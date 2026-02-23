"""Audit logging for admin auth actions."""

import uuid
from typing import Any

from sqlalchemy.orm import Session

from app.models.audit_log import AuditLog

ADMIN_LOGIN_SUCCESS = "ADMIN_LOGIN_SUCCESS"
ADMIN_LOGIN_FAILED = "ADMIN_LOGIN_FAILED"
ADMIN_TOKEN_REFRESH_SUCCESS = "ADMIN_TOKEN_REFRESH_SUCCESS"
ADMIN_TOKEN_REFRESH_FAILED = "ADMIN_TOKEN_REFRESH_FAILED"


def log_admin_login(
    db: Session,
    admin_id: uuid.UUID | None,
    action: str,
    ip_address: str | None,
    user_agent: str | None,
    metadata_: dict[str, Any] | None = None,
) -> None:
    """
    Log admin login attempt to audit_logs.
    metadata_ must NOT contain password. Typically {"email": "..."}.
    """
    log = AuditLog(
        admin_id=admin_id,
        action=action,
        entity_type="admin_auth",
        entity_id=None,
        metadata_=metadata_ or {},
        ip_address=ip_address,
        user_agent=user_agent,
    )
    db.add(log)


def log_admin_refresh(
    db: Session,
    admin_id: uuid.UUID | None,
    action: str,
    ip_address: str | None,
    user_agent: str | None,
    metadata_: dict[str, Any] | None = None,
) -> None:
    """Log admin token refresh attempt."""
    log = AuditLog(
        admin_id=admin_id,
        action=action,
        entity_type="admin_auth",
        entity_id=None,
        metadata_=metadata_ or {},
        ip_address=ip_address,
        user_agent=user_agent,
    )
    db.add(log)
