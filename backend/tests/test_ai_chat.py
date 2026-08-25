from types import SimpleNamespace
from unittest.mock import AsyncMock, patch


def _fake_anthropic_client(reply_text: str):
    fake_response = SimpleNamespace(
        content=[SimpleNamespace(type="text", text=reply_text)]
    )
    fake_client = SimpleNamespace(
        messages=SimpleNamespace(create=AsyncMock(return_value=fake_response))
    )
    return patch("app.ai.router.AsyncAnthropic", return_value=fake_client), fake_client


async def _sign_in_and_get_token(client) -> str:
    from tests.conftest import sign_in

    data = await sign_in(client, sub="ai-chat-sub", email="driver@example.com")
    return data["access_token"]


async def test_chat_requires_auth(client):
    response = await client.post(
        "/api/v1/ai/chat", json={"messages": [{"role": "user", "content": "oi"}]}
    )
    assert response.status_code == 401


async def test_chat_returns_assistant_reply(client):
    access_token = await _sign_in_and_get_token(client)
    client.headers["Authorization"] = f"Bearer {access_token}"

    patcher, fake_client = _fake_anthropic_client("Você lucrou R$ 0,00 este mês.")
    with patcher:
        response = await client.post(
            "/api/v1/ai/chat",
            json={"messages": [{"role": "user", "content": "Quanto lucrei?"}]},
        )

    assert response.status_code == 200
    assert response.json() == {"content": "Você lucrou R$ 0,00 este mês."}
    fake_client.messages.create.assert_awaited_once()


async def test_chat_includes_real_financial_context_in_system_prompt(
    client, authed_client
):
    # authed_client already created a trip/platform/expense fixture user in
    # other tests' style — build our own minimal data here instead, to keep
    # this test self-contained about exactly what ends up in the prompt.
    platform_id = "11111111-1111-1111-1111-111111111111"
    await authed_client.put(
        f"/api/v1/platforms/{platform_id}", json={"type": "uber"}
    )
    from datetime import date

    today = date.today().isoformat()
    await authed_client.put(
        "/api/v1/trips/22222222-2222-2222-2222-222222222222",
        json={
            "platform_id": platform_id,
            "gross_amount_cents": 10000,
            "trip_date": today,
        },
    )

    patcher, fake_client = _fake_anthropic_client("ok")
    with patcher:
        response = await authed_client.post(
            "/api/v1/ai/chat",
            json={"messages": [{"role": "user", "content": "oi"}]},
        )

    assert response.status_code == 200
    call_kwargs = fake_client.messages.create.await_args.kwargs
    assert "Corridas realizadas: 1" in call_kwargs["system"]
    assert "R$ 100,00" in call_kwargs["system"]
