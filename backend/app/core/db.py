from collections.abc import AsyncIterator

import asyncpg
from fastapi import Depends, Request

from app.core.security import current_user_id

_POOL_ATTR = "pg_pool"


async def create_pool(database_url: str) -> asyncpg.Pool:
    return await asyncpg.create_pool(database_url, min_size=1, max_size=10)


async def get_conn(request: Request) -> AsyncIterator[asyncpg.Connection]:
    """Plain transactional connection, no RLS session var set.

    Used by routes that don't yet have an authenticated user (auth/google,
    auth/apple, auth/refresh, auth/logout).
    """
    pool: asyncpg.Pool = getattr(request.app.state, _POOL_ATTR)
    async with pool.acquire() as conn, conn.transaction():
        yield conn


async def authenticated_conn(
    request: Request, user_id: str = Depends(current_user_id)
) -> AsyncIterator[asyncpg.Connection]:
    """Transactional connection with `app.current_user_id` set for the
    duration of the transaction, so RLS policies
    (`current_setting('app.current_user_id', true)::uuid = user_id`) scope
    every query to the authenticated user.
    """
    pool: asyncpg.Pool = getattr(request.app.state, _POOL_ATTR)
    async with pool.acquire() as conn, conn.transaction():
        await conn.execute(
            "SELECT set_config('app.current_user_id', $1, true)", user_id
        )
        yield conn
