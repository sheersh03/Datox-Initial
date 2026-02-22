import uuid
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.api.deps import get_db
from app.api.openapi_responses import PROFILE_NOT_FOUND_RESPONSE
from app.core.security import auth_user_id
from app.core.rate_limit import rate_limit
from app.schemas.profile import ProfileUpsert, LocationUpdate, PromptIn, VerificationRequest
from app.services.profile_service import (
    upsert_profile, get_profile, add_photo, upsert_prompt, delete_prompt, set_verification_pending
)
from app.services.profile_service import update_location as update_profile_location
from app.services.storage_service import ensure_bucket, presign_put, public_url
from app.core.errors import api_error

router = APIRouter(tags=["profile"])

@router.get("/me", responses={404: PROFILE_NOT_FOUND_RESPONSE})
def me(db: Session = Depends(get_db), user_id: str = Depends(auth_user_id)):
    rate_limit(f"profile_me:{user_id}", limit=120, window_seconds=60)
    p = get_profile(db, user_id)
    if not p:
        api_error("PROFILE_NOT_FOUND", "Profile not found", 404)
    return {"ok": True, "data": p}

@router.post("")
def upsert(req: ProfileUpsert, db: Session = Depends(get_db), user_id: str = Depends(auth_user_id)):
    rate_limit(f"profile_upsert:{user_id}", limit=30, window_seconds=60)
    p = upsert_profile(db, user_id, req.model_dump())
    return {"ok": True, "data": {"user_id": p.user_id}}

@router.patch("/location")
def patch_location(
    req: LocationUpdate,
    db: Session = Depends(get_db),
    user_id: str = Depends(auth_user_id),
):
    rate_limit(f"profile_location:{user_id}", limit=30, window_seconds=60)
    update_profile_location(db, user_id, req.lat, req.lng)
    return {"ok": True}

@router.post("/photos/signed-upload")
def signed_photo_upload(
    content_type: str = "image/jpeg",
    db: Session = Depends(get_db),
    user_id: str = Depends(auth_user_id),
):
    ensure_bucket()
    key = f"users/{user_id}/photos/{uuid.uuid4()}.jpg"
    url = presign_put(key, content_type=content_type)
    return {"ok": True, "data": {"upload_url": url, "public_url": public_url(key), "s3_key": key}}

@router.post("/photos/commit")
def commit_photo(
    s3_key: str,
    is_primary: bool = False,
    db: Session = Depends(get_db),
    user_id: str = Depends(auth_user_id),
):
    rate_limit(f"photo_commit:{user_id}", limit=20, window_seconds=60)
    ph = add_photo(db, user_id, s3_key, is_primary=is_primary)
    return {"ok": True, "data": {"id": ph.id, "s3_key": ph.s3_key, "is_primary": ph.is_primary}}

@router.get("/prompts")
def list_prompts(db: Session = Depends(get_db), user_id: str = Depends(auth_user_id)):
    p = get_profile(db, user_id)
    return {"ok": True, "data": {"items": (p or {}).get("prompts", [])}}

@router.post("/prompts")
def create_prompt(req: PromptIn, db: Session = Depends(get_db), user_id: str = Depends(auth_user_id)):
    rate_limit(f"prompt_write:{user_id}", limit=30, window_seconds=60)
    pr = upsert_prompt(db, user_id, None, req.question, req.answer, req.order)
    return {"ok": True, "data": {"id": pr.id}}

@router.put("/prompts/{prompt_id}")
def update_prompt(prompt_id: str, req: PromptIn, db: Session = Depends(get_db), user_id: str = Depends(auth_user_id)):
    rate_limit(f"prompt_write:{user_id}", limit=30, window_seconds=60)
    pr = upsert_prompt(db, user_id, prompt_id, req.question, req.answer, req.order)
    return {"ok": True, "data": {"id": pr.id}}

@router.delete("/prompts/{prompt_id}")
def remove_prompt(prompt_id: str, db: Session = Depends(get_db), user_id: str = Depends(auth_user_id)):
    rate_limit(f"prompt_write:{user_id}", limit=30, window_seconds=60)
    delete_prompt(db, user_id, prompt_id)
    return {"ok": True}

@router.post("/verification/signed-selfie")
def signed_selfie_upload(
    content_type: str = "image/jpeg",
    user_id: str = Depends(auth_user_id),
):
    ensure_bucket()
    key = f"users/{user_id}/verification/{uuid.uuid4()}.jpg"
    url = presign_put(key, content_type=content_type)
    return {"ok": True, "data": {"upload_url": url, "public_url": public_url(key), "s3_key": key}}

@router.post("/verification/request")
def request_verification(
    req: VerificationRequest,
    db: Session = Depends(get_db),
    user_id: str = Depends(auth_user_id),
):
    rate_limit(f"verify_req:{user_id}", limit=5, window_seconds=3600)
    p = set_verification_pending(db, user_id, req.selfie_s3_key)
    return {"ok": True, "data": {"status": p.verification_status}}
