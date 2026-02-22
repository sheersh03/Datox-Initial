from pydantic import BaseModel, EmailStr, Field

class SendOtpReq(BaseModel):
    phone: str = Field(min_length=8, max_length=20)

class VerifyOtpReq(BaseModel):
    phone: str = Field(min_length=8, max_length=20)
    code: str = Field(min_length=4, max_length=8)

class AuthToken(BaseModel):
    access_token: str
    token_type: str = "bearer"
