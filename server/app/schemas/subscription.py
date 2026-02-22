from pydantic import BaseModel

class EntitlementsOut(BaseModel):
    tier: str
    can_see_likes_you: bool
    unlimited_likes: bool
    has_read_receipts: bool
    has_undo_swipe: bool
    weekly_boosts: int
