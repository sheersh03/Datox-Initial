from fastapi import APIRouter, Depends, Header
from sqlalchemy.orm import Session
from app.api.deps import get_db
from app.core.config import settings
from app.core.errors import api_error
from app.schemas.admin import BanReq
from app.services.moderation_service import list_reports, ban_user

router = APIRouter(tags=["admin"])

def admin_guard(x_admin_key: str | None = Header(default=None)):
    admin_key = getattr(settings, "ADMIN_API_KEY", None)
    if not admin_key or x_admin_key != admin_key:
        api_error("FORBIDDEN", "Admin key required", 403)
    return True

@router.get("/reports")
def reports(
    status: str = "open",
    cursor: str | None = None,
    limit: int = 50,
    db: Session = Depends(get_db),
    _ok: bool = Depends(admin_guard),
):
    offset = int(cursor or "0")
    items = list_reports(db, status=status, offset=offset, limit=limit)
    next_cursor = str(offset + len(items)) if len(items) == limit else None
    return {"ok": True, "data": {"items": items, "next_cursor": next_cursor}}

@router.post("/ban")
def ban(req: BanReq, db: Session = Depends(get_db), _ok: bool = Depends(admin_guard)):
    u = ban_user(db, req.user_id, req.reason)
    return {"ok": True, "data": {"user_id": u.id, "is_banned": u.is_banned}}
