import sqlalchemy as sa
from sqlalchemy.orm import Mapped, mapped_column
from app.db.base import Base

class Report(Base):
    __tablename__ = "reports"
    id: Mapped[str] = mapped_column(sa.String, primary_key=True)
    reporter_id: Mapped[str] = mapped_column(sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), index=True)
    reported_id: Mapped[str] = mapped_column(sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), index=True)
    reason: Mapped[str] = mapped_column(sa.String, nullable=False)
    details: Mapped[str | None] = mapped_column(sa.String, nullable=True)
    status: Mapped[str] = mapped_column(sa.String, server_default="open")
    created_at: Mapped[object] = mapped_column(sa.DateTime(timezone=True), server_default=sa.text("now()"))

class Block(Base):
    __tablename__ = "blocks"
    id: Mapped[str] = mapped_column(sa.String, primary_key=True)
    blocker_id: Mapped[str] = mapped_column(sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), index=True)
    blocked_id: Mapped[str] = mapped_column(sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), index=True)
    created_at: Mapped[object] = mapped_column(sa.DateTime(timezone=True), server_default=sa.text("now()"))
