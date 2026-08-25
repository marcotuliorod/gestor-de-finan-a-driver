from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.auth.router import router as auth_router
from app.core.config import settings
from app.core.db import create_pool


@asynccontextmanager
async def lifespan(app: FastAPI):
    app.state.pg_pool = await create_pool(settings.database_url)
    try:
        yield
    finally:
        await app.state.pg_pool.close()


app = FastAPI(title="Driver Finance AI API", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins.split(","),
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router)


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}
