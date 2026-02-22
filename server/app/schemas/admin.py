from pydantic import BaseModel, Field

class BanReq(BaseModel):
    user_id: str
    reason: str = Field(min_length=2, max_length=120)
