"""Admin auth business logic."""

import uuid
from datetime import datetime, timezone

from sqlalchemy.orm import Session

from app.admin_auth.audit import (
    ADMIN_LOGIN_FAILED,
    ADMIN_LOGIN_SUCCESS,
    ADMIN_TOKEN_REFRESH_FAILED,
    ADMIN_TOKEN_REFRESH_SUCCESS,
    log_admin_login,
    log_admin_refresh,
)
from app.admin_auth.rate_limit import (
    check_admin_login_rate_limit,
    check_admin_refresh_rate_limit,
)
from app.admin_auth.repo import (
    get_admin_by_email,
    get_valid_refresh_token_with_admin,
    revoke_refresh_token,
    store_refresh_token,
    update_last_login,
)
from app.admin_auth.schemas import AdminInfo, AdminLoginResponse, TokenResponse
from app.admin_auth.security import (
    create_admin_access_token,
    create_admin_refresh_token,
    decode_admin_token,
    get_jti_hash_for_storage,
    verify_password,
)
from app.core.errors import api_error


def admin_login(
    db: Session,
    email: str,
    password: str,
    ip_address: str | None = None,
    user_agent: str | None = None,
) -> AdminLoginResponse:
    """
    Authenticate admin and return tokens.
    Raises: 401 invalid credentials, 403 admin disabled, 429 rate limited.
    """
    # Rate limit first (before any DB lookup to avoid timing leaks)
    if not check_admin_login_rate_limit(ip_address or "unknown", email):
        api_error("RATE_LIMITED", "Too many attempts", 429)

    admin = get_admin_by_email(db, email)

    # Generic "Invalid credentials" for wrong email OR wrong password (no user enumeration)
    if not admin:
        log_admin_login(
            db,
            admin_id=None,
            action=ADMIN_LOGIN_FAILED,
            ip_address=ip_address,
            user_agent=user_agent,
            metadata_={"email": email},
        )
        db.commit()
        api_error("INVALID_CREDENTIALS", "Invalid credentials", 401)

    if not admin.is_active:
        log_admin_login(
            db,
            admin_id=admin.id,
            action=ADMIN_LOGIN_FAILED,
            ip_address=ip_address,
            user_agent=user_agent,
            metadata_={"email": email, "reason": "inactive"},
        )
        db.commit()
        api_error("ADMIN_DISABLED", "Admin disabled", 403)

    if not verify_password(password, admin.password_hash):
        log_admin_login(
            db,
            admin_id=None,  # Don't reveal admin exists
            action=ADMIN_LOGIN_FAILED,
            ip_address=ip_address,
            user_agent=user_agent,
            metadata_={"email": email},
        )
        db.commit()
        api_error("INVALID_CREDENTIALS", "Invalid credentials", 401)

    # Success
    access_token, expires_in = create_admin_access_token(admin.id, admin.role)
    refresh_token, jti_hash, expires_at = create_admin_refresh_token(admin.id, admin.role)

    store_refresh_token(db, admin.id, jti_hash, expires_at)
    update_last_login(db, admin.id)

    log_admin_login(
        db,
        admin_id=admin.id,
        action=ADMIN_LOGIN_SUCCESS,
        ip_address=ip_address,
        user_agent=user_agent,
        metadata_={"email": email},
    )
    db.commit()

    return AdminLoginResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        expires_in=expires_in,
        admin=AdminInfo(
            id=admin.id,
            email=admin.email,
            role=admin.role,
            is_active=admin.is_active,
        ),
    )


def refresh_token(
    db: Session,
    refresh_token_str: str,
    ip_address: str | None = None,
    user_agent: str | None = None,
) -> TokenResponse:
    """
    Validate refresh token, rotate it, return new tokens.
    Raises: 401 invalid refresh token, 403 admin disabled, 429 rate limited.
    """
    payload = decode_admin_token(refresh_token_str)
    if not payload or payload.get("token_type") != "refresh":
        log_admin_refresh(
            db,
            admin_id=None,
            action=ADMIN_TOKEN_REFRESH_FAILED,
            ip_address=ip_address,
            user_agent=user_agent,
            metadata_={"reason": "invalid_token"},
        )
        db.commit()
        api_error("INVALID_REFRESH_TOKEN", "Invalid refresh token", 401)

    jti = payload.get("jti")
    sub = payload.get("sub")
    if not jti or not sub:
        log_admin_refresh(
            db,
            admin_id=None,
            action=ADMIN_TOKEN_REFRESH_FAILED,
            ip_address=ip_address,
            user_agent=user_agent,
            metadata_={"reason": "missing_claims"},
        )
        db.commit()
        api_error("INVALID_REFRESH_TOKEN", "Invalid refresh token", 401)

    try:
        admin_id = uuid.UUID(sub)
    except (ValueError, TypeError):
        log_admin_refresh(
            db,
            admin_id=None,
            action=ADMIN_TOKEN_REFRESH_FAILED,
            ip_address=ip_address,
            user_agent=user_agent,
            metadata_={"reason": "invalid_sub"},
        )
        db.commit()
        api_error("INVALID_REFRESH_TOKEN", "Invalid refresh token", 401)

    if not check_admin_refresh_rate_limit(str(admin_id)):
        api_error("RATE_LIMITED", "Too many requests", 429)

    jti_hash = get_jti_hash_for_storage(jti)
    now = datetime.now(timezone.utc)

    result = get_valid_refresh_token_with_admin(db, jti_hash, now)
    if not result:
        log_admin_refresh(
            db,
            admin_id=admin_id,
            action=ADMIN_TOKEN_REFRESH_FAILED,
            ip_address=ip_address,
            user_agent=user_agent,
            metadata_={"admin_id": str(admin_id), "reason": "token_not_found_or_revoked_or_expired"},
        )
        db.commit()
        api_error("INVALID_REFRESH_TOKEN", "Invalid refresh token", 401)

    token_rec, admin = result

    if not admin.is_active:
        log_admin_refresh(
            db,
            admin_id=admin.id,
            action=ADMIN_TOKEN_REFRESH_FAILED,
            ip_address=ip_address,
            user_agent=user_agent,
            metadata_={"admin_id": str(admin.id), "reason": "admin_disabled"},
        )
        db.commit()
        api_error("ADMIN_DISABLED", "Admin disabled", 403)

    revoke_refresh_token(db, token_rec.id, now)
    access_token, expires_in = create_admin_access_token(admin.id, admin.role)
    new_refresh_token, new_jti_hash, new_expires_at = create_admin_refresh_token(
        admin.id, admin.role
    )
    store_refresh_token(db, admin.id, new_jti_hash, new_expires_at)

    log_admin_refresh(
        db,
        admin_id=admin.id,
        action=ADMIN_TOKEN_REFRESH_SUCCESS,
        ip_address=ip_address,
        user_agent=user_agent,
        metadata_={"admin_id": str(admin.id)},
    )
    db.commit()

    return TokenResponse(
        access_token=access_token,
        refresh_token=new_refresh_token,
        token_type="bearer",
        expires_in=expires_in,
    )
