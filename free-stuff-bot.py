import asyncio
import json
import requests

from os import environ, path
from shutil import copy

from nio import AsyncClient


HOMESERVER_URL = environ["HOMESERVER_URL"]
BOT_USER = environ["BOT_USER"]
BOT_PASSWORD = environ["BOT_PASSWORD"]
ROOM_ID = environ["ROOM_ID"]
STORAGE_FILE = environ["STORAGE_FILE"]
URL_SKIP = environ["URL_SKIP"]


def create_cache() -> None:
    """Creates a local cache file, if none exists."""
    if not path.exists(STORAGE_FILE):
        copy("./storage.example.json", "storage.json")


def cache_results(results: list) -> None:
    """Add the given results to the local cache file.

    Arguments:
    results -- A list of result objects that should be added to the local cache file.
    """
    # Read cache file
    with open(STORAGE_FILE, "r") as f:
        posts_cache = json.load(f)

    # Add new posts to cache list
    posts_cache["posts_seen"].extend(results)

    # Write new cache to file
    with open(STORAGE_FILE, "w") as f:
        json.dump(posts_cache, f)


def filter_posts(posts: list) -> list:
    """Filter the given lists of posts with the local cache file.

    Arguments:
    posts -- Lists of posts that should be filtered."""
    # Read cache file
    with open(STORAGE_FILE, "r") as f:
        posts_cache = [post["id"] for post in json.load(f)["posts_seen"]]

    # Remove already seen posts
    return (
        post for post
        in posts
        if post["data"]["id"] not in posts_cache
    )


def skip_url(url: str) -> str:
    """Check if the given URL should be skipped or not in future processing.

    Arguments:
    url -- The URL that should be checked."""
    skip_urls = URL_SKIP.split(",")

    return any([skip_url in url for skip_url in skip_urls])


def fetch_posts() -> list:
    """Fetch the most recent posts of data source and return only the new ones."""
    # Fetch new posts in GameDeals sub-reddit
    headers = {"User-agent": "free-stuff-matrixbotv0.1"}
    most_recent_posts = requests.get(
        "https://old.reddit.com/r/GameDeals/new/.json",
        headers=headers
    ).json()

    # Remove unused information from post objects
    posts_squashed = [
        {
            "id": post["data"]["id"],
            "timestamp": post["data"]["created"],
            "title": post["data"]["title"],
            "url": post["data"]["url"],
            "skip": skip_url(post["data"]["url"])
        }
        for post in filter_posts(most_recent_posts["data"]["children"])
    ]

    return posts_squashed


def format_message_content(post: dict) -> str:
    """Format the given post object into a nice HTML matrix message content object.

    Arguments:
    post -- Dictionary object holding the post information.
    """
    message_body = f"[{post['title']}]({post['url']})"
    message_formatted_body = (
        f"<a href='{post['url']}'>"
        f"{post['title']}"
        "</a>"
    )

    return {
        "msgtype": "m.text",
        "body": message_body,
        "format": "org.matrix.custom.html",
        "formatted_body": message_formatted_body
    }


async def main() -> None:
    client = AsyncClient(HOMESERVER_URL, BOT_USER)
    print(await client.login(BOT_PASSWORD))

    # Build local cache
    create_cache()

    # Fetch recent posts from all sources
    posts = fetch_posts()

    # Only post and cache if there are new posts
    if len(posts) > 0:
        cache_results(posts)

        for post in posts:
            if not post["skip"]:
                await client.room_send(
                    room_id=ROOM_ID,
                    message_type="m.room.message",
                    content=format_message_content(post)
                )

    # End this session
    await client.logout()
    await client.close()

asyncio.get_event_loop().run_until_complete(main())
