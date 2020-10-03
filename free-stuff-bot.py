import asyncio
import os

from nio import AsyncClient


HOMESERVER_URL = os.environ["HOMESERVER_URL"]
BOT_USER = os.environ["BOT_USER"]
BOT_PASSWORD = os.environ["BOT_PASSWORD"]
ROOM_ID = os.environ["ROOM_ID"]
CACHE_FILE = os.environ["CACHE_FILE"]


async def main() -> None:
    client = AsyncClient(HOMESERVER_URL, BOT_USER)
    print(await client.login(BOT_PASSWORD))

    await client.room_send(
        room_id=ROOM_ID,
        message_type="m.room.message",
        content={'msgtype': "m.text", 'body': "poll"}
    )

    await client.logout()
    await client.close()

asyncio.get_event_loop().run_until_complete(main())
