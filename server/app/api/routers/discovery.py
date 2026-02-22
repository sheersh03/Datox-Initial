from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from pydantic import BaseModel, Field

from app.api.deps import get_db, require_profile
from app.api.openapi_responses import PROFILE_REQUIRED_RESPONSE
from app.services.discovery_service import candidates
from app.services.match_service import swipe

router = APIRouter(tags=["discovery"])

class SwipeReq(BaseModel):
    to_user_id: str
    action: str = Field(pattern="^(like|pass)$")


@router.get("/candidates", responses={409: PROFILE_REQUIRED_RESPONSE})
def get_candidates(
    limit: int = 20,
    db: Session = Depends(get_db),
    user_id: str = Depends(require_profile),
):
    return {
        "ok": True,
        "data": {
            "items": candidates(db, user_id, limit=limit)
        }
    }


@router.post("/swipe", responses={409: PROFILE_REQUIRED_RESPONSE})
def post_swipe(
    req: SwipeReq,
    db: Session = Depends(get_db),
    user_id: str = Depends(require_profile),
):
    res = swipe(
        db,
        user_id,
        req.to_user_id,
        is_like=(req.action == "like"),
    )
    return {"ok": True, "data": res}
