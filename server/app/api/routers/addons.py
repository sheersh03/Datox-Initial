from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from pydantic import BaseModel

from app.api.deps import get_db
from app.core.security import auth_user_id
from app.services.addon_service import get_entitlements, use_addon

router = APIRouter(tags=["addons"])


@router.get("/entitlements")
def list_entitlements(
    db: Session = Depends(get_db),
    user_id: str = Depends(auth_user_id),
):
    items = get_entitlements(db, user_id)
    return {"ok": True, "data": {"items": items}}


class UseAddonRequest(BaseModel):
    addon_type: str
    metadata: dict | None = None


@router.post("/use")
def use_addon_endpoint(
    req: UseAddonRequest,
    db: Session = Depends(get_db),
    user_id: str = Depends(auth_user_id),
):
    use_addon(db, user_id, req.addon_type, req.metadata)
    return {"ok": True}
