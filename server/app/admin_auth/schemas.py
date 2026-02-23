"""Pydantic schemas for admin auth API."""

from uuid import UUID

from pydantic import BaseModel, Field


class AdminLoginRequest(BaseModel):
    """Request body for POST /admin/auth/login."""

    email: str = Field(..., min_length=1, max_length=255, description="Admin email")
    password: str = Field(..., min_length=1, description="Admin password")


class AdminInfo(BaseModel):
    """Admin info returned in login response."""

    id: UUID
    email: str
    role: str
    is_active: bool


class AdminLoginResponse(BaseModel):
    """Response for successful admin login."""

    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int
    admin: AdminInfo


class RefreshRequest(BaseModel):
    """Request body for POST /admin/auth/refresh."""

    refresh_token: str = Field(..., min_length=1, description="Refresh token JWT")


class TokenResponse(BaseModel):
    """Response for successful token refresh."""

    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int
