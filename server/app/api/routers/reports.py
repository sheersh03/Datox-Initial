from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.api.deps import get_db
from app.core.security import auth_user_id
from app.core.rate_limit import rate_limit
from app.schemas.report import ReportReq, BlockReq
from app.services.moderation_service import report_user, block_user

router = APIRouter(tags=["safety"])

@router.post("/report")
def report(req: ReportReq, db: Session = Depends(get_db), user_id: str = Depends(auth_user_id)):
    rate_limit(f"report:{user_id}", limit=10, window_seconds=3600)
    r = report_user(db, user_id, req.reported_id, req.reason, req.details)
    return {"ok": True, "data": {"id": r.id}}

@router.post("/block")
def block(req: BlockReq, db: Session = Depends(get_db), user_id: str = Depends(auth_user_id)):
    rate_limit(f"block:{user_id}", limit=30, window_seconds=3600)
    b = block_user(db, user_id, req.blocked_id)
    return {"ok": True, "data": {"id": b.id}}
