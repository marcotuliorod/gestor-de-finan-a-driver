import contextlib
import os
import sys
from pathlib import Path
from unittest.mock import AsyncMock, patch

import asyncpg
import pytest_asyncio
from httpx import ASGITransport, AsyncClient

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

os.environ.setdefault(
    "DATABASE_URL",
    "postgresql://driver_finance:devpassword@localhost:5432/driver_finance_test",
)
os.environ.setdefault("APP_DB_PASSWORD", "app-test-password")
os.environ.setdefault(
    "APP_DATABASE_URL",
    "postgresql://driver_finance_app:app-test-password@localhost:5432/driver_finance_test",
)
os.environ.setdefault("JWT_SECRET", "test-secret")
os.environ.setdefault("GOOGLE_CLIENT_ID", "test-google-client-id")
os.environ.setdefault("APPLE_BUNDLE_ID", "com.marcotuliorod.driver_finance")

from tool.migrate import run as run_migrations  # noqa: E402


@pytest_asyncio.fixture(autouse=True)
async def _migrate_db():
    # Function-scoped (not session) so its event loop scope matches
    # `asyncio_default_fixture_loop_scope = "function"` in pyproject.toml.
    # Re-running is cheap: tool/migrate.py tracks applied migrations in
    # schema_migrations and no-ops once they're already applied.
    await run_migrations()
    yield


@pytest_asyncio.fixture(autouse=True)
async def _clean_tables(_migrate_db):
    # Explicit dependency on _migrate_db so pytest guarantees migrations
    # run first — two same-scope autouse fixtures have no ordering
    # guarantee otherwise.
    conn = await asyncpg.connect(os.environ["DATABASE_URL"])
    try:
        await conn.execute("TRUNCATE refresh_tokens, users CASCADE")
    finally:
        await conn.close()
    yield


@pytest_asyncio.fixture
async def client():
    from app.main import app

    async with contextlib.AsyncExitStack() as stack:
        await stack.enter_async_context(app.router.lifespan_context(app))
        ac = await stack.enter_async_context(
            AsyncClient(transport=ASGITransport(app=app), base_url="http://test")
        )
        yield ac


async def sign_in(client: AsyncClient, *, sub: str, email: str) -> dict:
    """Signs a test user in via a mocked Google verifier and returns the
    token pair response body — reused by resource tests that need an
    authenticated user without re-testing the auth flow itself.
    """
    from app.auth.google_verifier import GoogleUserInfo

    with patch(
        "app.auth.router.verify_google_id_token",
        new=AsyncMock(
            return_value=GoogleUserInfo(sub=sub, email=email, name=None, picture=None)
        ),
    ):
        response = await client.post("/api/v1/auth/google", json={"id_token": "fake"})
    return response.json()


@pytest_asyncio.fixture
async def authed_client(client):
    """`client` pre-authenticated as a single test user — the common case
    for resource endpoint tests that aren't specifically about auth.
    """
    data = await sign_in(client, sub="resource-tests-sub", email="driver@example.com")
    client.headers["Authorization"] = f"Bearer {data['access_token']}"
    return client
