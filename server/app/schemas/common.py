from pydantic import BaseModel

class Ok(BaseModel):
    ok: bool = True

class ApiResponse(BaseModel):
    ok: bool = True
    data: dict | None = None
