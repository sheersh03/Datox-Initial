from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.api.routers import (
    auth,
    profile,
    discovery,
    matching,
    chat,
    reports,
    subscriptions,
    admin,
    passkey,
)

app = FastAPI(
    title="Datox API",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json",
)

# ---------------------------------
# CORS
# ---------------------------------
origins = (
    settings.CORS_ORIGINS.split(",")
    if settings.CORS_ORIGINS
    else ["*"]
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[o.strip() for o in origins] if origins != ["*"] else ["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------
# API v1 Router Mount
# ---------------------------------
API_PREFIX = "/api/v1"

app.include_router(auth.router, prefix=f"{API_PREFIX}/auth")
app.include_router(profile.router, prefix=f"{API_PREFIX}/profile")
app.include_router(discovery.router, prefix=f"{API_PREFIX}/discovery")
app.include_router(matching.router, prefix=f"{API_PREFIX}/matching")
app.include_router(chat.router, prefix=f"{API_PREFIX}/chat")
app.include_router(reports.router, prefix=f"{API_PREFIX}/reports")
app.include_router(subscriptions.router, prefix=f"{API_PREFIX}/subscriptions")
app.include_router(admin.router, prefix=f"{API_PREFIX}/admin")
app.include_router(passkey.router, prefix=f"{API_PREFIX}/passkey")

# ---------------------------------
# Health
# ---------------------------------
@app.get("/health", tags=["system"])
def health():
    return {"ok": True, "env": settings.ENV}