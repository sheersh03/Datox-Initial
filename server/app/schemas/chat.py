from pydantic import BaseModel, Field

class SendMsgReq(BaseModel):
    content: str = Field(min_length=1, max_length=2000)

class MessageOut(BaseModel):
    id: str
    match_id: str
    sender_id: str
    type: str
    content: str
    created_at: str
