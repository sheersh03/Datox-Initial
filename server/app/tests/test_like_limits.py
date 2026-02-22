import uuid
import pytest
from sqlalchemy.orm import Session
from app.services.user_service import get_or_create_user_by_phone
from app.services.discovery_service import enforce_like_limit
from app.services.subscription_service import set_tier
from app.models.like import Like

@pytest.fixture
def db():
    from app.db.session import SessionLocal
    db = SessionLocal()
    yield db
    db.close()

def test_free_like_limit(db: Session):
    u = get_or_create_user_by_phone(db, "+19999999999")
    set_tier(db, u.id, "free")

    # simulate 10 likes today
    for i in range(10):
        db.add(Like(id=str(uuid.uuid4()), from_user_id=u.id, to_user_id=str(uuid.uuid4()), is_like=True))
    db.commit()

    with pytest.raises(Exception):
        enforce_like_limit(db, u.id)

def test_lite_unlimited(db: Session):
    u = get_or_create_user_by_phone(db, "+18888888888")
    set_tier(db, u.id, "lite")
    # should not raise even if many likes exist
    for i in range(50):
        db.add(Like(id=str(uuid.uuid4()), from_user_id=u.id, to_user_id=str(uuid.uuid4()), is_like=True))
    db.commit()
    enforce_like_limit(db, u.id)
