"""Admin Dashboard Phase 1: new tables and safe column additions.

Creates: admin_users, audit_logs, ban_history, verification_reviews, subscription_events.
Modifies: users (verification_status, subscription_tier, profile_completed),
         reports (assigned_to, resolution_note, resolved_at, indexes).
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import JSONB, UUID

revision = "0005_admin_dashboard_phase1"
down_revision = "0004_addon_entitlements"
branch_labels = None
depends_on = None


def upgrade():
    # --- Phase 1: New tables (admin_users first; others FK to it) ---

    op.create_table(
        "admin_users",
        sa.Column("id", UUID(as_uuid=True), primary_key=True),
        sa.Column("email", sa.String(255), nullable=False),
        sa.Column("password_hash", sa.Text(), nullable=False),
        sa.Column("role", sa.String(50), nullable=False),
        sa.Column("is_active", sa.Boolean(), server_default=sa.text("true")),
        sa.Column("last_login_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("now()")),
    )
    op.create_index("ix_admin_users_email", "admin_users", ["email"], unique=True)

    op.create_table(
        "audit_logs",
        sa.Column("id", UUID(as_uuid=True), primary_key=True),
        sa.Column("admin_id", UUID(as_uuid=True), sa.ForeignKey("admin_users.id", ondelete="SET NULL"), nullable=True),
        sa.Column("action", sa.String(100), nullable=False),
        sa.Column("entity_type", sa.String(50), nullable=True),
        sa.Column("entity_id", sa.String(36), nullable=True),
        sa.Column("metadata", JSONB, nullable=True),
        sa.Column("ip_address", sa.String(45), nullable=True),
        sa.Column("user_agent", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()")),
    )
    op.create_index("ix_audit_logs_admin_id", "audit_logs", ["admin_id"])
    op.create_index("ix_audit_logs_entity_type", "audit_logs", ["entity_type"])
    op.create_index("ix_audit_logs_entity_id", "audit_logs", ["entity_id"])
    op.create_index("ix_audit_logs_created_at", "audit_logs", ["created_at"])

    op.create_table(
        "ban_history",
        sa.Column("id", UUID(as_uuid=True), primary_key=True),
        sa.Column("user_id", sa.String(), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("banned_by", UUID(as_uuid=True), sa.ForeignKey("admin_users.id", ondelete="SET NULL"), nullable=True),
        sa.Column("reason", sa.Text(), nullable=False),
        sa.Column("ban_type", sa.String(20), server_default=sa.text("'permanent'")),
        sa.Column("ban_until", sa.DateTime(timezone=True), nullable=True),
        sa.Column("is_active", sa.Boolean(), server_default=sa.text("true")),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()")),
        sa.Column("lifted_at", sa.DateTime(timezone=True), nullable=True),
    )
    op.create_index("ix_ban_history_user_id", "ban_history", ["user_id"])
    op.create_index("ix_ban_history_is_active", "ban_history", ["is_active"])

    op.create_table(
        "verification_reviews",
        sa.Column("id", UUID(as_uuid=True), primary_key=True),
        sa.Column("user_id", sa.String(), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("selfie_s3_key", sa.Text(), nullable=False),
        sa.Column("status", sa.String(20), server_default=sa.text("'pending'")),
        sa.Column("reviewed_by", UUID(as_uuid=True), sa.ForeignKey("admin_users.id", ondelete="SET NULL"), nullable=True),
        sa.Column("reviewed_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("rejection_reason", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()")),
    )
    op.create_index("ix_verification_reviews_user_id", "verification_reviews", ["user_id"])
    op.create_index("ix_verification_reviews_status", "verification_reviews", ["status"])

    op.create_table(
        "subscription_events",
        sa.Column("id", UUID(as_uuid=True), primary_key=True),
        sa.Column("user_id", sa.String(), sa.ForeignKey("users.id", ondelete="SET NULL"), nullable=True),
        sa.Column("event_type", sa.String(100), nullable=False),
        sa.Column("product_id", sa.String(100), nullable=True),
        sa.Column("amount", sa.Numeric(10, 2), nullable=True),
        sa.Column("currency", sa.String(10), nullable=True),
        sa.Column("raw_payload", JSONB, nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()")),
    )
    op.create_index("ix_subscription_events_user_id", "subscription_events", ["user_id"])
    op.create_index("ix_subscription_events_event_type", "subscription_events", ["event_type"])
    op.create_index("ix_subscription_events_created_at", "subscription_events", ["created_at"])

    # --- Phase 2: Modify existing tables ---

    # users: add columns (is_banned already exists)
    op.add_column(
        "users",
        sa.Column("verification_status", sa.String(20), server_default=sa.text("'unverified'")),
    )
    op.add_column(
        "users",
        sa.Column("subscription_tier", sa.String(50), nullable=True),
    )
    op.add_column(
        "users",
        sa.Column("profile_completed", sa.Boolean(), server_default=sa.text("false")),
    )

    # reports: add columns (status already exists)
    op.add_column(
        "reports",
        sa.Column("assigned_to", UUID(as_uuid=True), sa.ForeignKey("admin_users.id", ondelete="SET NULL"), nullable=True),
    )
    op.add_column(
        "reports",
        sa.Column("resolution_note", sa.Text(), nullable=True),
    )
    op.add_column(
        "reports",
        sa.Column("resolved_at", sa.DateTime(timezone=True), nullable=True),
    )
    op.create_index("ix_reports_status", "reports", ["status"])
    op.create_index("ix_reports_assigned_to", "reports", ["assigned_to"])


def downgrade():
    # --- Phase 2: Revert users and reports ---

    op.drop_index("ix_reports_assigned_to", "reports")
    op.drop_index("ix_reports_status", "reports")
    op.drop_column("reports", "resolved_at")
    op.drop_column("reports", "resolution_note")
    op.drop_column("reports", "assigned_to")

    op.drop_column("users", "profile_completed")
    op.drop_column("users", "subscription_tier")
    op.drop_column("users", "verification_status")

    # --- Phase 1: Drop new tables (reverse order of FKs) ---

    op.drop_table("subscription_events")
    op.drop_table("verification_reviews")
    op.drop_table("ban_history")
    op.drop_table("audit_logs")
    op.drop_index("ix_admin_users_email", "admin_users")
    op.drop_table("admin_users")
