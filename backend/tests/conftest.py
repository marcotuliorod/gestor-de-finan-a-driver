import contextlib
import os
import sys
from pathlib import Path

import asyncpg
import pytest_asyncio
from httpx import ASGITransport, AsyncClient

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

os.environ.setdefault(
    "DATABASE_URL",
    "postgresql://driver_finance:devpassword@localhost:5432/driver_finance_test",
)
os.environ.setdefault("JWT_SECRET", "test-secret")
os.environ.setdefault("GOOGLE_CLIENT_ID", "test-google-client-id")
os.environ.setdefault("APPLE_BUNDLE_ID", "com.marcotuliorod.driver_finance")

from tool.migrate import run as run_migrations  # noqa: E402


@pytest_asyncio.fixture(scope="session", autouse=True)
async def _migrate_db():
    await run_migrations()
    yield


@pytest_asyncio.fixture(autouse=True)
async def _clean_tables():
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
