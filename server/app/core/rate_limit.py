import time
from redis import Redis
from app.core.config import settings
from app.core.errors import api_error

redis = Redis.from_url(settings.REDIS_URL, decode_responses=True)

def rate_limit(key: str, limit: int, window_seconds: int):
    now = int(time.time())
    bucket = now // window_seconds
    rkey = f"rl:{key}:{bucket}"
    val = redis.incr(rkey)
    if val == 1:
        redis.expire(rkey, window_seconds + 2)
    if val > limit:
        api_error("RATE_LIMITED", "Too many requests", 429)
