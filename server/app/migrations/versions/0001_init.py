from alembic import op
import sqlalchemy as sa

revision = "0001_init"
down_revision = None
branch_labels = None
depends_on = None

def upgrade():
    op.create_table(
    "users",
    sa.Column("id", sa.String(), primary_key=True),
    sa.Column("phone", sa.String(), nullable=False),
    sa.Column("email", sa.String(), nullable=True),
    sa.Column("is_verified", sa.Boolean(), nullable=False, server_default="false"),
    sa.Column("is_banned", sa.Boolean(), nullable=False, server_default="false"),
    sa.Column("ban_reason", sa.String(), nullable=True),
    sa.Column(
        "created_at",
        sa.DateTime(),
        nullable=False,
        server_default=sa.text("now()"),
    ),
)





    op.create_table(
        "profiles",
        sa.Column("user_id", sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), primary_key=True),
        sa.Column("name", sa.String, nullable=False),
        sa.Column("birth_year", sa.Integer, nullable=False),
        sa.Column("gender", sa.String, nullable=False),
        sa.Column("intent", sa.String, nullable=False),  # dating/friends/marriage
        sa.Column("bio", sa.String, nullable=True),
        sa.Column("city", sa.String, nullable=True),
        sa.Column("lat", sa.Float, nullable=True),
        sa.Column("lng", sa.Float, nullable=True),
        sa.Column("approx_lat", sa.Float, nullable=True),
        sa.Column("approx_lng", sa.Float, nullable=True),
        sa.Column("age_min", sa.Integer, server_default="18"),
        sa.Column("age_max", sa.Integer, server_default="40"),
        sa.Column("distance_km", sa.Integer, server_default="20"),
        sa.Column("pref_gender", sa.String, nullable=True),  # "male,female,nonbinary"
        sa.Column("verification_status", sa.String, server_default="unverified"),  # unverified/pending/verified/rejected
        sa.Column("verification_selfie_key", sa.String, nullable=True),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("now()")),
    )

    op.create_table(
        "photos",
        sa.Column("id", sa.String, primary_key=True),
        sa.Column("user_id", sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), index=True),
        sa.Column("s3_key", sa.String, nullable=False),
        sa.Column("is_primary", sa.Boolean, server_default=sa.text("false")),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()")),
    )

    op.create_table(
        "prompts",
        sa.Column("id", sa.String, primary_key=True),
        sa.Column("user_id", sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), index=True),
        sa.Column("question", sa.String, nullable=False),
        sa.Column("answer", sa.String, nullable=False),
        sa.Column("order", sa.Integer, server_default="0"),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()")),
    )

    op.create_table(
        "likes",
        sa.Column("id", sa.String, primary_key=True),
        sa.Column("from_user_id", sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), index=True),
        sa.Column("to_user_id", sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), index=True),
        sa.Column("is_like", sa.Boolean, nullable=False),  # True=like, False=pass
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()")),
        sa.UniqueConstraint("from_user_id", "to_user_id", name="uq_like_once"),
    )

    op.create_table(
        "matches",
        sa.Column("id", sa.String, primary_key=True),
        sa.Column("user_a", sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), index=True),
        sa.Column("user_b", sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), index=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()")),
        sa.UniqueConstraint("user_a", "user_b", name="uq_match_pair"),
    )

    op.create_table(
        "messages",
        sa.Column("id", sa.String, primary_key=True),
        sa.Column("match_id", sa.String, sa.ForeignKey("matches.id", ondelete="CASCADE"), index=True),
        sa.Column("sender_id", sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), index=True),
        sa.Column("type", sa.String, server_default="text"),
        sa.Column("content", sa.String, nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()")),
    )

    op.create_table(
        "reports",
        sa.Column("id", sa.String, primary_key=True),
        sa.Column("reporter_id", sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), index=True),
        sa.Column("reported_id", sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), index=True),
        sa.Column("reason", sa.String, nullable=False),
        sa.Column("details", sa.String, nullable=True),
        sa.Column("status", sa.String, server_default="open"),  # open/reviewed/actioned
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()")),
    )

    op.create_table(
        "blocks",
        sa.Column("id", sa.String, primary_key=True),
        sa.Column("blocker_id", sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), index=True),
        sa.Column("blocked_id", sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), index=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()")),
        sa.UniqueConstraint("blocker_id", "blocked_id", name="uq_block_once"),
    )

    op.create_table(
        "subscriptions",
        sa.Column("id", sa.String, primary_key=True),
        sa.Column("user_id", sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), unique=True),
        sa.Column("tier", sa.String, server_default="free"),  # free/lite/plus
        sa.Column("entitlements_json", sa.Text, nullable=True),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("now()")),
    )

    op.create_table(
        "boosts",
        sa.Column("id", sa.String, primary_key=True),
        sa.Column("user_id", sa.String, sa.ForeignKey("users.id", ondelete="CASCADE"), index=True),
        sa.Column("available_count", sa.Integer, server_default="0"),
        sa.Column("used_count", sa.Integer, server_default="0"),
        sa.Column("week_key", sa.String, index=True),  # e.g. 2026-W06
        sa.UniqueConstraint("user_id", "week_key", name="uq_boost_week"),
    )

def downgrade():
    for t in ["boosts","subscriptions","blocks","reports","messages","matches","likes","prompts","photos","profiles","users"]:
        op.drop_table(t)
