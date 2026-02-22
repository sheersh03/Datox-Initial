import sqlalchemy as sa
from sqlalchemy.orm import Mapped, mapped_column
from app.db.base import Base

class Match(Base):
    __tablename__ = "matches"
    id: Mapped[str] = mapped_column(sa.String, primary_key=True)
    user_a: Mapped[str] = mapped_column(sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), index=True)
    user_b: Mapped[str] = mapped_column(sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), index=True)
    created_at: Mapped[object] = mapped_column(sa.DateTime(timezone=True), server_default=sa.text("now()"))
