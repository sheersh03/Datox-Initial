from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.api.deps import get_db
from app.schemas.auth import SendOtpReq, VerifyOtpReq, AuthToken
from app.services.otp_service import send_otp, verify_otp
from app.services.user_service import get_or_create_user_by_phone
from app.core.security import create_access_token
from app.core.rate_limit import rate_limit

router = APIRouter()

@router.post("/otp/send")
def otp_send(req: SendOtpReq):
    rate_limit(f"otp_send:{req.phone}", limit=5, window_seconds=60)
    send_otp(req.phone)
    return {"ok": True}

@router.post("/otp/verify", response_model=AuthToken)
def otp_verify(req: VerifyOtpReq, db: Session = Depends(get_db)):
    rate_limit(f"otp_verify:{req.phone}", limit=10, window_seconds=60)
    verify_otp(req.phone, req.code)
    user = get_or_create_user_by_phone(db, req.phone)
    # Persist newly created user before returning a token tied to user.id.
    db.commit()
    return AuthToken(access_token=create_access_token(user.id))

@router.post("/logout")
def logout():
    # JWT is stateless. For production: add token blacklist if needed.
    return {"ok": True}
