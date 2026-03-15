"""Cypher match - mutual interest in Cypher Mode."""

import sqlalchemy as sa
from sqlalchemy.orm import Mapped, mapped_column
from app.db.base import Base


class CypherMatch(Base):
    """Match between two Cypher users. Unlocks Cypher Chat."""

    __tablename__ = "cypher_matches"

    id: Mapped[str] = mapped_column(sa.String, primary_key=True)
    user_a: Mapped[str] = mapped_column(
        sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    user_b: Mapped[str] = mapped_column(
        sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    reveal_status: Mapped[str] = mapped_column(
        sa.String, server_default="none"
    )  # none, requested_a, requested_b, mutual
    revealed_at: Mapped[object | None] = mapped_column(sa.DateTime(timezone=True), nullable=True)
    created_at: Mapped[object] = mapped_column(
        sa.DateTime(timezone=True), server_default=sa.text("now()")
    )
