from datetime import date

import asyncpg
from fastapi import APIRouter, Depends, status
from pydantic import BaseModel

from app.core.db import authenticated_conn
from app.core.security import current_user_id

router = APIRouter(prefix="/api/v1/fuel-records", tags=["fuel"])


class FuelRecordIn(BaseModel):
    expense_id: str
    vehicle_id: str
    amount_cents: int
    expense_date: date
    liters: float
    odometer: int
    fuel_type: str


@router.put("/{fuel_record_id}", status_code=status.HTTP_204_NO_CONTENT)
async def upsert_fuel_record(
    fuel_record_id: str,
    body: FuelRecordIn,
    user_id: str = Depends(current_user_id),
    conn: asyncpg.Connection = Depends(authenticated_conn),
) -> None:
    # Mirrors o que o Flutter faz hoje: um registro de combustível é sempre
    # uma despesa (categoria fixa "fuel") + os detalhes em fuel_records,
    # gravados atomicamente na mesma transação da request.
    async with conn.transaction():
        await conn.execute(
            """
            INSERT INTO expenses (
                id, user_id, vehicle_id, category, amount_cents,
                expense_date, is_recurring
            ) VALUES ($1,$2,$3,'fuel',$4,$5,false)
            ON CONFLICT (id) DO UPDATE SET
                vehicle_id = EXCLUDED.vehicle_id,
                amount_cents = EXCLUDED.amount_cents,
                expense_date = EXCLUDED.expense_date
            """,
            body.expense_id,
            user_id,
            body.vehicle_id,
            body.amount_cents,
            body.expense_date,
        )
        await conn.execute(
            """
            INSERT INTO fuel_records (
                id, expense_id, user_id, vehicle_id, liters, odometer, fuel_type
            ) VALUES ($1,$2,$3,$4,$5,$6,$7)
            ON CONFLICT (id) DO UPDATE SET
                liters = EXCLUDED.liters,
                odometer = EXCLUDED.odometer,
                fuel_type = EXCLUDED.fuel_type
            """,
            fuel_record_id,
            body.expense_id,
            user_id,
            body.vehicle_id,
            body.liters,
            body.odometer,
            body.fuel_type,
        )
