"""Ban history model for tracking user bans."""

import uuid

import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class BanHistory(Base):
    """
    History of user bans. user_id references users.id (String).
    ON DELETE SET NULL for banned_by so admin deletion doesn't cascade.
    """

    __tablename__ = "ban_history"

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
    banned_by: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True),
        sa.ForeignKey("admin_users.id", ondelete="SET NULL"),
        nullable=True,
    )
    reason: Mapped[str] = mapped_column(sa.Text, nullable=False)
    ban_type: Mapped[str] = mapped_column(
        sa.String(20),
        server_default=sa.text("'permanent'"),
    )
    ban_until: Mapped[object | None] = mapped_column(
        sa.DateTime(timezone=True),
        nullable=True,
    )
    is_active: Mapped[bool] = mapped_column(
        sa.Boolean,
        server_default=sa.text("true"),
        index=True,
    )
    created_at: Mapped[object] = mapped_column(
        sa.DateTime(timezone=True),
        server_default=sa.text("now()"),
    )
    lifted_at: Mapped[object | None] = mapped_column(
        sa.DateTime(timezone=True),
        nullable=True,
    )

    def __repr__(self) -> str:
        return f"<BanHistory(id={self.id}, user_id={self.user_id}, is_active={self.is_active})>"
