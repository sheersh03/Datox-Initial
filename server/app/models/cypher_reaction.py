"""Cypher reaction - like/pass in Cypher discovery."""

import sqlalchemy as sa
from sqlalchemy.orm import Mapped, mapped_column
from app.db.base import Base


class CypherReaction(Base):
    """Reaction from one Cypher user to another in discovery."""

    __tablename__ = "cypher_reactions"

    id: Mapped[str] = mapped_column(sa.String, primary_key=True)
    from_user_id: Mapped[str] = mapped_column(
        sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    to_user_id: Mapped[str] = mapped_column(
        sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    is_like: Mapped[bool] = mapped_column(sa.Boolean, nullable=False)
    created_at: Mapped[object] = mapped_column(
        sa.DateTime(timezone=True), server_default=sa.text("now()")
    )
