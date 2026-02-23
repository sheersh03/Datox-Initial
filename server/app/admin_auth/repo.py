"""Database access for admin auth."""

import uuid
from datetime import datetime, timezone
from sqlalchemy.orm import Session

from app.models.admin_user import AdminUser
from app.models.admin_refresh_token import AdminRefreshToken


def get_admin_by_email(db: Session, email: str) -> AdminUser | None:
    """Fetch admin user by email. Returns None if not found."""
    return db.query(AdminUser).filter(AdminUser.email == email.lower().strip()).first()


def update_last_login(db: Session, admin_id: uuid.UUID) -> None:
    """Update admin_users.last_login_at to now (UTC)."""
    db.query(AdminUser).filter(AdminUser.id == admin_id).update(
        {"last_login_at": datetime.now(timezone.utc)}
    )


def store_refresh_token(
    db: Session,
    admin_id: uuid.UUID,
    jti_hash: str,
    expires_at: datetime,
) -> AdminRefreshToken:
    """Persist refresh token JTI hash for later validation/revocation."""
    rec = AdminRefreshToken(
        admin_id=admin_id,
        jti_hash=jti_hash,
        expires_at=expires_at,
    )
    db.add(rec)
    return rec


def get_valid_refresh_token_with_admin(
    db: Session,
    jti_hash: str,
    now: datetime,
) -> tuple[AdminRefreshToken, AdminUser] | None:
    """
    Fetch refresh token by jti_hash with admin join.
    Returns (token, admin) only if: exists, revoked_at IS NULL, expires_at > now.
    """
    row = (
        db.query(AdminRefreshToken, AdminUser)
        .join(AdminUser, AdminRefreshToken.admin_id == AdminUser.id)
        .filter(
            AdminRefreshToken.jti_hash == jti_hash,
            AdminRefreshToken.revoked_at.is_(None),
            AdminRefreshToken.expires_at > now,
        )
        .first()
    )
    if row is None:
        return None
    return (row[0], row[1])


def revoke_refresh_token(db: Session, token_id: uuid.UUID, now: datetime) -> None:
    """Set revoked_at = now on refresh token."""
    db.query(AdminRefreshToken).filter(AdminRefreshToken.id == token_id).update(
        {"revoked_at": now}
    )


def get_admin_by_id(db: Session, admin_id: uuid.UUID) -> AdminUser | None:
    """Fetch admin by id."""
    return db.query(AdminUser).filter(AdminUser.id == admin_id).first()
