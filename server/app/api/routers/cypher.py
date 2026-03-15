"""Cypher Mode API."""

from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from app.api.deps import get_db, require_profile
from app.api.openapi_responses import PROFILE_REQUIRED_RESPONSE
from app.services.cypher_service import (
    require_cypher_access,
    get_or_create_profile,
    upsert_profile,
    discovery_candidates,
    react,
    list_matches,
)

router = APIRouter(tags=["cypher"])


class ProfileUpsert(BaseModel):
    avatar_id: str
    anonymous_username: str = Field(min_length=2, max_length=30)
    interest_tags: list[str] = Field(default_factory=list, max_length=20)
    fantasy_keywords: list[str] = Field(default_factory=list, max_length=20)
    headline: str | None = None
    communication_preferences: str | None = None
    boundaries: str | None = None
    mood: str | None = None
    curiosity_level: str | None = None
    discovery_visible: bool = True


class ReactReq(BaseModel):
    to_user_id: str
    is_like: bool


@router.get("/entitlement", responses={402: {"description": "Cypher requires Plus subscription"}})
def check_entitlement(
    db: Session = Depends(get_db),
    user_id: str = Depends(require_profile),
):
    """Check if user has Cypher access. Raises 402 if not."""
    require_cypher_access(db, user_id)
    return {"ok": True, "data": {"has_access": True}}


@router.get("/profile")
def get_profile(
    db: Session = Depends(get_db),
    user_id: str = Depends(require_profile),
):
    """Get current user's Cypher profile. 404 if not created."""
    require_cypher_access(db, user_id)
    profile = get_or_create_profile(db, user_id)
    if not profile:
        return {"ok": True, "data": None}
    return {
        "ok": True,
        "data": {
            "avatar_id": profile.avatar_id,
            "anonymous_username": profile.anonymous_username,
            "interest_tags": profile.interest_tags or [],
            "fantasy_keywords": profile.fantasy_keywords or [],
            "headline": profile.headline,
            "communication_preferences": profile.communication_preferences,
            "boundaries": profile.boundaries,
            "mood": profile.mood,
            "curiosity_level": profile.curiosity_level,
            "discovery_visible": profile.discovery_visible,
        }
    }


@router.post("/profile")
def post_profile(
    req: ProfileUpsert,
    db: Session = Depends(get_db),
    user_id: str = Depends(require_profile),
):
    """Create or update Cypher profile."""
    require_cypher_access(db, user_id)
    profile = upsert_profile(
        db,
        user_id,
        avatar_id=req.avatar_id,
        anonymous_username=req.anonymous_username,
        interest_tags=req.interest_tags,
        fantasy_keywords=req.fantasy_keywords,
        headline=req.headline,
        communication_preferences=req.communication_preferences,
        boundaries=req.boundaries,
        mood=req.mood,
        curiosity_level=req.curiosity_level,
        discovery_visible=req.discovery_visible,
    )
    return {"ok": True, "data": {"user_id": profile.user_id}}


@router.get("/candidates")
def get_candidates(
    limit: int = 20,
    db: Session = Depends(get_db),
    user_id: str = Depends(require_profile),
):
    """Get Cypher discovery candidates."""
    items = discovery_candidates(db, user_id, limit=limit)
    return {"ok": True, "data": {"items": items}}


@router.post("/react")
def post_react(
    req: ReactReq,
    db: Session = Depends(get_db),
    user_id: str = Depends(require_profile),
):
    """React to a candidate (like or pass)."""
    result = react(db, user_id, req.to_user_id, req.is_like)
    return {"ok": True, "data": result}


@router.get("/matches")
def get_matches(
    limit: int = 50,
    db: Session = Depends(get_db),
    user_id: str = Depends(require_profile),
):
    """List Cypher matches (anonymous)."""
    items = list_matches(db, user_id, limit=limit)
    return {"ok": True, "data": {"items": items}}
