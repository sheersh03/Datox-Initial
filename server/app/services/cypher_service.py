"""Cypher Mode service: profile, discovery, matching."""

import uuid
from sqlalchemy.orm import Session
from sqlalchemy import or_, and_, func

from app.core.errors import api_error
from app.models.cypher_profile import CypherProfile
from app.models.cypher_reaction import CypherReaction
from app.models.cypher_match import CypherMatch
from app.models.report import Block
from app.services.subscription_service import get_tier, can_access_cypher


def require_cypher_access(db: Session, user_id: str) -> None:
    """Raise 402 if user does not have Cypher access."""
    tier = get_tier(db, user_id)
    if not can_access_cypher(tier):
        api_error(
            "CYPHER_PAYWALL",
            "Upgrade to Plus to access Cypher Mode.",
            402,
        )


def get_or_create_profile(db: Session, user_id: str) -> CypherProfile | None:
    """Get Cypher profile for user, or None if not created yet."""
    return db.query(CypherProfile).filter(CypherProfile.user_id == user_id).first()


def upsert_profile(
    db: Session,
    user_id: str,
    *,
    avatar_id: str,
    anonymous_username: str,
    interest_tags: list[str] | None = None,
    fantasy_keywords: list[str] | None = None,
    headline: str | None = None,
    communication_preferences: str | None = None,
    boundaries: str | None = None,
    mood: str | None = None,
    curiosity_level: str | None = None,
    discovery_visible: bool = True,
) -> CypherProfile:
    """Create or update Cypher profile."""
    profile = db.query(CypherProfile).filter(CypherProfile.user_id == user_id).first()
    if profile:
        profile.avatar_id = avatar_id
        profile.anonymous_username = anonymous_username
        profile.interest_tags = interest_tags or profile.interest_tags
        profile.fantasy_keywords = fantasy_keywords or profile.fantasy_keywords
        profile.headline = headline
        profile.communication_preferences = communication_preferences
        profile.boundaries = boundaries
        profile.mood = mood
        profile.curiosity_level = curiosity_level
        profile.discovery_visible = discovery_visible
    else:
        profile = CypherProfile(
            user_id=user_id,
            avatar_id=avatar_id,
            anonymous_username=anonymous_username,
            interest_tags=interest_tags or [],
            fantasy_keywords=fantasy_keywords or [],
            headline=headline,
            communication_preferences=communication_preferences,
            boundaries=boundaries,
            mood=mood,
            curiosity_level=curiosity_level,
            discovery_visible=discovery_visible,
        )
        db.add(profile)
    db.commit()
    db.refresh(profile)
    return profile


def discovery_candidates(db: Session, user_id: str, limit: int = 20) -> list[dict]:
    """Get Cypher discovery candidates for user. Excludes blocked, already reacted, self."""
    require_cypher_access(db, user_id)

    me = get_or_create_profile(db, user_id)
    if not me or not me.discovery_visible:
        return []

    blocked_ids = [b.blocked_id for b in db.query(Block).filter(Block.blocker_id == user_id).all()]
    blocked_me = [b.blocker_id for b in db.query(Block).filter(Block.blocked_id == user_id).all()]
    excluded = set(blocked_ids + blocked_me + [user_id])

    reacted = db.query(CypherReaction.to_user_id).filter(CypherReaction.from_user_id == user_id).all()
    excluded.update(r[0] for r in reacted)

    matched = db.query(CypherMatch).filter(
        or_(
            CypherMatch.user_a == user_id,
            CypherMatch.user_b == user_id,
        )
    ).all()
    for m in matched:
        other = m.user_b if m.user_a == user_id else m.user_a
        excluded.add(other)

    q = db.query(CypherProfile).filter(CypherProfile.discovery_visible == True)
    if excluded:
        q = q.filter(CypherProfile.user_id.notin_(excluded))
    profiles = q.limit(limit * 2).all()

    def _shared_count(a: CypherProfile, b: CypherProfile) -> int:
        atags = set(a.interest_tags or []) | set(a.fantasy_keywords or [])
        btags = set(b.interest_tags or []) | set(b.fantasy_keywords or [])
        return len(atags & btags)

    scored = [(p, _shared_count(me, p)) for p in profiles]
    scored.sort(key=lambda x: x[1], reverse=True)

    out = []
    for p in scored[:limit]:
        prof = p[0]
        out.append({
            "user_id": prof.user_id,
            "avatar_id": prof.avatar_id,
            "anonymous_username": prof.anonymous_username,
            "headline": prof.headline,
            "interest_tags": prof.interest_tags or [],
            "fantasy_keywords": prof.fantasy_keywords or [],
            "mood": prof.mood,
            "curiosity_level": prof.curiosity_level,
            "shared_count": p[1],
        })
    return out


def react(db: Session, from_user_id: str, to_user_id: str, is_like: bool) -> dict:
    """Record reaction. If mutual like, create match. Returns {reacted: bool, matched: bool, match_id?: str}."""
    require_cypher_access(db, from_user_id)

    if from_user_id == to_user_id:
        api_error("BAD_REQUEST", "Cannot react to yourself", 400)

    existing = db.query(CypherReaction).filter(
        CypherReaction.from_user_id == from_user_id,
        CypherReaction.to_user_id == to_user_id,
    ).first()
    if existing:
        api_error("ALREADY_REACTED", "Already reacted to this user", 409)

    db.add(CypherReaction(
        id=str(uuid.uuid4()),
        from_user_id=from_user_id,
        to_user_id=to_user_id,
        is_like=is_like,
    ))
    db.commit()

    if not is_like:
        return {"reacted": True, "matched": False}

    other_like = db.query(CypherReaction).filter(
        CypherReaction.from_user_id == to_user_id,
        CypherReaction.to_user_id == from_user_id,
        CypherReaction.is_like == True,
    ).first()

    if not other_like:
        return {"reacted": True, "matched": False}

    a, b = (from_user_id, to_user_id) if from_user_id < to_user_id else (to_user_id, from_user_id)
    existing_match = db.query(CypherMatch).filter(
        CypherMatch.user_a == a,
        CypherMatch.user_b == b,
    ).first()
    if existing_match:
        return {"reacted": True, "matched": True, "match_id": existing_match.id}

    match = CypherMatch(
        id=str(uuid.uuid4()),
        user_a=a,
        user_b=b,
    )
    db.add(match)
    db.commit()
    return {"reacted": True, "matched": True, "match_id": match.id}


def list_matches(db: Session, user_id: str, limit: int = 50) -> list[dict]:
    """List Cypher matches for user. Returns anonymous profile data only."""
    require_cypher_access(db, user_id)

    matches = (
        db.query(CypherMatch)
        .filter(
            or_(CypherMatch.user_a == user_id, CypherMatch.user_b == user_id),
            CypherMatch.reveal_status == "none",
        )
        .order_by(CypherMatch.created_at.desc())
        .limit(limit)
        .all()
    )

    out = []
    for m in matches:
        other_id = m.user_b if m.user_a == user_id else m.user_a
        prof = db.query(CypherProfile).filter(CypherProfile.user_id == other_id).first()
        if not prof:
            continue
        out.append({
            "match_id": m.id,
            "user_id": other_id,
            "avatar_id": prof.avatar_id,
            "anonymous_username": prof.anonymous_username,
            "headline": prof.headline,
            "interest_tags": prof.interest_tags or [],
            "created_at": m.created_at.isoformat() if m.created_at else None,
        })
    return out
