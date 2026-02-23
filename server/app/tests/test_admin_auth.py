"""Tests for admin auth login and refresh API."""

import uuid
from datetime import datetime, timedelta, timezone

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient
from jose import jwt
from sqlalchemy.orm import Session

from app.admin_auth.rate_limit import _clear_memory_store_for_tests
from app.admin_auth.router import router as admin_auth_router
from app.admin_auth.security import (
    create_admin_refresh_token,
    get_jti_hash_for_storage,
    hash_password,
)
from app.models.admin_refresh_token import AdminRefreshToken
from app.models.admin_user import AdminUser

# Minimal app for testing (avoids loading full app + all deps)
_test_app = FastAPI()
_test_app.include_router(admin_auth_router, prefix="/api/v1/admin")

# Run: pytest app/tests/test_admin_auth.py -v
# Requires: PostgreSQL (migrations 0005, 0006), Redis optional (in-memory fallback for rate limit)


@pytest.fixture
def db():
    from app.db.session import SessionLocal

    db = SessionLocal()
    yield db
    db.close()


@pytest.fixture
def client():
    return TestClient(_test_app)


@pytest.fixture
def active_admin(db: Session) -> AdminUser:
    """Create an active admin user for tests."""
    admin = AdminUser(
        id=uuid.uuid4(),
        email="admin@datox.com",
        password_hash=hash_password("correct_password"),
        role="super_admin",
        is_active=True,
    )
    db.add(admin)
    db.commit()
    db.refresh(admin)
    return admin


@pytest.fixture
def inactive_admin(db: Session) -> AdminUser:
    """Create an inactive admin user for tests."""
    admin = AdminUser(
        id=uuid.uuid4(),
        email="disabled@datox.com",
        password_hash=hash_password("correct_password"),
        role="moderator",
        is_active=False,
    )
    db.add(admin)
    db.commit()
    db.refresh(admin)
    return admin


def test_valid_login_returns_tokens(client: TestClient, active_admin: AdminUser):
    """Valid login returns access_token, refresh_token, and admin info."""
    resp = client.post(
        "/api/v1/admin/auth/login",
        json={"email": "admin@datox.com", "password": "correct_password"},
    )
    assert resp.status_code == 200
    data = resp.json()
    assert "access_token" in data
    assert "refresh_token" in data
    assert data["token_type"] == "bearer"
    assert data["expires_in"] > 0
    assert data["admin"]["id"] == str(active_admin.id)
    assert data["admin"]["email"] == "admin@datox.com"
    assert data["admin"]["role"] == "super_admin"
    assert data["admin"]["is_active"] is True


def test_invalid_password_returns_401(client: TestClient, active_admin: AdminUser):
    """Wrong password returns 401 with generic message."""
    resp = client.post(
        "/api/v1/admin/auth/login",
        json={"email": "admin@datox.com", "password": "wrong_password"},
    )
    assert resp.status_code == 401
    data = resp.json()
    assert "Invalid credentials" in data.get("detail", {}).get("message", "")


def test_invalid_email_returns_401(client: TestClient):
    """Wrong email returns 401 with generic message (no user enumeration)."""
    resp = client.post(
        "/api/v1/admin/auth/login",
        json={"email": "nonexistent@datox.com", "password": "any_password"},
    )
    assert resp.status_code == 401
    data = resp.json()
    assert "Invalid credentials" in data.get("detail", {}).get("message", "")


def test_inactive_admin_returns_403(client: TestClient, inactive_admin: AdminUser):
    """Inactive admin returns 403."""
    resp = client.post(
        "/api/v1/admin/auth/login",
        json={"email": "disabled@datox.com", "password": "correct_password"},
    )
    assert resp.status_code == 403
    data = resp.json()
    assert "Admin disabled" in data.get("detail", {}).get("message", "")


def test_rate_limit_returns_429(client: TestClient, active_admin: AdminUser):
    """After N attempts, returns 429."""
    _clear_memory_store_for_tests()
    email = f"ratelimit_{uuid.uuid4()}@datox.com"
    # Create admin with this unique email so we don't hit "invalid credentials"
    from app.db.session import SessionLocal

    db = SessionLocal()
    try:
        admin = AdminUser(
            id=uuid.uuid4(),
            email=email,
            password_hash=hash_password("correct_password"),
            role="analyst",
            is_active=True,
        )
        db.add(admin)
        db.commit()
    finally:
        db.close()

    limit = 5
    for i in range(limit):
        resp = client.post(
            "/api/v1/admin/auth/login",
            json={"email": email, "password": "wrong_password"},
        )
        assert resp.status_code == 401
    # Next attempt should be rate limited
    resp = client.post(
        "/api/v1/admin/auth/login",
        json={"email": email, "password": "wrong_password"},
    )
    assert resp.status_code == 429


# --- Refresh token tests ---


def test_valid_refresh_rotates_tokens(client: TestClient, active_admin: AdminUser):
    """Valid refresh returns new tokens; old refresh token is revoked."""
    login_resp = client.post(
        "/api/v1/admin/auth/login",
        json={"email": "admin@datox.com", "password": "correct_password"},
    )
    assert login_resp.status_code == 200
    refresh_tok = login_resp.json()["refresh_token"]

    refresh_resp = client.post(
        "/api/v1/admin/auth/refresh",
        json={"refresh_token": refresh_tok},
    )
    assert refresh_resp.status_code == 200
    data = refresh_resp.json()
    assert "access_token" in data
    assert "refresh_token" in data
    assert data["token_type"] == "bearer"
    assert data["expires_in"] > 0
    assert data["refresh_token"] != refresh_tok

    # Using old refresh token again returns 401
    old_again = client.post(
        "/api/v1/admin/auth/refresh",
        json={"refresh_token": refresh_tok},
    )
    assert old_again.status_code == 401


def test_revoked_refresh_returns_401(client: TestClient, db: Session, active_admin: AdminUser):
    """Revoked refresh token returns 401."""
    login_resp = client.post(
        "/api/v1/admin/auth/login",
        json={"email": "admin@datox.com", "password": "correct_password"},
    )
    refresh_tok = login_resp.json()["refresh_token"]

    from app.admin_auth.security import decode_admin_token

    payload = decode_admin_token(refresh_tok)
    jti_hash = get_jti_hash_for_storage(payload["jti"])
    rec = db.query(AdminRefreshToken).filter(AdminRefreshToken.jti_hash == jti_hash).first()
    assert rec
    rec.revoked_at = datetime.now(timezone.utc)
    db.commit()

    resp = client.post(
        "/api/v1/admin/auth/refresh",
        json={"refresh_token": refresh_tok},
    )
    assert resp.status_code == 401


def test_expired_refresh_returns_401(client: TestClient, active_admin: AdminUser):
    """Expired refresh token returns 401."""
    from app.core.config import settings

    now = datetime.now(timezone.utc)
    past = now - timedelta(hours=1)
    payload = {
        "sub": str(active_admin.id),
        "role": active_admin.role,
        "token_type": "refresh",
        "iss": "datox-admin",
        "aud": "datox-admin-dashboard",
        "iat": int(past.timestamp()),
        "exp": int(past.timestamp()),
        "jti": str(uuid.uuid4()),
    }
    secret = getattr(settings, "ADMIN_JWT_SECRET", "") or "change-me"
    expired_token = jwt.encode(payload, secret, algorithm="HS256")

    resp = client.post(
        "/api/v1/admin/auth/refresh",
        json={"refresh_token": expired_token},
    )
    assert resp.status_code == 401


def test_disabled_admin_refresh_returns_403(
    client: TestClient, db: Session, inactive_admin: AdminUser
):
    """Refresh with valid token but disabled admin returns 403."""
    # Login as inactive admin would fail. We need a valid refresh token for a disabled admin.
    # Create token manually: create refresh token, store it, then deactivate admin.
    admin = inactive_admin
    token_str, jti_hash, expires_at = create_admin_refresh_token(admin.id, admin.role)
    from app.admin_auth.repo import store_refresh_token

    store_refresh_token(db, admin.id, jti_hash, expires_at)
    db.commit()

    resp = client.post(
        "/api/v1/admin/auth/refresh",
        json={"refresh_token": token_str},
    )
    assert resp.status_code == 403
