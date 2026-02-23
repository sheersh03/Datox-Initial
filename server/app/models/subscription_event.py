"""Subscription event model for payment/subscription webhook events."""

import uuid

import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class SubscriptionEvent(Base):
    """
    Immutable log of subscription/payment events.
    user_id nullable for events before user association.
    Uses JSONB for raw webhook payload storage.
    """

    __tablename__ = "subscription_events"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
    )
    user_id: Mapped[str | None] = mapped_column(
        sa.String,
        sa.ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True,
        index=True,
    )
    event_type: Mapped[str] = mapped_column(sa.String(100), nullable=False, index=True)
    product_id: Mapped[str | None] = mapped_column(sa.String(100), nullable=True)
    amount: Mapped[object | None] = mapped_column(sa.Numeric(10, 2), nullable=True)
    currency: Mapped[str | None] = mapped_column(sa.String(10), nullable=True)
    raw_payload: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    created_at: Mapped[object] = mapped_column(
        sa.DateTime(timezone=True),
        server_default=sa.text("now()"),
    )

    def __repr__(self) -> str:
        return f"<SubscriptionEvent(id={self.id}, event_type={self.event_type}, user_id={self.user_id})>"
