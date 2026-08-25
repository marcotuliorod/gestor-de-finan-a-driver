from datetime import date

import asyncpg
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel

from app.core.db import authenticated_conn
from app.core.security import current_user_id

router = APIRouter(prefix="/api/v1/expenses", tags=["expenses"])


class ExpenseIn(BaseModel):
    vehicle_id: str | None = None
    category: str
    amount_cents: int
    description: str | None = None
    expense_date: date
    is_recurring: bool = False
    recurrence_type: str | None = None


@router.put("/{expense_id}", status_code=status.HTTP_204_NO_CONTENT)
async def upsert_expense(
    expense_id: str,
    body: ExpenseIn,
    user_id: str = Depends(current_user_id),
    conn: asyncpg.Connection = Depends(authenticated_conn),
) -> None:
    await conn.execute(
        """
        INSERT INTO expenses (
            id, user_id, vehicle_id, category, amount_cents, description,
            expense_date, is_recurring, recurrence_type
        ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
        ON CONFLICT (id) DO UPDATE SET
            vehicle_id = EXCLUDED.vehicle_id,
            category = EXCLUDED.category,
            amount_cents = EXCLUDED.amount_cents,
            description = EXCLUDED.description,
            expense_date = EXCLUDED.expense_date,
            is_recurring = EXCLUDED.is_recurring,
            recurrence_type = EXCLUDED.recurrence_type
        """,
        expense_id,
        user_id,
        body.vehicle_id,
        body.category,
        body.amount_cents,
        body.description,
        body.expense_date,
        body.is_recurring,
        body.recurrence_type,
    )


@router.delete("/{expense_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_expense(
    expense_id: str,
    user_id: str = Depends(current_user_id),
    conn: asyncpg.Connection = Depends(authenticated_conn),
) -> None:
    result = await conn.execute(
        "UPDATE expenses SET deleted_at = now() WHERE id = $1", expense_id
    )
    if result == "UPDATE 0":
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
