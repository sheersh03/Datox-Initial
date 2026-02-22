import uuid
from sqlalchemy.orm import Session
from sqlalchemy import or_, and_
from app.core.errors import api_error
from app.models.like import Like
from app.models.match import Match
from app.models.report import Block
from app.services.discovery_service import enforce_like_limit
from app.services.subscription_service import get_tier
from app.core.config import settings
from sqlalchemy import func

def _pair(a: str, b: str) -> tuple[str,str]:
    return (a,b) if a < b else (b,a)

def is_blocked(db: Session, a: str, b: str) -> bool:
    return db.query(Block).filter(
        or_(
            and_(Block.blocker_id==a, Block.blocked_id==b),
            and_(Block.blocker_id==b, Block.blocked_id==a),
        )
    ).first() is not None

def swipe(db: Session, from_user: str, to_user: str, is_like: bool):
    if from_user == to_user:
        api_error("BAD_REQUEST", "Cannot swipe yourself", 400)
    if is_blocked(db, from_user, to_user):
        api_error("BLOCKED", "Cannot interact with this user", 403)

    if is_like:
        enforce_like_limit(db, from_user)

    existing = db.query(Like).filter(Like.from_user_id==from_user, Like.to_user_id==to_user).first()
    if existing:
        api_error("ALREADY_SWIPED", "Already swiped", 409)

    db.add(Like(id=str(uuid.uuid4()), from_user_id=from_user, to_user_id=to_user, is_like=is_like))
    db.commit()

    if not is_like:
        return {"matched": False}

    # If other user already liked me => match
    other_like = db.query(Like).filter(
        Like.from_user_id==to_user,
        Like.to_user_id==from_user,
        Like.is_like==True
    ).first()
    if other_like:
        a,b = _pair(from_user, to_user)
        m = db.query(Match).filter(Match.user_a==a, Match.user_b==b).first()
        if m:
            return {"matched": True, "match_id": m.id}
        # daily match limit for spam reduction (applies to both; MVP uses per-user count)
        for uid in (from_user, to_user):
            cnt = db.query(func.count(Match.id)).filter(
                or_(Match.user_a==uid, Match.user_b==uid),
                func.date(Match.created_at)==func.current_date()
            ).scalar()
            tier = get_tier(db, uid)
            # keep same limit for all tiers for now; adjust if desired
            if cnt >= settings.FREE_MATCHES_PER_DAY:
                api_error("MATCH_LIMIT", "Daily match limit reached", 429)

        m = Match(id=str(uuid.uuid4()), user_a=a, user_b=b)
        db.add(m)
        db.commit()
        return {"matched": True, "match_id": m.id}

    return {"matched": False}
