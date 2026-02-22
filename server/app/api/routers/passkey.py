import json
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_db, auth_user_id
from app.schemas.passkey import PasskeyRegisterStartReq, PasskeyRegisterFinishReq
from app.services.passkey_service import (
    start_registration,
    finish_registration,
    has_passkey,
)
from app.core.rate_limit import rate_limit

router = APIRouter()


@router.post("/register/start")
def register_start(
    req: PasskeyRegisterStartReq,
    db: Session = Depends(get_db),
    user_id: str = Depends(auth_user_id),
):
    rate_limit(f"passkey_start:{user_id}", limit=10, window_seconds=60)
    options_json = start_registration(db, user_id, req.user_name or user_id)
    return {"options": json.loads(options_json)}


@router.post("/register/finish")
def register_finish(
    req: PasskeyRegisterFinishReq,
    db: Session = Depends(get_db),
    user_id: str = Depends(auth_user_id),
):
    rate_limit(f"passkey_finish:{user_id}", limit=10, window_seconds=60)
    finish_registration(db, user_id, req.credential)
    return {"ok": True}


@router.get("/has")
def check_has_passkey(
    db: Session = Depends(get_db),
    user_id: str = Depends(auth_user_id),
):
    return {"has_passkey": has_passkey(db, user_id)}
