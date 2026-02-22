import sqlalchemy as sa
from sqlalchemy.orm import Mapped, mapped_column
from app.db.base import Base

class Photo(Base):
    __tablename__ = "photos"
    id: Mapped[str] = mapped_column(sa.String, primary_key=True)
    user_id: Mapped[str] = mapped_column(sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), index=True)
    s3_key: Mapped[str] = mapped_column(sa.String, nullable=False)
    is_primary: Mapped[bool] = mapped_column(sa.Boolean, server_default=sa.text("false"))
    created_at: Mapped[object] = mapped_column(sa.DateTime(timezone=True), server_default=sa.text("now()"))
