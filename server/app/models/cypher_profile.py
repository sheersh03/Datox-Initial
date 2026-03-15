"""Cypher profile - anonymous identity for Cypher Mode."""

import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column
from app.db.base import Base


class CypherProfile(Base):
    """Anonymous profile for Cypher Mode. No real identity data."""

    __tablename__ = "cypher_profiles"

    user_id: Mapped[str] = mapped_column(
        sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    avatar_id: Mapped[str] = mapped_column(sa.String, nullable=False)
    anonymous_username: Mapped[str] = mapped_column(sa.String, nullable=False, index=True)
    interest_tags: Mapped[list] = mapped_column(
        JSONB, server_default=sa.text("'[]'::jsonb"), nullable=False
    )
    fantasy_keywords: Mapped[list] = mapped_column(
        JSONB, server_default=sa.text("'[]'::jsonb"), nullable=False
    )
    headline: Mapped[str | None] = mapped_column(sa.String, nullable=True)
    communication_preferences: Mapped[str | None] = mapped_column(sa.String, nullable=True)
    boundaries: Mapped[str | None] = mapped_column(sa.String, nullable=True)
    mood: Mapped[str | None] = mapped_column(sa.String, nullable=True)
    curiosity_level: Mapped[str | None] = mapped_column(sa.String, nullable=True)
    discovery_visible: Mapped[bool] = mapped_column(sa.Boolean, server_default=sa.text("true"))
    created_at: Mapped[object] = mapped_column(
        sa.DateTime(timezone=True), server_default=sa.text("now()")
    )
    updated_at: Mapped[object] = mapped_column(
        sa.DateTime(timezone=True),
        server_default=sa.func.now(),
        onupdate=sa.func.now(),
    )
