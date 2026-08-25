from datetime import date

import asyncpg
from fastapi import APIRouter, Depends, status
from pydantic import BaseModel

from app.core.db import authenticated_conn
from app.core.security import current_user_id

router = APIRouter(prefix="/api/v1/mileage-records", tags=["mileage"])


class MileageRecordIn(BaseModel):
    vehicle_id: str
    start_odometer: int
    end_odometer: int
    work_km: int = 0
    personal_km: int = 0
    record_date: date


@router.put("/{record_id}", status_code=status.HTTP_204_NO_CONTENT)
async def upsert_mileage_record(
    record_id: str,
    body: MileageRecordIn,
    user_id: str = Depends(current_user_id),
    conn: asyncpg.Connection = Depends(authenticated_conn),
) -> None:
    await conn.execute(
        """
        INSERT INTO mileage_records (
            id, user_id, vehicle_id, start_odometer, end_odometer,
            work_km, personal_km, record_date
        ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
        ON CONFLICT (id) DO UPDATE SET
            vehicle_id = EXCLUDED.vehicle_id,
            start_odometer = EXCLUDED.start_odometer,
            end_odometer = EXCLUDED.end_odometer,
            work_km = EXCLUDED.work_km,
            personal_km = EXCLUDED.personal_km,
            record_date = EXCLUDED.record_date
        """,
        record_id,
        user_id,
        body.vehicle_id,
        body.start_odometer,
        body.end_odometer,
        body.work_km,
        body.personal_km,
        body.record_date,
    )
