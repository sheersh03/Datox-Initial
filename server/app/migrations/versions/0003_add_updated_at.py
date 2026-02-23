"""Add updated_at to users; profiles.updated_at already exists, ORM onupdate handles updates."""

from alembic import op
import sqlalchemy as sa

revision = "0003_add_updated_at"
down_revision = "0002_user_passkeys"
branch_labels = None
depends_on = None


def upgrade():
    op.add_column(
        "users",
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("now()"),
        ),
    )


def downgrade():
    op.drop_column("users", "updated_at")
