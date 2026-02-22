from datetime import datetime, timedelta, timezone
from jose import jwt, JWTError
from fastapi import Header
from app.core.config import settings
from app.core.errors import api_error

ALG = "HS256"

def create_access_token(user_id: str) -> str:
    now = datetime.now(timezone.utc)
    exp = now + timedelta(minutes=settings.ACCESS_TOKEN_MINUTES)
    payload = {
        "sub": user_id,
        "iss": settings.JWT_ISSUER,
        "aud": settings.JWT_AUDIENCE,
        "iat": int(now.timestamp()),
        "exp": int(exp.timestamp()),
    }
    return jwt.encode(payload, settings.JWT_SECRET, algorithm=ALG)

def decode_token(token: str) -> str:
    try:
        payload = jwt.decode(
            token,
            settings.JWT_SECRET,
            algorithms=[ALG],
            audience=settings.JWT_AUDIENCE,
            issuer=settings.JWT_ISSUER,
        )
        return payload["sub"]
    except JWTError:
        api_error("AUTH_INVALID_TOKEN", "Invalid or expired token", 401)

def get_bearer_token(authorization: str | None) -> str:
    if not authorization or not authorization.startswith("Bearer "):
        api_error("AUTH_MISSING", "Missing Authorization header", 401)
    return authorization.split(" ", 1)[1].strip()

def auth_user_id(authorization: str | None = Header(default=None)) -> str:
    token = get_bearer_token(authorization)
    return decode_token(token)
