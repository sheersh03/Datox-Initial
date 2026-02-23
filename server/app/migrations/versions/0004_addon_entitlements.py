"""Add user_entitlements and addon_usage_logs tables."""

from alembic import op
import sqlalchemy as sa

revision = "0004_addon_entitlements"
down_revision = "0003_add_updated_at"
branch_labels = None
depends_on = None


def upgrade():
    op.create_table(
        "user_entitlements",
        sa.Column("id", sa.String(), primary_key=True),
        sa.Column("user_id", sa.String(), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True),
        sa.Column("addon_type", sa.String(), nullable=False, index=True),
        sa.Column("remaining_count", sa.Integer(), server_default="0"),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("is_active", sa.Boolean(), server_default=sa.text("true")),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()")),
    )

    op.create_table(
        "addon_usage_logs",
        sa.Column("id", sa.String(), primary_key=True),
        sa.Column("user_id", sa.String(), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True),
        sa.Column("addon_type", sa.String(), nullable=False, index=True),
        sa.Column("used_at", sa.DateTime(timezone=True), server_default=sa.text("now()")),
        sa.Column("metadata_json", sa.Text(), nullable=True),
    )


def downgrade():
    op.drop_table("addon_usage_logs")
    op.drop_table("user_entitlements")
