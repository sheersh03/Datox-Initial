import sqlalchemy as sa
from sqlalchemy.orm import Mapped, mapped_column
from app.db.base import Base


class UserPasskey(Base):
    __tablename__ = "user_passkeys"

    id: Mapped[str] = mapped_column(sa.String, primary_key=True)
    user_id: Mapped[str] = mapped_column(
        sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    credential_id: Mapped[bytes] = mapped_column(sa.LargeBinary, nullable=False, unique=True)
    public_key: Mapped[bytes] = mapped_column(sa.LargeBinary, nullable=False)
    sign_count: Mapped[int] = mapped_column(sa.Integer, nullable=False, server_default=sa.text("0"))
    created_at: Mapped[object] = mapped_column(
        sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")
    )
