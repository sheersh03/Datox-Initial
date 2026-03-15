"""Cypher Mode: cypher_profiles, cypher_reactions, cypher_matches, cypher_messages, cypher_reveal_requests."""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import JSONB

revision = "0007_cypher_mode"
down_revision = "0006_admin_refresh_tokens"
branch_labels = None
depends_on = None


def upgrade():
    op.create_table(
        "cypher_profiles",
        sa.Column("user_id", sa.String(), sa.ForeignKey("users.id", ondelete="CASCADE"), primary_key=True),
        sa.Column("avatar_id", sa.String(), nullable=False),
        sa.Column("anonymous_username", sa.String(), nullable=False),
        sa.Column("interest_tags", JSONB, server_default=sa.text("'[]'::jsonb"), nullable=False),
        sa.Column("fantasy_keywords", JSONB, server_default=sa.text("'[]'::jsonb"), nullable=False),
        sa.Column("headline", sa.String(), nullable=True),
        sa.Column("communication_preferences", sa.String(), nullable=True),
        sa.Column("boundaries", sa.String(), nullable=True),
        sa.Column("mood", sa.String(), nullable=True),
        sa.Column("curiosity_level", sa.String(), nullable=True),
        sa.Column("discovery_visible", sa.Boolean(), server_default=sa.text("true")),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("now()")),
    )
    op.create_index("ix_cypher_profiles_anonymous_username", "cypher_profiles", ["anonymous_username"])

    op.create_table(
        "cypher_reactions",
        sa.Column("id", sa.String(), primary_key=True),
        sa.Column("from_user_id", sa.String(), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("to_user_id", sa.String(), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("is_like", sa.Boolean(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()")),
        sa.UniqueConstraint("from_user_id", "to_user_id", name="uq_cypher_reaction_once"),
    )
    op.create_index("ix_cypher_reactions_from_user_id", "cypher_reactions", ["from_user_id"])
    op.create_index("ix_cypher_reactions_to_user_id", "cypher_reactions", ["to_user_id"])

    op.create_table(
        "cypher_matches",
        sa.Column("id", sa.String(), primary_key=True),
        sa.Column("user_a", sa.String(), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("user_b", sa.String(), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("reveal_status", sa.String(), server_default=sa.text("'none'")),
        sa.Column("revealed_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()")),
        sa.UniqueConstraint("user_a", "user_b", name="uq_cypher_match_pair"),
    )
    op.create_index("ix_cypher_matches_user_a", "cypher_matches", ["user_a"])
    op.create_index("ix_cypher_matches_user_b", "cypher_matches", ["user_b"])

    op.create_table(
        "cypher_messages",
        sa.Column("id", sa.String(), primary_key=True),
        sa.Column("cypher_match_id", sa.String(), sa.ForeignKey("cypher_matches.id", ondelete="CASCADE"), nullable=False),
        sa.Column("sender_id", sa.String(), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("content", sa.String(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()")),
    )
    op.create_index("ix_cypher_messages_cypher_match_id", "cypher_messages", ["cypher_match_id"])
    op.create_index("ix_cypher_messages_sender_id", "cypher_messages", ["sender_id"])

    op.create_table(
        "cypher_reveal_requests",
        sa.Column("id", sa.String(), primary_key=True),
        sa.Column("cypher_match_id", sa.String(), sa.ForeignKey("cypher_matches.id", ondelete="CASCADE"), nullable=False),
        sa.Column("requested_by_user_id", sa.String(), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("requested_at", sa.DateTime(timezone=True), server_default=sa.text("now()")),
        sa.Column("responded_by_user_id", sa.String(), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=True),
        sa.Column("response", sa.String(), nullable=True),
        sa.Column("responded_at", sa.DateTime(timezone=True), nullable=True),
    )
    op.create_index("ix_cypher_reveal_requests_cypher_match_id", "cypher_reveal_requests", ["cypher_match_id"])
    op.create_index("ix_cypher_reveal_requests_requested_by", "cypher_reveal_requests", ["requested_by_user_id"])


def downgrade():
    op.drop_index("ix_cypher_reveal_requests_requested_by", "cypher_reveal_requests")
    op.drop_index("ix_cypher_reveal_requests_cypher_match_id", "cypher_reveal_requests")
    op.drop_table("cypher_reveal_requests")
    op.drop_index("ix_cypher_messages_sender_id", "cypher_messages")
    op.drop_index("ix_cypher_messages_cypher_match_id", "cypher_messages")
    op.drop_table("cypher_messages")
    op.drop_index("ix_cypher_matches_user_b", "cypher_matches")
    op.drop_index("ix_cypher_matches_user_a", "cypher_matches")
    op.drop_table("cypher_matches")
    op.drop_index("ix_cypher_reactions_to_user_id", "cypher_reactions")
    op.drop_index("ix_cypher_reactions_from_user_id", "cypher_reactions")
    op.drop_table("cypher_reactions")
    op.drop_index("ix_cypher_profiles_anonymous_username", "cypher_profiles")
    op.drop_table("cypher_profiles")
