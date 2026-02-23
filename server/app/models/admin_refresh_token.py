"""Admin refresh token model for JWT refresh token persistence."""

import uuid

import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class AdminRefreshToken(Base):
    """
    Persisted refresh token JTIs (hashed) for revocation and validation.
    jti_hash = sha256(jti + ADMIN_REFRESH_TOKEN_JTI_SALT).
    """

    __tablename__ = "admin_refresh_tokens"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
    )
    admin_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        sa.ForeignKey("admin_users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    jti_hash: Mapped[str] = mapped_column(sa.String(64), nullable=False, index=True)
    expires_at: Mapped[object] = mapped_column(
        sa.DateTime(timezone=True),
        nullable=False,
    )
    revoked_at: Mapped[object | None] = mapped_column(
        sa.DateTime(timezone=True),
        nullable=True,
    )
    created_at: Mapped[object] = mapped_column(
        sa.DateTime(timezone=True),
        server_default=sa.text("now()"),
    )

    def __repr__(self) -> str:
        return f"<AdminRefreshToken(id={self.id}, admin_id={self.admin_id})>"
