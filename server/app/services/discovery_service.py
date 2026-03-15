import math
import uuid
from datetime import datetime, timezone, date
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func
from app.core.config import settings
from app.core.errors import api_error
from app.models.profile import Profile
from app.models.like import Like
from app.models.report import Block
from app.models.subscription import Subscription
from app.services.subscription_service import get_tier, unlimited_likes, can_see_likes_you
from app.models.prompt import Prompt  # defined similarly
from app.models.user import User
from app.models.photo import Photo
from app.services.storage_service import public_url

def _haversine_km(lat1, lon1, lat2, lon2):
    if None in (lat1, lon1, lat2, lon2):
        return 99999.0
    R = 6371.0
    p1, p2 = math.radians(lat1), math.radians(lat2)
    d1 = math.radians(lat2-lat1)
    d2 = math.radians(lon2-lon1)
    a = math.sin(d1/2)**2 + math.cos(p1)*math.cos(p2)*math.sin(d2/2)**2
    return 2*R*math.asin(math.sqrt(a))

def _today_key() -> str:
    return date.today().isoformat()

def count_likes_today(db: Session, user_id: str) -> int:
    # count only likes (not passes) created today (UTC date boundary acceptable for MVP)
    return (
        db.query(func.count(Like.id))
        .filter(
            Like.from_user_id == user_id,
            Like.is_like == True,
            func.date(Like.created_at) == func.current_date()
        )
        .scalar()
    )

def enforce_like_limit(db: Session, user_id: str):
    tier = get_tier(db, user_id)
    if unlimited_likes(tier):
        return
    used = count_likes_today(db, user_id)
    if used >= settings.FREE_LIKES_PER_DAY:
        api_error("LIKE_LIMIT", "Daily like limit reached. Upgrade for unlimited likes.", 402)

def candidates(db: Session, user_id: str, limit: int = 20):
    # Profile existence is guaranteed by API dependency (require_profile).
    me = db.query(Profile).filter(Profile.user_id == user_id).one()
    if me.intent not in {"dating", "friends", "marriage"}:
        api_error(
            "PROFILE_INVALID",
            "Update profile intent to one of: dating, friends, marriage.",
            409,
        )
    if me.gender not in {"male", "female", "nonbinary"}:
        api_error(
            "PROFILE_INVALID",
            "Update profile gender to one of: male, female, nonbinary.",
            409,
        )
    if me.lat is None or me.lng is None:
        api_error(
            "LOCATION_REQUIRED",
            "Set your location before requesting discovery candidates.",
            409,
        )
    if not (-90 <= float(me.lat) <= 90 and -180 <= float(me.lng) <= 180):
        api_error(
            "LOCATION_INVALID",
            "Profile location is invalid. Please update your location.",
            409,
        )

    # blocked users
    blocked_ids = [b.blocked_id for b in db.query(Block).filter(Block.blocker_id == user_id).all()]
    blocked_me = [b.blocker_id for b in db.query(Block).filter(Block.blocked_id == user_id).all()]
    excluded = set(blocked_ids + blocked_me + [user_id])

    # already swiped
    swiped = db.query(Like.to_user_id).filter(Like.from_user_id == user_id).all()
    excluded.update([x[0] for x in swiped])

    # age filter
    this_year = datetime.now(timezone.utc).year
    min_by = this_year - int(me.age_max)
    max_by = this_year - int(me.age_min)

    q = db.query(Profile).filter(Profile.user_id.notin_(excluded))

    # preference gender
    if me.pref_gender:
        allowed = [g.strip() for g in me.pref_gender.split(",") if g.strip()]
        if allowed:
            q = q.filter(Profile.gender.in_(allowed))

    # intent
    q = q.filter(Profile.intent == me.intent)

    # age range
    q = q.filter(Profile.birth_year.between(min_by, max_by))

    rows = q.limit(400).all()  # preselect set, then rank in Python for MVP

    # prompt overlap: count shared question keywords (cheap heuristic)
    my_prompts = db.query(Prompt).filter(Prompt.user_id == user_id).all()
    my_text = " ".join([p.answer.lower() for p in my_prompts])[:2000]

    scored = []
    for p in rows:
        dist = _haversine_km(me.lat, me.lng, p.lat, p.lng)
        if dist > float(me.distance_km):
            continue
        other_prompts = db.query(Prompt).filter(Prompt.user_id == p.user_id).all()
        other_text = " ".join([x.answer.lower() for x in other_prompts])[:2000]
        overlap = 0
        for w in set(my_text.split()):
            if len(w) >= 5 and w in other_text:
                overlap += 1
        # activity score: recently updated profile gets small bonus
        activity = 1.0
        score = (overlap * 2.0) + (activity) - (dist / 50.0)
        scored.append((score, dist, p))

    scored.sort(key=lambda x: x[0], reverse=True)
    out = []
    for score, dist, p in scored[:limit]:
        photos = (
            db.query(Photo)
            .filter(Photo.user_id == p.user_id)
            .order_by(Photo.is_primary.desc(), Photo.created_at.asc())
            .all()
        )
        primary_photo = photos[0] if photos else None
        out.append({
            "user_id": p.user_id,
            "name": p.name,
            "birth_year": p.birth_year,
            "gender": p.gender,
            "intent": p.intent,
            "bio": p.bio,
            "city": p.city,
            "approx_location": {"lat": p.approx_lat, "lng": p.approx_lng},
            "distance_km": round(dist, 1),
            "verification_status": p.verification_status,
            "primary_photo_url": public_url(primary_photo.s3_key) if primary_photo else None,
        })
    return out


def who_liked_me(db: Session, user_id: str, limit: int = 50):
    """Users who liked me (to_user_id=me, is_like=True), excluding blocked and already-swiped."""
    tier = get_tier(db, user_id)
    if not can_see_likes_you(tier):
        api_error(
            "PAYWALL_REQUIRED",
            "Upgrade to see who liked you.",
            402,
        )

    me = db.query(Profile).filter(Profile.user_id == user_id).first()
    if not me or me.lat is None or me.lng is None:
        api_error("LOCATION_REQUIRED", "Set your location first.", 409)

    blocked_ids = [b.blocked_id for b in db.query(Block).filter(Block.blocker_id == user_id).all()]
    blocked_me = [b.blocker_id for b in db.query(Block).filter(Block.blocked_id == user_id).all()]
    excluded = set(blocked_ids + blocked_me + [user_id])

    # I've already swiped on these users
    my_swipes = db.query(Like.to_user_id).filter(Like.from_user_id == user_id).all()
    excluded.update(x[0] for x in my_swipes)

    q = (
        db.query(Like)
        .filter(Like.to_user_id == user_id, Like.is_like == True)
        .order_by(Like.created_at.desc())
        .limit(limit * 2)
    )
    if excluded:
        q = q.filter(Like.from_user_id.notin_(excluded))
    likes = q.all()

    liker_ids = [l.from_user_id for l in likes]
    if not liker_ids:
        return []

    profiles = db.query(Profile).filter(Profile.user_id.in_(liker_ids)).all()
    profile_map = {p.user_id: p for p in profiles}

    out = []
    for like in likes[:limit]:
        p = profile_map.get(like.from_user_id)
        if not p:
            continue
        dist = _haversine_km(me.lat, me.lng, p.lat, p.lng)
        photos = (
            db.query(Photo)
            .filter(Photo.user_id == p.user_id)
            .order_by(Photo.is_primary.desc(), Photo.created_at.asc())
            .all()
        )
        primary_photo = photos[0] if photos else None
        out.append({
            "user_id": p.user_id,
            "name": p.name,
            "birth_year": p.birth_year,
            "gender": p.gender,
            "intent": p.intent,
            "bio": p.bio,
            "city": p.city,
            "approx_location": {"lat": p.approx_lat, "lng": p.approx_lng},
            "distance_km": round(dist, 1),
            "verification_status": p.verification_status,
            "primary_photo_url": public_url(primary_photo.s3_key) if primary_photo else None,
            "liked_at": like.created_at.isoformat() if like.created_at else None,
        })
    return out
