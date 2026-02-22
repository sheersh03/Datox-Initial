import uuid
import pytest
from sqlalchemy.orm import Session
from app.services.user_service import get_or_create_user_by_phone
from app.services.match_service import swipe

@pytest.fixture
def db():
    from app.db.session import SessionLocal
    db = SessionLocal()
    yield db
    db.close()

def test_mutual_like_creates_match(db: Session):
    a = get_or_create_user_by_phone(db, "+17770000001")
    b = get_or_create_user_by_phone(db, "+17770000002")

    r1 = swipe(db, a.id, b.id, True)
    assert r1["matched"] is False

    r2 = swipe(db, b.id, a.id, True)
    assert r2["matched"] is True
    assert "match_id" in r2
