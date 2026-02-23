import sqlalchemy as sa
from sqlalchemy.orm import Mapped, mapped_column
from app.db.base import Base


class User(Base):
    __tablename__ = "users"

    id: Mapped[str] = mapped_column(sa.String, primary_key=True)
    phone: Mapped[str] = mapped_column(sa.String, unique=True, index=True)
    email: Mapped[str | None] = mapped_column(sa.String, nullable=True)

    is_verified: Mapped[bool] = mapped_column(
        sa.Boolean, server_default=sa.text("false")
    )

    is_banned: Mapped[bool] = mapped_column(
        sa.Boolean, server_default=sa.text("false")
    )

    ban_reason: Mapped[str | None] = mapped_column(sa.String, nullable=True)

    # Admin dashboard Phase 1: denormalized for admin queries
    verification_status: Mapped[str] = mapped_column(
        sa.String(20),
        server_default=sa.text("'unverified'"),
    )
    subscription_tier: Mapped[str | None] = mapped_column(sa.String(50), nullable=True)
    profile_completed: Mapped[bool] = mapped_column(
        sa.Boolean,
        server_default=sa.text("false"),
    )

    created_at: Mapped[object] = mapped_column(
        sa.DateTime(timezone=True),
        server_default=sa.text("now()"),
    )
    updated_at: Mapped[object] = mapped_column(
        sa.DateTime(timezone=True),
        server_default=sa.func.now(),
        onupdate=sa.func.now(),
    )
