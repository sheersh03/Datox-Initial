from fastapi import Depends
from sqlalchemy.orm import Session

from app.db.session import SessionLocal
from app.core.security import auth_user_id
from app.core.errors import api_error
from app.models.profile import Profile

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def ensure_profile_exists(db: Session, user_id: str) -> None:
    has_profile = (
        db.query(Profile.user_id)
        .filter(Profile.user_id == user_id)
        .first()
    )
    if not has_profile:
        api_error("PROFILE_REQUIRED", "Complete profile first", 409)


def require_profile(
    user_id: str = Depends(auth_user_id),
    db: Session = Depends(get_db),
) -> str:
    ensure_profile_exists(db, user_id)
    return user_id
