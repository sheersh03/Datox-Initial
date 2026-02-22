import sqlalchemy as sa
from sqlalchemy.orm import Mapped, mapped_column
from app.db.base import Base

class Message(Base):
    __tablename__ = "messages"
    id: Mapped[str] = mapped_column(sa.String, primary_key=True)
    match_id: Mapped[str] = mapped_column(sa.String, sa.ForeignKey("matches.id", ondelete="CASCADE"), index=True)
    sender_id: Mapped[str] = mapped_column(sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), index=True)
    type: Mapped[str] = mapped_column(sa.String, server_default="text")
    content: Mapped[str] = mapped_column(sa.String, nullable=False)
    created_at: Mapped[object] = mapped_column(sa.DateTime(timezone=True), server_default=sa.text("now()"))
