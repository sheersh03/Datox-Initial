"""Admin auth API routes."""

from fastapi import APIRouter, Depends, Request
from sqlalchemy.orm import Session

from app.admin_auth.schemas import (
    AdminLoginRequest,
    AdminLoginResponse,
    RefreshRequest,
    TokenResponse,
)
from app.admin_auth.service import admin_login, refresh_token
from app.api.deps import get_db

router = APIRouter(prefix="/auth", tags=["admin_auth"])


def _client_ip(request: Request) -> str | None:
    """Extract client IP, considering X-Forwarded-For."""
    forwarded = request.headers.get("X-Forwarded-For")
    if forwarded:
        return forwarded.split(",")[0].strip()
    return request.client.host if request.client else None


def _user_agent(request: Request) -> str | None:
    """Extract User-Agent header."""
    return request.headers.get("User-Agent")


@router.post("/login", response_model=AdminLoginResponse)
def login(
    req: AdminLoginRequest,
    request: Request,
    db: Session = Depends(get_db),
) -> AdminLoginResponse:
    """
    Admin login. Returns access and refresh tokens.
    - 401: Invalid credentials (wrong email or password)
    - 403: Admin disabled
    - 429: Too many attempts
    """
    return admin_login(
        db,
        email=req.email,
        password=req.password,
        ip_address=_client_ip(request),
        user_agent=_user_agent(request),
    )


@router.post("/refresh", response_model=TokenResponse)
def refresh(
    req: RefreshRequest,
    request: Request,
    db: Session = Depends(get_db),
) -> TokenResponse:
    """
    Refresh access token.
    Rotates refresh token (old one revoked, new one issued).
    - 401: Invalid refresh token
    - 403: Admin disabled
    - 429: Too many requests
    """
    return refresh_token(
        db,
        refresh_token_str=req.refresh_token,
        ip_address=_client_ip(request),
        user_agent=_user_agent(request),
    )
