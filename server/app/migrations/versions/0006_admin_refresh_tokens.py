"""Add admin_refresh_tokens table for JWT refresh token persistence."""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import UUID

revision = "0006_admin_refresh_tokens"
down_revision = "0005_admin_dashboard_phase1"
branch_labels = None
depends_on = None


def upgrade():
    op.create_table(
        "admin_refresh_tokens",
        sa.Column("id", UUID(as_uuid=True), primary_key=True),
        sa.Column("admin_id", UUID(as_uuid=True), sa.ForeignKey("admin_users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("jti_hash", sa.String(64), nullable=False),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("revoked_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()")),
    )
    op.create_index("ix_admin_refresh_tokens_admin_id", "admin_refresh_tokens", ["admin_id"])
    op.create_index("ix_admin_refresh_tokens_jti_hash", "admin_refresh_tokens", ["jti_hash"])


def downgrade():
    op.drop_index("ix_admin_refresh_tokens_jti_hash", "admin_refresh_tokens")
    op.drop_index("ix_admin_refresh_tokens_admin_id", "admin_refresh_tokens")
    op.drop_table("admin_refresh_tokens")
