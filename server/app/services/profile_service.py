import uuid
from sqlalchemy.orm import Session
from app.core.config import settings
from app.core.errors import api_error
from app.models.profile import Profile
from app.models.photo import Photo
from app.models.prompt import Prompt
from app.models.user import User

def _round_loc(v: float, km: float) -> float:
    # ~1 degree lat ~= 111km. MVP approximation; good enough for privacy rounding.
    step = km / 111.0
    return round(v / step) * step

def upsert_profile(db: Session, user_id: str, data: dict):
    p = db.query(Profile).filter(Profile.user_id == user_id).first()
    if not p:
        if not db.query(User.id).filter(User.id == user_id).first():
            api_error("AUTH_INVALID_USER", "User not found. Please login again.", 401)
        p = Profile(user_id=user_id, **data)
        db.add(p)
    else:
        for k, v in data.items():
            setattr(p, k, v)

    # privacy: store approx coords
    if p.lat is not None and p.lng is not None:
        p.approx_lat = _round_loc(p.lat, settings.LOCATION_ROUNDING_KM)
        p.approx_lng = _round_loc(p.lng, settings.LOCATION_ROUNDING_KM)

    db.commit()
    return p

def update_location(db: Session, user_id: str, lat: float, lng: float):
    p = db.query(Profile).filter(Profile.user_id == user_id).first()
    if not p:
        api_error("PROFILE_REQUIRED", "Complete profile first", 409)
    p.lat = lat
    p.lng = lng
    if p.lat is not None and p.lng is not None:
        p.approx_lat = _round_loc(p.lat, settings.LOCATION_ROUNDING_KM)
        p.approx_lng = _round_loc(p.lng, settings.LOCATION_ROUNDING_KM)
    db.commit()
    return p

def get_profile(db: Session, user_id: str):
    p = db.query(Profile).filter(Profile.user_id == user_id).first()
    if not p:
        return None
    photos = db.query(Photo).filter(Photo.user_id == user_id).all()
    prompts = db.query(Prompt).filter(Prompt.user_id == user_id).order_by(Prompt.order.asc()).all()

    return {
        "user_id": p.user_id,
        "name": p.name,
        "birth_year": p.birth_year,
        "gender": p.gender,
        "intent": p.intent,
        "bio": p.bio,
        "city": p.city,
        "age_min": p.age_min,
        "age_max": p.age_max,
        "distance_km": p.distance_km,
        "pref_gender": p.pref_gender,
        "verification_status": p.verification_status,
        "approx_location": {"lat": p.approx_lat, "lng": p.approx_lng},
        "photos": [{"id": ph.id, "url": ph.s3_key, "is_primary": ph.is_primary} for ph in photos],
        "prompts": [{"id": pr.id, "question": pr.question, "answer": pr.answer, "order": pr.order} for pr in prompts],
    }

def add_photo(db: Session, user_id: str, s3_key: str, is_primary: bool = False):
    ph = Photo(id=str(uuid.uuid4()), user_id=user_id, s3_key=s3_key, is_primary=is_primary)
    db.add(ph)
    if is_primary:
        db.query(Photo).filter(Photo.user_id==user_id, Photo.id!=ph.id).update({"is_primary": False})
    db.commit()
    return ph

def set_verification_pending(db: Session, user_id: str, selfie_key: str):
    p = db.query(Profile).filter(Profile.user_id == user_id).first()
    if not p:
        api_error("PROFILE_REQUIRED", "Complete profile first", 409)
    p.verification_status = "pending"
    p.verification_selfie_key = selfie_key
    db.commit()
    return p

def upsert_prompt(db: Session, user_id: str, prompt_id: str | None, question: str, answer: str, order: int):
    if prompt_id:
        pr = db.query(Prompt).filter(Prompt.id == prompt_id, Prompt.user_id == user_id).first()
        if not pr:
            api_error("NOT_FOUND", "Prompt not found", 404)
        pr.question, pr.answer, pr.order = question, answer, order
    else:
        pr = Prompt(id=str(uuid.uuid4()), user_id=user_id, question=question, answer=answer, order=order)
        db.add(pr)
    db.commit()
    return pr

def delete_prompt(db: Session, user_id: str, prompt_id: str):
    pr = db.query(Prompt).filter(Prompt.id == prompt_id, Prompt.user_id == user_id).first()
    if not pr:
        api_error("NOT_FOUND", "Prompt not found", 404)
    db.delete(pr)
    db.commit()
