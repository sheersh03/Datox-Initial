import uuid
import json
from datetime import datetime, timezone
from sqlalchemy.orm import Session

from app.core.errors import api_error
from app.models.addon_entitlement import UserEntitlement, AddonUsageLog

ADDON_TYPES = {
    "spotlight", "super_swipe", "boost", "compliment",
    "extend", "rematch", "backtrack", "travel_mode", "incognito",
}


def get_entitlements(db: Session, user_id: str) -> list[dict]:
    rows = db.query(UserEntitlement).filter(
        UserEntitlement.user_id == user_id,
        UserEntitlement.is_active == True,
    ).all()

    now = datetime.now(timezone.utc)
    result = []
    for r in rows:
        if r.expires_at and r.expires_at < now:
            continue
        result.append({
            "addon_type": r.addon_type,
            "remaining_count": r.remaining_count,
            "expires_at": r.expires_at.isoformat() if r.expires_at else None,
            "is_active": r.is_active,
        })
    return result


def get_entitlement(db: Session, user_id: str, addon_type: str) -> UserEntitlement | None:
    now = datetime.now(timezone.utc)
    return db.query(UserEntitlement).filter(
        UserEntitlement.user_id == user_id,
        UserEntitlement.addon_type == addon_type,
        UserEntitlement.is_active == True,
        (UserEntitlement.expires_at == None) | (UserEntitlement.expires_at > now),
    ).first()


def grant_entitlement(
    db: Session,
    user_id: str,
    addon_type: str,
    remaining_count: int = 1,
    expires_at: datetime | None = None,
) -> UserEntitlement:
    if addon_type not in ADDON_TYPES:
        api_error("BAD_REQUEST", f"Invalid addon_type: {addon_type}", 400)

    existing = db.query(UserEntitlement).filter(
        UserEntitlement.user_id == user_id,
        UserEntitlement.addon_type == addon_type,
        UserEntitlement.is_active == True,
    ).first()

    if existing:
        existing.remaining_count += remaining_count
        if expires_at:
            existing.expires_at = expires_at
        db.commit()
        return existing

    ent = UserEntitlement(
        id=str(uuid.uuid4()),
        user_id=user_id,
        addon_type=addon_type,
        remaining_count=remaining_count,
        expires_at=expires_at,
        is_active=True,
    )
    db.add(ent)
    db.commit()
    return ent


def use_addon(
    db: Session,
    user_id: str,
    addon_type: str,
    metadata: dict | None = None,
) -> bool:
    """Deduct one use. Returns True if successful. Server-side validation."""
    if addon_type not in ADDON_TYPES:
        api_error("BAD_REQUEST", f"Invalid addon_type: {addon_type}", 400)

    ent = get_entitlement(db, user_id, addon_type)
    if not ent:
        api_error("NO_ENTITLEMENT", f"No active entitlement for {addon_type}", 403)

    if ent.addon_type in ("spotlight", "travel_mode", "incognito"):
        pass
    elif ent.remaining_count <= 0:
        api_error("NO_REMAINING", f"No remaining uses for {addon_type}", 403)

    if ent.addon_type not in ("spotlight", "travel_mode", "incognito"):
        ent.remaining_count -= 1

    log = AddonUsageLog(
        id=str(uuid.uuid4()),
        user_id=user_id,
        addon_type=addon_type,
        metadata_json=json.dumps(metadata) if metadata else None,
    )
    db.add(log)
    db.commit()
    return True
