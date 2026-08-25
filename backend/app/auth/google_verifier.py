import asyncio

from fastapi import HTTPException, status
from google.auth.transport import requests as google_requests
from google.oauth2 import id_token

from app.core.config import settings


class GoogleUserInfo:
    def __init__(self, sub: str, email: str, name: str | None, picture: str | None):
        self.sub = sub
        self.email = email
        self.name = name
        self.picture = picture


def _verify_sync(token: str) -> dict:
    # google-auth performs a blocking HTTP call to fetch/refresh Google's
    # certs, so this must never be awaited directly from an async route —
    # callers run it via asyncio.to_thread.
    return id_token.verify_oauth2_token(
        token, google_requests.Request(), settings.google_client_id
    )


async def verify_google_id_token(token: str) -> GoogleUserInfo:
    try:
        payload = await asyncio.to_thread(_verify_sync, token)
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Token Google inválido: {exc}",
        ) from exc

    email = payload.get("email")
    sub = payload.get("sub")
    if not email or not sub:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token Google sem email/sub",
        )

    return GoogleUserInfo(
        sub=sub,
        email=email,
        name=payload.get("name"),
        picture=payload.get("picture"),
    )
