from pydantic import BaseModel, Field


class PasskeyRegisterStartReq(BaseModel):
    user_name: str | None = Field(default=None, max_length=256)


class PasskeyRegisterFinishReq(BaseModel):
    credential: dict = Field(...)
