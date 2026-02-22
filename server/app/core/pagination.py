from pydantic import BaseModel, Field

class Page(BaseModel):
    items: list
    next_cursor: str | None = None

def encode_cursor(value: int) -> str:
    return str(value)

def decode_cursor(cursor: str | None) -> int:
    if not cursor:
        return 0
    try:
        return int(cursor)
    except ValueError:
        return 0
