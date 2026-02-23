import sqlalchemy as sa
from sqlalchemy.orm import Mapped, mapped_column
from app.db.base import Base

class Subscription(Base):
    __tablename__ = "subscriptions"
    id: Mapped[str] = mapped_column(sa.String, primary_key=True)
    user_id: Mapped[str] = mapped_column(sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), unique=True)
    tier: Mapped[str] = mapped_column(sa.String, server_default="free")  # free/lite/plus
    entitlements_json: Mapped[str | None] = mapped_column(sa.Text, nullable=True)
    expires_at: Mapped[object | None] = mapped_column(sa.DateTime(timezone=True), nullable=True)
    updated_at: Mapped[object] = mapped_column(
        sa.DateTime(timezone=True),
        server_default=sa.func.now(),
        onupdate=sa.func.now(),
    )
