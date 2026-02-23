"""Pytest fixtures and test configuration."""

import os

# Set minimal env vars for tests if not already set (before any app imports)
_env_defaults = {
    "DATABASE_URL": "postgresql+psycopg://datox:datox@localhost:5432/datox",
    "REDIS_URL": "redis://localhost:6379/0",
    "JWT_SECRET": "test-jwt-secret",
    "S3_ENDPOINT": "http://localhost:9000",
    "S3_REGION": "us-east-1",
    "S3_BUCKET": "datox",
    "S3_ACCESS_KEY": "minio",
    "S3_SECRET_KEY": "minio12345",
    "S3_PUBLIC_BASE_URL": "http://localhost:9000/datox",
    "REVENUECAT_WEBHOOK_AUTH": "test-webhook-auth",
    "ADMIN_JWT_SECRET": "test-admin-jwt-secret",
    "ADMIN_REFRESH_TOKEN_JTI_SALT": "test-jti-salt",
}
for k, v in _env_defaults.items():
    os.environ.setdefault(k, v)
