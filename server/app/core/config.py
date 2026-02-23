from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    ENV: str = "local"
    APP_NAME: str = "datox"
    API_PREFIX: str = "/api"

    DATABASE_URL: str
    REDIS_URL: str

    JWT_SECRET: str
    JWT_ISSUER: str = "datox"
    JWT_AUDIENCE: str = "datox-mobile"
    ACCESS_TOKEN_MINUTES: int = 60 * 24 * 7

    OTP_DEV_BYPASS: bool = True
    OTP_TEST_CODE: str = "123456"
    OTP_TTL_SECONDS: int = 300

    S3_ENDPOINT: str
    S3_REGION: str
    S3_BUCKET: str
    S3_ACCESS_KEY: str
    S3_SECRET_KEY: str
    S3_PUBLIC_BASE_URL: str

    REVENUECAT_WEBHOOK_AUTH: str
    REVENUECAT_MOCK_MODE: bool = True

    FREE_LIKES_PER_DAY: int = 10
    FREE_MATCHES_PER_DAY: int = 5

    LOCATION_ROUNDING_KM: float = 2.0
    CORS_ORIGINS: str = "*"

    PASSKEY_RP_ID: str = "localhost"
    PASSKEY_RP_NAME: str = "Datox"
    PASSKEY_ORIGIN: str = "http://localhost:8080"

    # Admin auth (JWT + refresh tokens)
    ADMIN_JWT_SECRET: str = ""
    ADMIN_ACCESS_TOKEN_TTL_SECONDS: int = 900
    ADMIN_REFRESH_TOKEN_TTL_SECONDS: int = 604800
    ADMIN_REFRESH_TOKEN_JTI_SALT: str = ""
    ADMIN_LOGIN_RATE_LIMIT_PER_MINUTE: int = 5
    ADMIN_REFRESH_RATE_LIMIT_PER_MINUTE: int = 10

    class Config:
        env_file = ".env"
        extra = "ignore"

settings = Settings()
