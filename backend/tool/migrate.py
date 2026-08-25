"""Runner de migrations: aplica os arquivos SQL numerados em
backend/migrations/, em ordem, registrando cada um em schema_migrations
para nunca reaplicar o mesmo arquivo duas vezes.

Uso: python tool/migrate.py
Requer a env var DATABASE_URL (ex: postgresql://user:pass@host:5432/db).
"""

import asyncio
import os
import sys
from pathlib import Path

import asyncpg

MIGRATIONS_DIR = Path(__file__).resolve().parent.parent / "migrations"


async def run() -> None:
    database_url = os.environ.get("DATABASE_URL")
    if not database_url:
        print("DATABASE_URL não definida", file=sys.stderr)
        sys.exit(1)

    conn = await asyncpg.connect(database_url)
    try:
        await conn.execute(
            """
            CREATE TABLE IF NOT EXISTS schema_migrations (
                version TEXT PRIMARY KEY,
                applied_at TIMESTAMPTZ NOT NULL DEFAULT now()
            )
            """
        )

        applied = {
            row["version"]
            for row in await conn.fetch("SELECT version FROM schema_migrations")
        }

        migration_files = sorted(MIGRATIONS_DIR.glob("*.sql"))
        for path in migration_files:
            if path.name in applied:
                continue
            sql = path.read_text()
            print(f"Aplicando {path.name}...")
            async with conn.transaction():
                await conn.execute(sql)
                await conn.execute(
                    "INSERT INTO schema_migrations (version) VALUES ($1)",
                    path.name,
                )
        print("Migrations em dia.")
    finally:
        await conn.close()


if __name__ == "__main__":
    asyncio.run(run())
