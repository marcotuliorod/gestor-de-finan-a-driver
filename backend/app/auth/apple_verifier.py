import time

import httpx
import jwt
from fastapi import HTTPException, status
from jwt.algorithms import RSAAlgorithm

from app.core.config import settings

APPLE_JWKS_URL = "https://appleid.apple.com/auth/keys"
APPLE_ISSUER = "https://appleid.apple.com"
_JWKS_CACHE_TTL_SECONDS = 3600

_jwks_cache: dict[str, dict] = {}
_jwks_fetched_at: float = 0.0


async def _get_jwks() -> dict[str, dict]:
    global _jwks_cache, _jwks_fetched_at
    now = time.monotonic()
    if not _jwks_cache or now - _jwks_fetched_at > _JWKS_CACHE_TTL_SECONDS:
        async with httpx.AsyncClient(timeout=5.0) as client:
            response = await client.get(APPLE_JWKS_URL)
            response.raise_for_status()
        keys = response.json()["keys"]
        _jwks_cache = {key["kid"]: key for key in keys}
        _jwks_fetched_at = now
    return _jwks_cache


class AppleUserInfo:
    def __init__(self, sub: str, email: str | None):
        self.sub = sub
        self.email = email


async def verify_apple_identity_token(token: str) -> AppleUserInfo:
    try:
        unverified_header = jwt.get_unverified_header(token)
        kid = unverified_header.get("kid")
        jwks = await _get_jwks()
        jwk = jwks.get(kid)
        if jwk is None:
            # Key rotated since our last fetch — force a refresh once.
            global _jwks_fetched_at
            _jwks_fetched_at = 0.0
            jwks = await _get_jwks()
            jwk = jwks.get(kid)
        if jwk is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Chave de verificação Apple (kid) não encontrada",
            )

        public_key = RSAAlgorithm.from_jwk(jwk)
        payload = jwt.decode(
            token,
            key=public_key,
            algorithms=["RS256"],
            audience=settings.apple_bundle_id,
            issuer=APPLE_ISSUER,
        )
    except jwt.PyJWTError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Token Apple inválido: {exc}",
        ) from exc

    sub = payload.get("sub")
    if not sub:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Token Apple sem sub"
        )

    return AppleUserInfo(sub=sub, email=payload.get("email"))
