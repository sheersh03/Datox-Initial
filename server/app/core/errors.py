from fastapi import HTTPException

def api_error(code: str, message: str, status_code: int = 400, details=None):
    raise HTTPException(
        status_code=status_code,
        detail={"code": code, "message": message, "details": details},
    )
