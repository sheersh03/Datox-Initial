import sqlalchemy as sa
from sqlalchemy.orm import Mapped, mapped_column
from app.db.base import Base

class Profile(Base):
    __tablename__ = "profiles"
    user_id: Mapped[str] = mapped_column(sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), primary_key=True)
    name: Mapped[str] = mapped_column(sa.String, nullable=False)
    birth_year: Mapped[int] = mapped_column(sa.Integer, nullable=False)
    gender: Mapped[str] = mapped_column(sa.String, nullable=False)
    intent: Mapped[str] = mapped_column(sa.String, nullable=False)
    bio: Mapped[str | None] = mapped_column(sa.String, nullable=True)
    city: Mapped[str | None] = mapped_column(sa.String, nullable=True)

    lat: Mapped[float | None] = mapped_column(sa.Float, nullable=True)
    lng: Mapped[float | None] = mapped_column(sa.Float, nullable=True)
    approx_lat: Mapped[float | None] = mapped_column(sa.Float, nullable=True)
    approx_lng: Mapped[float | None] = mapped_column(sa.Float, nullable=True)

    age_min: Mapped[int] = mapped_column(sa.Integer, server_default="18")
    age_max: Mapped[int] = mapped_column(sa.Integer, server_default="40")
    distance_km: Mapped[int] = mapped_column(sa.Integer, server_default="20")
    pref_gender: Mapped[str | None] = mapped_column(sa.String, nullable=True)

    verification_status: Mapped[str] = mapped_column(sa.String, server_default="unverified")
    verification_selfie_key: Mapped[str | None] = mapped_column(sa.String, nullable=True)

    updated_at: Mapped[object] = mapped_column(sa.DateTime(timezone=True), server_default=sa.text("now()"))
