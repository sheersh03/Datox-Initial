"""Cypher message - chat within Cypher Match (anonymous until reveal)."""

import sqlalchemy as sa
from sqlalchemy.orm import Mapped, mapped_column
from app.db.base import Base


class CypherMessage(Base):
    """Message in Cypher Chat. Sender identity not exposed until reveal."""

    __tablename__ = "cypher_messages"

    id: Mapped[str] = mapped_column(sa.String, primary_key=True)
    cypher_match_id: Mapped[str] = mapped_column(
        sa.String, sa.ForeignKey("cypher_matches.id", ondelete="CASCADE"), index=True
    )
    sender_id: Mapped[str] = mapped_column(
        sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    content: Mapped[str] = mapped_column(sa.String, nullable=False)
    created_at: Mapped[object] = mapped_column(
        sa.DateTime(timezone=True), server_default=sa.text("now()")
    )
