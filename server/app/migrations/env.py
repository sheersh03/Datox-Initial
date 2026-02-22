from __future__ import with_statement

import os
import sys
from logging.config import fileConfig

from sqlalchemy import engine_from_config, pool
from alembic import context

# ------------------------------------------------------------
# Ensure /app is on PYTHONPATH (Docker safety)
# ------------------------------------------------------------
sys.path.append("/app")

# ------------------------------------------------------------
# Alembic Config
# ------------------------------------------------------------
config = context.config

# Interpret the config file for Python logging.
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# ------------------------------------------------------------
# Import Base + ALL models so Alembic detects tables
# ------------------------------------------------------------
from app.db.base import Base

# ⚠️ IMPORTANT: import every model module here
from app.models.user import User
from app.models.profile import Profile
from app.models.photo import Photo
from app.models.prompt import Prompt
from app.models.like import Like
from app.models.match import Match
from app.models.message import Message
from app.models.report import Report, Block
from app.models.subscription import Subscription
from app.models.boost import Boost
from app.models.passkey import UserPasskey

target_metadata = Base.metadata

# ------------------------------------------------------------
# Database URL from environment (Docker)
# ------------------------------------------------------------
def get_database_url():
    url = os.getenv("DATABASE_URL")
    if not url:
        raise RuntimeError("DATABASE_URL environment variable is not set")
    return url

# ------------------------------------------------------------
# Offline migrations
# ------------------------------------------------------------
def run_migrations_offline():
    url = get_database_url()
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
        compare_type=True,
    )

    with context.begin_transaction():
        context.run_migrations()

# ------------------------------------------------------------
# Online migrations
# ------------------------------------------------------------
def run_migrations_online():
    configuration = config.get_section(config.config_ini_section)
    configuration["sqlalchemy.url"] = get_database_url()

    connectable = engine_from_config(
        configuration,
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        context.configure(
            connection=connection,
            target_metadata=target_metadata,
            compare_type=True,
        )

        with context.begin_transaction():
            context.run_migrations()

# ------------------------------------------------------------
# Entrypoint
# ------------------------------------------------------------
if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
