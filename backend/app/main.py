from contextlib import asynccontextmanager

import asyncpg
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.ai.router import router as ai_router
from app.auth.router import router as auth_router
from app.core.config import settings
from app.core.db import create_pool
from app.resources.expenses import router as expenses_router
from app.resources.fuel import router as fuel_router
from app.resources.goals import router as goals_router
from app.resources.maintenance import router as maintenance_router
from app.resources.mileage import router as mileage_router
from app.resources.platforms import router as platforms_router
from app.resources.trips import router as trips_router
from app.resources.vehicles import router as vehicles_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    app.state.pg_pool = await create_pool(settings.app_database_url)
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


@app.exception_handler(asyncpg.PostgresError)
async def postgres_error_handler(
    request: Request, exc: asyncpg.PostgresError
) -> JSONResponse:
    # CHECK/FK constraint violations, RLS rejections etc. surface as a 400
    # instead of an opaque 500 — the client sent data the database rejected.
    return JSONResponse(status_code=400, content={"detail": str(exc)})


app.include_router(auth_router)
app.include_router(trips_router)
app.include_router(expenses_router)
app.include_router(fuel_router)
app.include_router(vehicles_router)
app.include_router(goals_router)
app.include_router(platforms_router)
app.include_router(mileage_router)
app.include_router(maintenance_router)
app.include_router(ai_router)


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}
