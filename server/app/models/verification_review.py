"""Verification review model for selfie verification workflow."""

import uuid

import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class VerificationReview(Base):
    """
    Tracks verification review workflow. user_id references users.id (String).
    status: pending | approved | rejected
    """

    __tablename__ = "verification_reviews"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
    )
    user_id: Mapped[str] = mapped_column(
        sa.String,
        sa.ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    selfie_s3_key: Mapped[str] = mapped_column(sa.Text, nullable=False)
    status: Mapped[str] = mapped_column(
        sa.String(20),
        server_default=sa.text("'pending'"),
        index=True,
    )
    reviewed_by: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True),
        sa.ForeignKey("admin_users.id", ondelete="SET NULL"),
        nullable=True,
    )
    reviewed_at: Mapped[object | None] = mapped_column(
        sa.DateTime(timezone=True),
        nullable=True,
    )
    rejection_reason: Mapped[str | None] = mapped_column(sa.Text, nullable=True)
    created_at: Mapped[object] = mapped_column(
        sa.DateTime(timezone=True),
        server_default=sa.text("now()"),
    )

    def __repr__(self) -> str:
        return f"<VerificationReview(id={self.id}, user_id={self.user_id}, status={self.status})>"
