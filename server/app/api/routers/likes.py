from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.api.deps import get_db, require_profile
from app.api.openapi_responses import PROFILE_REQUIRED_RESPONSE
from app.models.like import Like
from app.models.profile import Profile
from app.models.photo import Photo
from app.services.discovery_service import _haversine_km
from app.services.storage_service import public_url

router = APIRouter(tags=["likes"])


@router.get("/who-liked-me", responses={409: PROFILE_REQUIRED_RESPONSE})
def who_liked_me(
    limit: int = 50,
    db: Session = Depends(get_db),
    user_id: str = Depends(require_profile),
):
    """Return profiles of users who liked the current user, with liked_at and distance_km."""
    me = db.query(Profile).filter(Profile.user_id == user_id).first()
    if not me:
        return {"ok": True, "data": {"items": []}}

    rows = (
        db.query(Like)
        .filter(Like.to_user_id == user_id, Like.is_like == True)
        .order_by(Like.created_at.desc())
        .limit(limit)
        .all()
    )
    out = []
    for like in rows:
        p = db.query(Profile).filter(Profile.user_id == like.from_user_id).first()
        if not p:
            continue
        photos = (
            db.query(Photo)
            .filter(Photo.user_id == p.user_id)
            .order_by(Photo.is_primary.desc(), Photo.created_at.asc())
            .all()
        )
        primary_photo = photos[0] if photos else None
        distance_km = None
        if me.lat is not None and me.lng is not None and p.lat is not None and p.lng is not None:
            distance_km = round(_haversine_km(float(me.lat), float(me.lng), float(p.lat), float(p.lng)), 1)
        liked_at = like.created_at.isoformat() if like.created_at else None
        out.append({
            "user_id": p.user_id,
            "name": p.name,
            "birth_year": p.birth_year,
            "gender": p.gender,
            "intent": p.intent,
            "bio": p.bio,
            "city": p.city,
            "verification_status": p.verification_status,
            "primary_photo_url": public_url(primary_photo.s3_key) if primary_photo else None,
            "liked_at": liked_at,
            "distance_km": distance_km,
        })
    return {"ok": True, "data": {"items": out}}
