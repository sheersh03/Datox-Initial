from sqlalchemy.orm import Session
from app.services.user_service import get_or_create_user_by_phone
from app.services.subscription_service import set_tier, get_tier

def test_tier_persists():
    from app.db.session import SessionLocal
    db: Session = SessionLocal()
    u = get_or_create_user_by_phone(db, "+16660000001")
    set_tier(db, u.id, "plus")
    assert get_tier(db, u.id) == "plus"
    db.close()
