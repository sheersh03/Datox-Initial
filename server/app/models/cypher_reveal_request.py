"""Cypher reveal request - consent-based identity reveal."""

import sqlalchemy as sa
from sqlalchemy.orm import Mapped, mapped_column
from app.db.base import Base


class CypherRevealRequest(Base):
    """Reveal request and response. Both must accept for reveal."""

    __tablename__ = "cypher_reveal_requests"

    id: Mapped[str] = mapped_column(sa.String, primary_key=True)
    cypher_match_id: Mapped[str] = mapped_column(
        sa.String, sa.ForeignKey("cypher_matches.id", ondelete="CASCADE"), index=True
    )
    requested_by_user_id: Mapped[str] = mapped_column(
        sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    requested_at: Mapped[object] = mapped_column(
        sa.DateTime(timezone=True), server_default=sa.text("now()")
    )
    responded_by_user_id: Mapped[str | None] = mapped_column(
        sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=True
    )
    response: Mapped[str | None] = mapped_column(sa.String, nullable=True)  # accepted, declined
    responded_at: Mapped[object | None] = mapped_column(sa.DateTime(timezone=True), nullable=True)
