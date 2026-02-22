from pydantic import BaseModel, Field

class ReportReq(BaseModel):
    reported_id: str
    reason: str = Field(min_length=2, max_length=80)
    details: str | None = Field(default=None, max_length=500)

class BlockReq(BaseModel):
    blocked_id: str
