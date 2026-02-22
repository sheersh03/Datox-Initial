import json, uuid
from datetime import datetime, timezone
from sqlalchemy.orm import Session
from app.models.subscription import Subscription
from app.core.config import settings

TIERS = ["free", "lite", "plus"]

def get_tier(db: Session, user_id: str) -> str:
    sub = db.query(Subscription).filter(Subscription.user_id == user_id).first()
    if not sub:
        return "free"
    # if expired => free
    if sub.expires_at and sub.expires_at < datetime.now(timezone.utc):
        return "free"
    return sub.tier or "free"

def set_tier(db: Session, user_id: str, tier: str, expires_at=None, entitlements=None):
    sub = db.query(Subscription).filter(Subscription.user_id == user_id).first()
    if not sub:
        sub = Subscription(id=str(uuid.uuid4()), user_id=user_id)
        db.add(sub)
    sub.tier = tier
    sub.expires_at = expires_at
    sub.entitlements_json = json.dumps(entitlements) if entitlements is not None else sub.entitlements_json
    db.commit()

def can_see_likes_you(tier: str) -> bool:
    return tier in ("lite","plus")

def unlimited_likes(tier: str) -> bool:
    return tier in ("lite","plus")

def has_read_receipts(tier: str) -> bool:
    return tier == "plus"

def has_undo_swipe(tier: str) -> bool:
    return tier == "plus"

def weekly_boosts(tier: str) -> int:
    return 1 if tier == "plus" else 0
