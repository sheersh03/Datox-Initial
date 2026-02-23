"""Admin user model for dashboard authentication and authorization."""

import uuid

import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base


class AdminUser(Base):
    """
    Admin users for dashboard access.
    Roles: super_admin | moderator | support | analyst
    """

    __tablename__ = "admin_users"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
    )
    email: Mapped[str] = mapped_column(sa.String(255), unique=True, nullable=False, index=True)
    password_hash: Mapped[str] = mapped_column(sa.Text, nullable=False)
    role: Mapped[str] = mapped_column(sa.String(50), nullable=False)
    is_active: Mapped[bool] = mapped_column(
        sa.Boolean,
        server_default=sa.text("true"),
    )
    last_login_at: Mapped[object | None] = mapped_column(
        sa.DateTime(timezone=True),
        nullable=True,
    )
    created_at: Mapped[object] = mapped_column(
        sa.DateTime(timezone=True),
        server_default=sa.text("now()"),
    )
    updated_at: Mapped[object] = mapped_column(
        sa.DateTime(timezone=True),
        server_default=sa.text("now()"),
    )

    # Relationships (lazy-loaded to avoid N+1)
    audit_logs: Mapped[list] = relationship(
        "AuditLog",
        back_populates="admin",
        foreign_keys="AuditLog.admin_id",
        lazy="selectin",
    )

    def __repr__(self) -> str:
        return f"<AdminUser(id={self.id}, email={self.email}, role={self.role})>"
