import asyncpg
from fastapi import APIRouter, Depends, status
from pydantic import BaseModel

from app.core.db import authenticated_conn
from app.core.security import current_user_id

router = APIRouter(prefix="/api/v1/vehicles", tags=["vehicles"])


class VehicleIn(BaseModel):
    make: str
    model: str
    year: int
    license_plate: str
    fuel_type: str
    tank_capacity_l: float
    purchase_price_cents: int
    useful_life_months: int = 60
    residual_value_pct: float = 0.200
    current_odometer: int = 0


@router.put("/{vehicle_id}", status_code=status.HTTP_204_NO_CONTENT)
async def upsert_vehicle(
    vehicle_id: str,
    body: VehicleIn,
    user_id: str = Depends(current_user_id),
    conn: asyncpg.Connection = Depends(authenticated_conn),
) -> None:
    await conn.execute(
        """
        INSERT INTO vehicles (
            id, user_id, make, model, year, license_plate, fuel_type,
            tank_capacity_l, purchase_price_cents, useful_life_months,
            residual_value_pct, current_odometer
        ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)
        ON CONFLICT (id) DO UPDATE SET
            make = EXCLUDED.make,
            model = EXCLUDED.model,
            year = EXCLUDED.year,
            license_plate = EXCLUDED.license_plate,
            fuel_type = EXCLUDED.fuel_type,
            tank_capacity_l = EXCLUDED.tank_capacity_l,
            purchase_price_cents = EXCLUDED.purchase_price_cents,
            useful_life_months = EXCLUDED.useful_life_months,
            residual_value_pct = EXCLUDED.residual_value_pct,
            current_odometer = EXCLUDED.current_odometer
        """,
        vehicle_id,
        user_id,
        body.make,
        body.model,
        body.year,
        body.license_plate,
        body.fuel_type,
        body.tank_capacity_l,
        body.purchase_price_cents,
        body.useful_life_months,
        body.residual_value_pct,
        body.current_odometer,
    )
