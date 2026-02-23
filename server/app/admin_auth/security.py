"""Admin auth security: password hashing (bcrypt) and JWT helpers."""

import hashlib
import uuid
from datetime import datetime, timedelta, timezone

import bcrypt
from jose import jwt, JWTError

from app.core.config import settings

ALG = "HS256"
ADMIN_ISSUER = "datox-admin"
ADMIN_AUDIENCE = "datox-admin-dashboard"
LEEWAY_SECONDS = 30


def verify_password(plain: str, hashed: str) -> bool:
    """Constant-time password verification via bcrypt.checkpw."""
    try:
        return bcrypt.checkpw(plain.encode("utf-8"), hashed.encode("utf-8"))
    except (ValueError, TypeError):
        return False


def hash_password(plain: str) -> str:
    """Hash password for storage. Never log the plain password."""
    return bcrypt.hashpw(plain.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")


def _jti_hash(jti: str) -> str:
    """Hash JTI with server salt so DB leak doesn't expose token IDs."""
    salt = getattr(settings, "ADMIN_REFRESH_TOKEN_JTI_SALT", "") or "fallback-salt"
    data = f"{jti}:{salt}".encode("utf-8")
    return hashlib.sha256(data).hexdigest()


def create_admin_access_token(admin_id: uuid.UUID, role: str) -> tuple[str, int]:
    """Create short-lived access token. Returns (token, expires_in_seconds)."""
    ttl = getattr(settings, "ADMIN_ACCESS_TOKEN_TTL_SECONDS", 900)
    now = datetime.now(timezone.utc)
    exp = now + timedelta(seconds=ttl)
    payload = {
        "sub": str(admin_id),
        "role": role,
        "token_type": "access",
        "iss": ADMIN_ISSUER,
        "aud": ADMIN_AUDIENCE,
        "iat": int(now.timestamp()),
        "exp": int(exp.timestamp()),
        "jti": str(uuid.uuid4()),
    }
    secret = getattr(settings, "ADMIN_JWT_SECRET", "") or "change-me"
    token = jwt.encode(payload, secret, algorithm=ALG)
    return token, ttl


def create_admin_refresh_token(admin_id: uuid.UUID, role: str) -> tuple[str, str, datetime]:
    """
    Create long-lived refresh token. Returns (token, jti_hash, expires_at).
    Caller must persist jti_hash in admin_refresh_tokens.
    """
    ttl = getattr(settings, "ADMIN_REFRESH_TOKEN_TTL_SECONDS", 604800)
    now = datetime.now(timezone.utc)
    exp = now + timedelta(seconds=ttl)
    jti = str(uuid.uuid4())
    payload = {
        "sub": str(admin_id),
        "role": role,
        "token_type": "refresh",
        "iss": ADMIN_ISSUER,
        "aud": ADMIN_AUDIENCE,
        "iat": int(now.timestamp()),
        "exp": int(exp.timestamp()),
        "jti": jti,
    }
    secret = getattr(settings, "ADMIN_JWT_SECRET", "") or "change-me"
    token = jwt.encode(payload, secret, algorithm=ALG)
    jti_hash = _jti_hash(jti)
    return token, jti_hash, exp


def decode_admin_token(token: str) -> dict | None:
    """Decode and validate admin JWT. Returns payload or None."""
    try:
        secret = getattr(settings, "ADMIN_JWT_SECRET", "") or "change-me"
        payload = jwt.decode(
            token,
            secret,
            algorithms=[ALG],
            audience=ADMIN_AUDIENCE,
            issuer=ADMIN_ISSUER,
            leeway=LEEWAY_SECONDS,
        )
        return payload
    except JWTError:
        return None


def get_jti_hash_for_storage(jti: str) -> str:
    """Compute jti_hash for DB storage. Used when persisting refresh token."""
    return _jti_hash(jti)
