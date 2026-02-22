import time
from redis import Redis
from app.core.config import settings
from app.core.errors import api_error

r = Redis.from_url(settings.REDIS_URL, decode_responses=True)

def _key(phone: str) -> str:
    return f"otp:{phone}"

def send_otp(phone: str) -> None:
    # In prod: integrate SMS provider. For MVP: store OTP (or bypass).
    code = settings.OTP_TEST_CODE
    r.setex(_key(phone), settings.OTP_TTL_SECONDS, code)

def verify_otp(phone: str, code: str) -> None:
    if settings.OTP_DEV_BYPASS and code == settings.OTP_TEST_CODE:
        return
    stored = r.get(_key(phone))
    if not stored or stored != code:
        api_error("OTP_INVALID", "Invalid OTP", 401)
    r.delete(_key(phone))
