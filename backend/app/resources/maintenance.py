from datetime import date

import asyncpg
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel

from app.core.db import authenticated_conn
from app.core.security import current_user_id

router = APIRouter(prefix="/api/v1/maintenance-records", tags=["maintenance"])


class MaintenanceRecordIn(BaseModel):
    vehicle_id: str
    type: str
    description: str | None = None
    cost_cents: int
    odometer: int
    maintenance_date: date
    next_maintenance_km: int | None = None
    next_maintenance_date: date | None = None


@router.put("/{record_id}", status_code=status.HTTP_204_NO_CONTENT)
async def upsert_maintenance_record(
    record_id: str,
    body: MaintenanceRecordIn,
    user_id: str = Depends(current_user_id),
    conn: asyncpg.Connection = Depends(authenticated_conn),
) -> None:
    await conn.execute(
        """
        INSERT INTO maintenance_records (
            id, user_id, vehicle_id, type, description, cost_cents,
            odometer, maintenance_date, next_maintenance_km, next_maintenance_date
        ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
        ON CONFLICT (id) DO UPDATE SET
            vehicle_id = EXCLUDED.vehicle_id,
            type = EXCLUDED.type,
            description = EXCLUDED.description,
            cost_cents = EXCLUDED.cost_cents,
            odometer = EXCLUDED.odometer,
            maintenance_date = EXCLUDED.maintenance_date,
            next_maintenance_km = EXCLUDED.next_maintenance_km,
            next_maintenance_date = EXCLUDED.next_maintenance_date
        """,
        record_id,
        user_id,
        body.vehicle_id,
        body.type,
        body.description,
        body.cost_cents,
        body.odometer,
        body.maintenance_date,
        body.next_maintenance_km,
        body.next_maintenance_date,
    )


@router.delete("/{record_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_maintenance_record(
    record_id: str,
    user_id: str = Depends(current_user_id),
    conn: asyncpg.Connection = Depends(authenticated_conn),
) -> None:
    result = await conn.execute(
        "UPDATE maintenance_records SET deleted_at = now() WHERE id = $1",
        record_id,
    )
    if result == "UPDATE 0":
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
