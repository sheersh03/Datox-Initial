from fastapi import WebSocket
from collections import defaultdict

class WSManager:
    def __init__(self):
        self.rooms: dict[str, set[WebSocket]] = defaultdict(set)

    async def connect(self, room: str, ws: WebSocket):
        await ws.accept()
        self.rooms[room].add(ws)

    def disconnect(self, room: str, ws: WebSocket):
        if ws in self.rooms.get(room, set()):
            self.rooms[room].remove(ws)

    async def broadcast_local(self, room: str, payload: dict):
        dead = []
        for ws in self.rooms.get(room, set()):
            try:
                await ws.send_json(payload)
            except Exception:
                dead.append(ws)
        for ws in dead:
            self.disconnect(room, ws)

ws_manager = WSManager()
