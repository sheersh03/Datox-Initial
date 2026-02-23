from fastapi import APIRouter, Depends, Header, Request
from sqlalchemy.orm import Session
from datetime import datetime
from app.api.deps import get_db
from app.core.config import settings
from app.core.errors import api_error
from app.core.security import auth_user_id
from app.services.subscription_service import (
    set_tier, get_tier,
    can_see_likes_you, unlimited_likes, has_read_receipts, has_undo_swipe, weekly_boosts
)
from app.services.addon_service import grant_entitlement

# Map RevenueCat product_id (normalized) -> (addon_type, count)
# Product IDs are lowercased and hyphens replaced with underscores
ADDON_PRODUCT_MAP = {
    "spotlight": ("spotlight", 1),
    "super_swipe": ("super_swipe", 5),
    "superswipe": ("super_swipe", 5),
    "boost": ("boost", 1),
    "compliment": ("compliment", 5),
    "compliments": ("compliment", 5),
    "extend": ("extend", 1),
    "extends": ("extend", 1),
    "rematch": ("rematch", 1),
    "backtrack": ("backtrack", 1),
    "travel_mode": ("travel_mode", 1),
    "incognito": ("incognito", 1),
}


def _extract_addon_from_product(product_id: str) -> tuple[str, int] | None:
    norm = product_id.lower().replace("-", "_")
    if norm in ADDON_PRODUCT_MAP:
        return ADDON_PRODUCT_MAP[norm]
    # Handle com.app.spotlight -> extract "spotlight"
    for key in ADDON_PRODUCT_MAP:
        if norm.endswith("_" + key) or norm == key:
            return ADDON_PRODUCT_MAP[key]
    return None

router = APIRouter(tags=["subscriptions"])

@router.get("/me")
def my_entitlements(db: Session = Depends(get_db), user_id: str = Depends(auth_user_id)):
    tier = get_tier(db, user_id)
    return {
        "ok": True,
        "data": {
            "tier": tier,
            "can_see_likes_you": can_see_likes_you(tier),
            "unlimited_likes": unlimited_likes(tier),
            "has_read_receipts": has_read_receipts(tier),
            "has_undo_swipe": has_undo_swipe(tier),
            "weekly_boosts": weekly_boosts(tier),
        }
    }

@router.post("/mock/set-tier")
def mock_set_tier(
    tier: str,
    db: Session = Depends(get_db),
    user_id: str = Depends(auth_user_id),
):
    if not settings.REVENUECAT_MOCK_MODE:
        api_error("FORBIDDEN", "Mock mode disabled", 403)
    if tier not in ("free", "lite", "plus"):
        api_error("BAD_REQUEST", "tier must be free/lite/plus", 400)
    set_tier(db, user_id, tier=tier, expires_at=None, entitlements={"mock": True, "tier": tier})
    return {"ok": True, "data": {"tier": tier}}

@router.post("/revenuecat/webhook")
async def revenuecat_webhook(
    req: Request,
    authorization: str | None = Header(default=None),
    db: Session = Depends(get_db),
):
    if authorization != f"Bearer {settings.REVENUECAT_WEBHOOK_AUTH}":
        api_error("FORBIDDEN", "Invalid webhook auth", 403)

    payload = await req.json()
    app_user_id = payload.get("app_user_id") or payload.get("event", {}).get("app_user_id")
    if not app_user_id:
        api_error("BAD_WEBHOOK", "Missing app_user_id", 400)

    ent = payload.get("entitlements") or payload.get("event", {}).get("entitlements") or {}
    tier = "free"
    expires = None

    def parse_exp(x: str):
        return datetime.fromisoformat(x.replace("Z", "+00:00"))

    if "plus" in ent and ent["plus"].get("expires_date"):
        tier = "plus"
        expires = parse_exp(ent["plus"]["expires_date"])
    elif "lite" in ent and ent["lite"].get("expires_date"):
        tier = "lite"
        expires = parse_exp(ent["lite"]["expires_date"])

    set_tier(db, app_user_id, tier=tier, expires_at=expires, entitlements=ent)

    # Handle add-on consumable purchases (NON_RENEWING_PURCHASE)
    event = payload.get("event", {})
    product_id = event.get("product_id") or payload.get("product_id") or ""
    mapped = _extract_addon_from_product(product_id)
    if mapped:
        addon_type, count = mapped
        grant_entitlement(db, app_user_id, addon_type, remaining_count=count)

    return {"ok": True}
