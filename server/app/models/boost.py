import sqlalchemy as sa
from sqlalchemy.orm import Mapped, mapped_column
from app.db.base import Base

class Boost(Base):
    __tablename__ = "boosts"
    id: Mapped[str] = mapped_column(sa.String, primary_key=True)
    user_id: Mapped[str] = mapped_column(sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), index=True)
    available_count: Mapped[int] = mapped_column(sa.Integer, server_default="0")
    used_count: Mapped[int] = mapped_column(sa.Integer, server_default="0")
    week_key: Mapped[str] = mapped_column(sa.String, index=True)
