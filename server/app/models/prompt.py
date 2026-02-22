import sqlalchemy as sa
from sqlalchemy.orm import Mapped, mapped_column
from app.db.base import Base

class Prompt(Base):
    __tablename__ = "prompts"
    id: Mapped[str] = mapped_column(sa.String, primary_key=True)
    user_id: Mapped[str] = mapped_column(sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), index=True)
    question: Mapped[str] = mapped_column(sa.String, nullable=False)
    answer: Mapped[str] = mapped_column(sa.String, nullable=False)
    order: Mapped[int] = mapped_column(sa.Integer, server_default="0")
    created_at: Mapped[object] = mapped_column(sa.DateTime(timezone=True), server_default=sa.text("now()"))
