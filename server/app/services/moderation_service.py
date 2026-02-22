import uuid
from sqlalchemy.orm import Session
from app.core.errors import api_error
from app.models.report import Report, Block
from app.models.user import User

def report_user(db: Session, reporter_id: str, reported_id: str, reason: str, details: str | None):
    if reporter_id == reported_id:
        api_error("BAD_REQUEST", "Cannot report yourself", 400)
    r = Report(
        id=str(uuid.uuid4()),
        reporter_id=reporter_id,
        reported_id=reported_id,
        reason=reason,
        details=details,
        status="open",
    )
    db.add(r)
    db.commit()
    return r

def block_user(db: Session, blocker_id: str, blocked_id: str):
    if blocker_id == blocked_id:
        api_error("BAD_REQUEST", "Cannot block yourself", 400)
    b = db.query(Block).filter(Block.blocker_id==blocker_id, Block.blocked_id==blocked_id).first()
    if b:
        return b
    b = Block(id=str(uuid.uuid4()), blocker_id=blocker_id, blocked_id=blocked_id)
    db.add(b)
    db.commit()
    return b

def list_reports(db: Session, status: str = "open", offset: int = 0, limit: int = 50):
    q = db.query(Report).filter(Report.status == status).order_by(Report.created_at.desc())
    rows = q.offset(offset).limit(limit).all()
    return [
        {
            "id": r.id,
            "reporter_id": r.reporter_id,
            "reported_id": r.reported_id,
            "reason": r.reason,
            "details": r.details,
            "status": r.status,
            "created_at": str(r.created_at),
        }
        for r in rows
    ]

def ban_user(db: Session, user_id: str, reason: str):
    u = db.query(User).filter(User.id == user_id).first()
    if not u:
        api_error("NOT_FOUND", "User not found", 404)
    u.is_banned = True
    u.ban_reason = reason
    db.commit()
    return u
