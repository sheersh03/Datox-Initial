from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.api.deps import get_db, require_profile
from app.api.openapi_responses import PROFILE_REQUIRED_RESPONSE
from app.services.chat_service import list_matches

router = APIRouter(tags=["matching"])

@router.get("/matches", responses={409: PROFILE_REQUIRED_RESPONSE})
def matches(
    cursor: str | None = None,
    limit: int = 20,
    db: Session = Depends(get_db),
    user_id: str = Depends(require_profile),
):
    offset = int(cursor or "0")
    items = list_matches(db, user_id, offset, limit)
    next_cursor = str(offset + len(items)) if len(items) == limit else None
    return {"ok": True, "data": {"items": items, "next_cursor": next_cursor}}
