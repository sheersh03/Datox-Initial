from typing import Literal
from pydantic import BaseModel, Field, field_validator, model_validator

ALLOWED_GENDERS = {"male", "female", "nonbinary"}

class ProfileUpsert(BaseModel):
    name: str = Field(min_length=1, max_length=80)
    birth_year: int = Field(ge=1900, le=2100)
    gender: Literal["male", "female", "nonbinary"]
    intent: Literal["dating", "friends", "marriage"]
    bio: str | None = Field(default=None, max_length=400)
    city: str | None = Field(default=None, max_length=80)

    lat: float | None = Field(default=None, ge=-90, le=90)
    lng: float | None = Field(default=None, ge=-180, le=180)

    age_min: int = Field(default=18, ge=18, le=80)
    age_max: int = Field(default=40, ge=18, le=80)
    distance_km: int = Field(default=20, ge=1, le=200)
    pref_gender: str | None = Field(default=None, max_length=64)

    @field_validator("gender", "intent", mode="before")
    @classmethod
    def normalize_choice(cls, v):
        if isinstance(v, str):
            return v.strip().lower()
        return v

    @field_validator("pref_gender")
    @classmethod
    def validate_pref_gender(cls, v: str | None) -> str | None:
        if v is None:
            return None
        vals = [x.strip().lower() for x in v.split(",") if x.strip()]
        if not vals:
            return None
        invalid = [x for x in vals if x not in ALLOWED_GENDERS]
        if invalid:
            raise ValueError("pref_gender must be comma-separated male/female/nonbinary")
        return ",".join(vals)

    @model_validator(mode="after")
    def validate_age_window(self):
        if self.age_min > self.age_max:
            raise ValueError("age_min must be <= age_max")
        return self

class LocationUpdate(BaseModel):
    lat: float = Field(ge=-90, le=90)
    lng: float = Field(ge=-180, le=180)

class PromptIn(BaseModel):
    question: str = Field(min_length=2, max_length=120)
    answer: str = Field(min_length=1, max_length=240)
    order: int = Field(default=0, ge=0, le=10)

class PromptOut(BaseModel):
    id: str
    question: str
    answer: str
    order: int

class SignedUpload(BaseModel):
    upload_url: str
    public_url: str
    s3_key: str

class VerificationRequest(BaseModel):
    selfie_s3_key: str
