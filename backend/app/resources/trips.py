from datetime import date

import asyncpg
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel

from app.core.db import authenticated_conn
from app.core.security import current_user_id

router = APIRouter(prefix="/api/v1/trips", tags=["trips"])


class TripIn(BaseModel):
    platform_id: str
    gross_amount_cents: int
    bonus_amount_cents: int = 0
    tip_amount_cents: int = 0
    promotion_cents: int = 0
    cancellation_cents: int = 0
    duration_minutes: int | None = None
    trip_date: date
    notes: str | None = None


@router.put("/{trip_id}", status_code=status.HTTP_204_NO_CONTENT)
async def upsert_trip(
    trip_id: str,
    body: TripIn,
    user_id: str = Depends(current_user_id),
    conn: asyncpg.Connection = Depends(authenticated_conn),
) -> None:
    await conn.execute(
        """
        INSERT INTO trips (
            id, user_id, platform_id, gross_amount_cents, bonus_amount_cents,
            tip_amount_cents, promotion_cents, cancellation_cents,
            duration_minutes, trip_date, notes
        ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
        ON CONFLICT (id) DO UPDATE SET
            platform_id = EXCLUDED.platform_id,
            gross_amount_cents = EXCLUDED.gross_amount_cents,
            bonus_amount_cents = EXCLUDED.bonus_amount_cents,
            tip_amount_cents = EXCLUDED.tip_amount_cents,
            promotion_cents = EXCLUDED.promotion_cents,
            cancellation_cents = EXCLUDED.cancellation_cents,
            duration_minutes = EXCLUDED.duration_minutes,
            trip_date = EXCLUDED.trip_date,
            notes = EXCLUDED.notes
        """,
        trip_id,
        user_id,
        body.platform_id,
        body.gross_amount_cents,
        body.bonus_amount_cents,
        body.tip_amount_cents,
        body.promotion_cents,
        body.cancellation_cents,
        body.duration_minutes,
        body.trip_date,
        body.notes,
    )


@router.delete("/{trip_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_trip(
    trip_id: str,
    user_id: str = Depends(current_user_id),
    conn: asyncpg.Connection = Depends(authenticated_conn),
) -> None:
    result = await conn.execute(
        "UPDATE trips SET deleted_at = now() WHERE id = $1", trip_id
    )
    if result == "UPDATE 0":
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
