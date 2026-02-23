import sqlalchemy as sa
from sqlalchemy.orm import Mapped, mapped_column
from app.db.base import Base


class UserEntitlement(Base):
    __tablename__ = "user_entitlements"

    id: Mapped[str] = mapped_column(sa.String, primary_key=True)
    user_id: Mapped[str] = mapped_column(
        sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    addon_type: Mapped[str] = mapped_column(sa.String, index=True, nullable=False)
    remaining_count: Mapped[int] = mapped_column(sa.Integer, server_default="0")
    expires_at: Mapped[object] = mapped_column(sa.DateTime(timezone=True), nullable=True)
    is_active: Mapped[bool] = mapped_column(sa.Boolean, server_default=sa.text("true"))
    created_at: Mapped[object] = mapped_column(
        sa.DateTime(timezone=True),
        server_default=sa.func.now(),
    )


class AddonUsageLog(Base):
    __tablename__ = "addon_usage_logs"

    id: Mapped[str] = mapped_column(sa.String, primary_key=True)
    user_id: Mapped[str] = mapped_column(
        sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    addon_type: Mapped[str] = mapped_column(sa.String, index=True, nullable=False)
    used_at: Mapped[object] = mapped_column(
        sa.DateTime(timezone=True),
        server_default=sa.func.now(),
    )
    metadata_json: Mapped[str] = mapped_column(sa.Text, nullable=True)
