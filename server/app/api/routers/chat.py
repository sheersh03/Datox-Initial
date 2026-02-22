import asyncio
from fastapi import APIRouter, Depends, HTTPException, WebSocket, WebSocketDisconnect
from sqlalchemy.orm import Session
from app.api.deps import get_db, require_profile, ensure_profile_exists
from app.api.openapi_responses import PROFILE_REQUIRED_RESPONSE
from app.core.security import decode_token
from app.core.rate_limit import rate_limit
from app.db.session import SessionLocal
from app.services.chat_service import list_messages, send_message
from app.realtime.websocket_manager import ws_manager
from app.realtime.redis_pubsub import RedisBus
from app.schemas.chat import SendMsgReq

router = APIRouter(tags=["chat"])
bus = RedisBus()

@router.get("/{match_id}/messages", responses={409: PROFILE_REQUIRED_RESPONSE})
def get_messages(
    match_id: str,
    cursor: str | None = None,
    limit: int = 50,
    db: Session = Depends(get_db),
    user_id: str = Depends(require_profile),
):
    rate_limit(f"msg_list:{user_id}", limit=60, window_seconds=60)
    offset = int(cursor or "0")
    items = list_messages(db, match_id, user_id, offset, limit)
    next_cursor = str(offset + len(items)) if len(items) == limit else None
    return {"ok": True, "data": {"items": items, "next_cursor": next_cursor}}

@router.post("/{match_id}/messages", responses={409: PROFILE_REQUIRED_RESPONSE})
def post_message(
    match_id: str,
    req: SendMsgReq,
    db: Session = Depends(get_db),
    user_id: str = Depends(require_profile),
):
    rate_limit(f"msg_send:{user_id}", limit=30, window_seconds=60)
    msg = send_message(db, match_id, user_id, req.content.strip())
    return {"ok": True, "data": msg}

@router.websocket("/ws/chat")
async def ws_chat(ws: WebSocket):
    token = ws.query_params.get("token")
    match_id = ws.query_params.get("match_id")
    if not token or not match_id:
        await ws.close(code=4400)
        return

    user_id = decode_token(token)
    db = SessionLocal()
    try:
        ensure_profile_exists(db, user_id)
    except HTTPException as exc:
        if exc.status_code != 409:
            await ws.close(code=4401)
            return
        await ws.close(code=4409)
        return
    finally:
        db.close()

    room = f"match:{match_id}"
    await ws_manager.connect(room, ws)

    async def forward_from_redis():
        async for payload in bus.subscribe(room):
            await ws_manager.broadcast_local(room, payload)

    task = asyncio.create_task(forward_from_redis())

    try:
        while True:
            data = await ws.receive_json()
            if data.get("type") == "message":
                content = str(data.get("content", "")).strip()
                if not content:
                    continue

                # persist message
                db = SessionLocal()
                try:
                    msg = send_message(db, match_id, user_id, content)
                finally:
                    db.close()

                payload = {"type": "message", "data": msg}
                await bus.publish(room, payload)
            else:
                await ws.send_json({"type": "pong"})
    except WebSocketDisconnect:
        pass
    finally:
        ws_manager.disconnect(room, ws)
        task.cancel()
