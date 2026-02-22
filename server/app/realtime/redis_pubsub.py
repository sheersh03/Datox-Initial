import json
import asyncio
import redis.asyncio as redis
from app.core.config import settings

class RedisBus:
    def __init__(self):
        self.r = redis.from_url(settings.REDIS_URL, decode_responses=True)

    async def publish(self, channel: str, payload: dict):
        await self.r.publish(channel, json.dumps(payload))

    async def subscribe(self, channel: str):
        pubsub = self.r.pubsub()
        await pubsub.subscribe(channel)
        try:
            while True:
                msg = await pubsub.get_message(ignore_subscribe_messages=True, timeout=1.0)
                if msg and msg.get("data"):
                    yield json.loads(msg["data"])
                await asyncio.sleep(0.01)
        finally:
            await pubsub.unsubscribe(channel)
            await pubsub.close()
