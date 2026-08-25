from datetime import date

import asyncpg
from fastapi import APIRouter, Depends, status
from pydantic import BaseModel

from app.core.db import authenticated_conn
from app.core.security import current_user_id

router = APIRouter(prefix="/api/v1/goals", tags=["goals"])


class GoalIn(BaseModel):
    monthly_target_cents: int
    working_days_per_month: int = 26
    period_start: date
    period_end: date


@router.put("/{goal_id}", status_code=status.HTTP_204_NO_CONTENT)
async def upsert_goal(
    goal_id: str,
    body: GoalIn,
    user_id: str = Depends(current_user_id),
    conn: asyncpg.Connection = Depends(authenticated_conn),
) -> None:
    await conn.execute(
        """
        INSERT INTO goals (
            id, user_id, monthly_target_cents, working_days_per_month,
            period_start, period_end
        ) VALUES ($1,$2,$3,$4,$5,$6)
        ON CONFLICT (id) DO UPDATE SET
            monthly_target_cents = EXCLUDED.monthly_target_cents,
            working_days_per_month = EXCLUDED.working_days_per_month,
            period_start = EXCLUDED.period_start,
            period_end = EXCLUDED.period_end
        """,
        goal_id,
        user_id,
        body.monthly_target_cents,
        body.working_days_per_month,
        body.period_start,
        body.period_end,
    )
