import asyncpg
from fastapi import APIRouter, Depends, status
from pydantic import BaseModel

from app.core.db import authenticated_conn
from app.core.security import current_user_id

router = APIRouter(prefix="/api/v1/platforms", tags=["platforms"])


class PlatformIn(BaseModel):
    type: str
    custom_name: str | None = None
    is_active: bool = True


@router.put("/{platform_id}", status_code=status.HTTP_204_NO_CONTENT)
async def upsert_platform(
    platform_id: str,
    body: PlatformIn,
    user_id: str = Depends(current_user_id),
    conn: asyncpg.Connection = Depends(authenticated_conn),
) -> None:
    await conn.execute(
        """
        INSERT INTO platforms (id, user_id, type, custom_name, is_active)
        VALUES ($1,$2,$3,$4,$5)
        ON CONFLICT (id) DO UPDATE SET
            type = EXCLUDED.type,
            custom_name = EXCLUDED.custom_name,
            is_active = EXCLUDED.is_active
        """,
        platform_id,
        user_id,
        body.type,
        body.custom_name,
        body.is_active,
    )
