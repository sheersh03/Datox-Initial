import os
import uuid
from webauthn import (
    generate_registration_options,
    verify_registration_response,
    options_to_json,
    base64url_to_bytes,
)
from webauthn.helpers.structs import (
    AuthenticatorSelectionCriteria,
    AuthenticatorAttachment,
    ResidentKeyRequirement,
    UserVerificationRequirement,
)

from sqlalchemy.orm import Session
from app.core.config import settings
from app.core.errors import api_error
from app.models.passkey import UserPasskey


PASSKEY_CHALLENGE_PREFIX = "passkey_challenge:"
CHALLENGE_TTL = 300  # 5 minutes


def _get_redis():
    import redis
    return redis.from_url(settings.REDIS_URL)


def _challenge_key(user_id: str) -> str:
    return f"{PASSKEY_CHALLENGE_PREFIX}{user_id}"


def start_registration(db: Session, user_id: str, user_name: str) -> dict:
    """Generate registration options and store challenge."""
    existing = db.query(UserPasskey).filter(UserPasskey.user_id == user_id).first()
    if existing:
        api_error("PASSKEY_EXISTS", "Passkey already registered for this user", 409)

    r = _get_redis()
    challenge = os.urandom(32)
    r.setex(_challenge_key(user_id), CHALLENGE_TTL, challenge)

    options = generate_registration_options(
        rp_id=settings.PASSKEY_RP_ID,
        rp_name=settings.PASSKEY_RP_NAME,
        user_id=user_id.encode("utf-8"),
        user_name=user_name or user_id,
        user_display_name=user_name or user_id,
        authenticator_selection=AuthenticatorSelectionCriteria(
            authenticator_attachment=AuthenticatorAttachment.PLATFORM,
            resident_key=ResidentKeyRequirement.PREFERRED,
            user_verification=UserVerificationRequirement.PREFERRED,
        ),
        challenge=challenge,
    )

    return options_to_json(options)


def finish_registration(db: Session, user_id: str, credential: dict) -> None:
    """Verify registration response and store credential."""
    r = _get_redis()
    challenge_key = _challenge_key(user_id)
    challenge_b64 = r.get(challenge_key)
    if not challenge_b64:
        api_error("PASSKEY_CHALLENGE_EXPIRED", "Registration challenge expired. Please try again.", 400)
    r.delete(challenge_key)

    try:
        verification = verify_registration_response(
            credential=credential,
            expected_challenge=challenge_b64,
            expected_origin=settings.PASSKEY_ORIGIN,
            expected_rp_id=settings.PASSKEY_RP_ID,
            require_user_verification=False,
        )
    except Exception as e:
        api_error("PASSKEY_VERIFY_FAILED", str(e), 400)

    existing = db.query(UserPasskey).filter(
        UserPasskey.credential_id == verification.credential_id
    ).first()
    if existing:
        api_error("PASSKEY_CREDENTIAL_EXISTS", "Credential already registered", 409)

    passkey = UserPasskey(
        id=str(uuid.uuid4()),
        user_id=user_id,
        credential_id=verification.credential_id,
        public_key=verification.credential_public_key,
        sign_count=verification.sign_count,
    )
    db.add(passkey)
    db.commit()


def has_passkey(db: Session, user_id: str) -> bool:
    return db.query(UserPasskey).filter(UserPasskey.user_id == user_id).first() is not None
