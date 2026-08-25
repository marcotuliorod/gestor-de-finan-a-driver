from datetime import datetime

import asyncpg


class UserRow:
    def __init__(self, record: asyncpg.Record):
        self.id: str = str(record["id"])
        self.email: str = record["email"]
        self.display_name: str | None = record["display_name"]
        self.avatar_url: str | None = record["avatar_url"]


async def get_or_create_by_google_sub(
    conn: asyncpg.Connection,
    *,
    sub: str,
    email: str,
    name: str | None,
    picture: str | None,
) -> UserRow:
    record = await conn.fetchrow(
        "SELECT id, email, display_name, avatar_url FROM users WHERE google_sub = $1",
        sub,
    )
    if record is not None:
        return UserRow(record)

    record = await conn.fetchrow(
        """
        INSERT INTO users (email, display_name, avatar_url, google_sub)
        VALUES ($1, $2, $3, $4)
        ON CONFLICT (email) DO UPDATE SET google_sub = EXCLUDED.google_sub
        RETURNING id, email, display_name, avatar_url
        """,
        email,
        name,
        picture,
        sub,
    )
    return UserRow(record)


async def get_or_create_by_apple_sub(
    conn: asyncpg.Connection,
    *,
    sub: str,
    email: str | None,
    full_name: str | None,
) -> UserRow:
    record = await conn.fetchrow(
        "SELECT id, email, display_name, avatar_url FROM users WHERE apple_sub = $1",
        sub,
    )
    if record is not None:
        return UserRow(record)

    # Apple only sends an email on the user's first authorization; if it's
    # missing on a re-auth without a matching apple_sub yet, fall back to a
    # private-relay-style placeholder tied to the sub so the UNIQUE(email)
    # constraint never collides across different Apple accounts.
    effective_email = email or f"{sub}@apple.privaterelay.local"

    record = await conn.fetchrow(
        """
        INSERT INTO users (email, display_name, apple_sub)
        VALUES ($1, $2, $3)
        ON CONFLICT (email) DO UPDATE SET apple_sub = EXCLUDED.apple_sub
        RETURNING id, email, display_name, avatar_url
        """,
        effective_email,
        full_name,
        sub,
    )
    return UserRow(record)


async def get_by_id(conn: asyncpg.Connection, user_id: str) -> UserRow | None:
    record = await conn.fetchrow(
        "SELECT id, email, display_name, avatar_url FROM users WHERE id = $1",
        user_id,
    )
    return UserRow(record) if record is not None else None


async def update_display_name(
    conn: asyncpg.Connection, user_id: str, display_name: str
) -> UserRow:
    record = await conn.fetchrow(
        """
        UPDATE users SET display_name = $2
        WHERE id = $1
        RETURNING id, email, display_name, avatar_url
        """,
        user_id,
        display_name,
    )
    return UserRow(record)


async def delete_account(conn: asyncpg.Connection, user_id: str) -> None:
    # Every user-owned table has ON DELETE CASCADE to users(id), so this
    # single delete cascades through all of the user's data.
    await conn.execute("DELETE FROM users WHERE id = $1", user_id)


async def store_refresh_token(
    conn: asyncpg.Connection,
    *,
    user_id: str,
    token_hash: str,
    expires_at: datetime,
) -> None:
    await conn.execute(
        """
        INSERT INTO refresh_tokens (user_id, token_hash, expires_at)
        VALUES ($1, $2, $3)
        """,
        user_id,
        token_hash,
        expires_at,
    )


async def get_valid_refresh_token(
    conn: asyncpg.Connection, token_hash: str
) -> asyncpg.Record | None:
    return await conn.fetchrow(
        """
        SELECT id, user_id FROM refresh_tokens
        WHERE token_hash = $1 AND revoked_at IS NULL AND expires_at > now()
        """,
        token_hash,
    )


async def revoke_refresh_token(conn: asyncpg.Connection, token_hash: str) -> None:
    await conn.execute(
        "UPDATE refresh_tokens SET revoked_at = now() WHERE token_hash = $1",
        token_hash,
    )
