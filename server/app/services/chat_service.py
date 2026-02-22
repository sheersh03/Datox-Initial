import uuid
from sqlalchemy.orm import Session
from sqlalchemy import or_
from app.core.errors import api_error
from app.models.match import Match
from app.models.message import Message

def _ensure_member(m: Match, user_id: str) -> bool:
    return user_id in (m.user_a, m.user_b)

def list_matches(db: Session, user_id: str, offset: int, limit: int):
    q = db.query(Match).filter(or_(Match.user_a==user_id, Match.user_b==user_id)).order_by(Match.created_at.desc())
    rows = q.offset(offset).limit(limit).all()
    items = [{"match_id": m.id, "user_a": m.user_a, "user_b": m.user_b, "created_at": str(m.created_at)} for m in rows]
    return items

def list_messages(db: Session, match_id: str, user_id: str, offset: int, limit: int):
    m = db.query(Match).filter(Match.id==match_id).first()
    if not m or not _ensure_member(m, user_id):
        api_error("FORBIDDEN", "Not allowed", 403)
    rows = (db.query(Message).filter(Message.match_id==match_id)
            .order_by(Message.created_at.desc()).offset(offset).limit(limit).all())
    rows.reverse()
    return [{"id": x.id, "sender_id": x.sender_id, "type": x.type, "content": x.content, "created_at": str(x.created_at)} for x in rows]

def send_message(db: Session, match_id: str, sender_id: str, content: str):
    m = db.query(Match).filter(Match.id==match_id).first()
    if not m or not _ensure_member(m, sender_id):
        api_error("FORBIDDEN", "Not allowed", 403)
    msg = Message(id=str(uuid.uuid4()), match_id=match_id, sender_id=sender_id, content=content, type="text")
    db.add(msg)
    db.commit()
    return {"id": msg.id, "match_id": match_id, "sender_id": sender_id, "content": content, "type":"text", "created_at": str(msg.created_at)}
