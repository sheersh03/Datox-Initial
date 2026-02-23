"""Admin login rate limiting. Redis with in-memory fallback (dev only)."""

import logging
import time
from collections import defaultdict
from threading import Lock

from app.core.config import settings

logger = logging.getLogger(__name__)

# In-memory fallback: (key -> list of timestamps). Dev only - not suitable for multi-instance.
_memory_store: dict[str, list[float]] = defaultdict(list)
_memory_lock = Lock()
_WINDOW_SECONDS = 60


def _memory_incr(key: str, limit: int) -> bool:
    """Return True if under limit, False if rate limited."""
    now = time.time()
    with _memory_lock:
        window_start = now - _WINDOW_SECONDS
        _memory_store[key] = [t for t in _memory_store[key] if t > window_start]
        if len(_memory_store[key]) >= limit:
            return False
        _memory_store[key].append(now)
        return True


def _redis_incr(key: str, limit: int) -> bool:
    """Return True if under limit, False if rate limited."""
    try:
        from redis import Redis

        r = Redis.from_url(settings.REDIS_URL, decode_responses=True)
        bucket = int(time.time()) // _WINDOW_SECONDS
        rkey = f"admin_login:{key}:{bucket}"
        val = r.incr(rkey)
        if val == 1:
            r.expire(rkey, _WINDOW_SECONDS + 2)
        return val <= limit
    except Exception as e:
        logger.warning(
            "Admin login rate limit: Redis unavailable (%s), using in-memory fallback (dev only)",
            e,
        )
        return _memory_incr(key, limit)


def _clear_memory_store_for_tests() -> None:
    """Clear in-memory rate limit store. For testing only."""
    with _memory_lock:
        _memory_store.clear()


def check_admin_login_rate_limit(ip_address: str, email: str) -> bool:
    """
    Check rate limit for admin login. Per-IP and per-email.
    Returns True if allowed, False if rate limited (caller should raise 429).
    """
    limit = getattr(settings, "ADMIN_LOGIN_RATE_LIMIT_PER_MINUTE", 5)
    ip_ok = _redis_incr(f"ip:{ip_address}", limit)
    email_ok = _redis_incr(f"email:{email.lower().strip()}", limit)
    return ip_ok and email_ok


def check_admin_refresh_rate_limit(admin_id: str) -> bool:
    """
    Check rate limit for admin token refresh. Per admin_id.
    Returns True if allowed, False if rate limited (caller should raise 429).
    """
    limit = getattr(settings, "ADMIN_REFRESH_RATE_LIMIT_PER_MINUTE", 10)
    return _redis_incr(f"admin_refresh:{admin_id}", limit)
