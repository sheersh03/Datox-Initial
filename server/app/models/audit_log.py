"""Audit log model for tracking admin actions."""

import uuid

import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base


class AuditLog(Base):
    """
    Immutable audit trail of admin actions.
    Uses JSONB for flexible metadata storage.
    """

    __tablename__ = "audit_logs"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
    )
    admin_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True),
        sa.ForeignKey("admin_users.id", ondelete="SET NULL"),
        nullable=True,
        index=True,
    )
    action: Mapped[str] = mapped_column(sa.String(100), nullable=False)
    entity_type: Mapped[str | None] = mapped_column(sa.String(50), nullable=True, index=True)
    entity_id: Mapped[str | None] = mapped_column(sa.String(36), nullable=True, index=True)
    metadata_: Mapped[dict | None] = mapped_column(
        "metadata",
        JSONB,
        nullable=True,
    )
    ip_address: Mapped[str | None] = mapped_column(sa.String(45), nullable=True)
    user_agent: Mapped[str | None] = mapped_column(sa.Text, nullable=True)
    created_at: Mapped[object] = mapped_column(
        sa.DateTime(timezone=True),
        server_default=sa.text("now()"),
    )

    admin: Mapped[object | None] = relationship(
        "AdminUser",
        back_populates="audit_logs",
        foreign_keys=[admin_id],
    )

    def __repr__(self) -> str:
        return f"<AuditLog(id={self.id}, action={self.action}, entity_type={self.entity_type})>"
