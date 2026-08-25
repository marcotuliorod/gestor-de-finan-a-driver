from datetime import date, datetime, timezone

import asyncpg
from anthropic import AsyncAnthropic
from fastapi import APIRouter, Depends
from pydantic import BaseModel

from app.core.config import settings
from app.core.db import authenticated_conn
from app.core.security import current_user_id

router = APIRouter(prefix="/api/v1/ai", tags=["ai"])

_MODEL = "claude-haiku-4-5-20251001"
_MAX_TOKENS = 1024

_MONTHS_PT = {
    1: "janeiro",
    2: "fevereiro",
    3: "março",
    4: "abril",
    5: "maio",
    6: "junho",
    7: "julho",
    8: "agosto",
    9: "setembro",
    10: "outubro",
    11: "novembro",
    12: "dezembro",
}


class AiMessageIn(BaseModel):
    role: str
    content: str


class AiChatRequest(BaseModel):
    messages: list[AiMessageIn]


class AiChatResponse(BaseModel):
    content: str


def _fmt_cents(cents: int) -> str:
    return f"R$ {cents / 100:.2f}".replace(".", ",")


def _month_label(d: date) -> str:
    return f"{_MONTHS_PT[d.month]} de {d.year}"


async def _build_system_prompt(conn: asyncpg.Connection, user_id: str) -> str:
    today = datetime.now(timezone.utc).date()
    month_start = today.replace(day=1)

    trips = await conn.fetch(
        """
        SELECT gross_amount_cents, bonus_amount_cents, tip_amount_cents,
               promotion_cents, cancellation_cents
        FROM trips
        WHERE user_id = $1 AND trip_date >= $2 AND deleted_at IS NULL
        """,
        user_id,
        month_start,
    )
    expenses = await conn.fetch(
        """
        SELECT amount_cents, category
        FROM expenses
        WHERE user_id = $1 AND expense_date >= $2 AND deleted_at IS NULL
        """,
        user_id,
        month_start,
    )
    goal = await conn.fetchrow(
        """
        SELECT monthly_target_cents, working_days_per_month
        FROM goals
        WHERE user_id = $1
        ORDER BY created_at DESC
        LIMIT 1
        """,
        user_id,
    )

    total_income_cents = sum(
        t["gross_amount_cents"]
        + t["bonus_amount_cents"]
        + t["tip_amount_cents"]
        + t["promotion_cents"]
        + t["cancellation_cents"]
        for t in trips
    )
    total_expenses_cents = sum(e["amount_cents"] for e in expenses)
    fuel_cents = sum(e["amount_cents"] for e in expenses if e["category"] == "fuel")

    context_lines = [
        f"Corridas realizadas: {len(trips)}",
        f"Receita total: {_fmt_cents(total_income_cents)}",
        f"Despesas totais: {_fmt_cents(total_expenses_cents)}",
        f"Combustível: {_fmt_cents(fuel_cents)}",
        f"Outras despesas: {_fmt_cents(total_expenses_cents - fuel_cents)}",
        f"Lucro líquido: {_fmt_cents(total_income_cents - total_expenses_cents)}",
    ]

    if goal is not None:
        target = goal["monthly_target_cents"]
        pct = round((total_income_cents / target) * 100) if target > 0 else 0
        context_lines += [
            f"Meta mensal: {_fmt_cents(target)}",
            f"Progresso da meta: {pct}%",
            f"Dias de trabalho/mês: {goal['working_days_per_month']}",
        ]

    context_block = "\n".join(f"• {line}" for line in context_lines)

    return (
        "Você é um assistente financeiro especializado para motoristas de "
        "aplicativo (Uber, 99, inDrive) no Brasil.\n"
        "Responda SEMPRE em português brasileiro, de forma clara, direta e "
        "amigável.\n"
        "Use exclusivamente os dados reais do motorista abaixo — não invente "
        "números.\n\n"
        f"DADOS FINANCEIROS — {_month_label(today)}:\n"
        f"{context_block}\n\n"
        "INSTRUÇÕES:\n"
        "- Cite os valores reais ao responder perguntas numéricas\n"
        "- Se perguntarem sobre dados indisponíveis, diga claramente\n"
        "- Dê dicas práticas quando relevante\n"
        "- Respostas concisas: máximo 3 parágrafos"
    )


@router.post("/chat", response_model=AiChatResponse)
async def chat(
    body: AiChatRequest,
    user_id: str = Depends(current_user_id),
    conn: asyncpg.Connection = Depends(authenticated_conn),
) -> AiChatResponse:
    system_prompt = await _build_system_prompt(conn, user_id)

    client = AsyncAnthropic(api_key=settings.anthropic_api_key)
    response = await client.messages.create(
        model=_MODEL,
        max_tokens=_MAX_TOKENS,
        system=system_prompt,
        messages=[{"role": m.role, "content": m.content} for m in body.messages],
    )

    content = ""
    if response.content and response.content[0].type == "text":
        content = response.content[0].text

    return AiChatResponse(content=content)
