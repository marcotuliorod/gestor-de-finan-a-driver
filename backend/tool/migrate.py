"""Runner de migrations: aplica os arquivos SQL numerados em
backend/migrations/, em ordem, registrando cada um em schema_migrations
para nunca reaplicar o mesmo arquivo duas vezes. Também sincroniza a senha
da role de runtime de baixo privilégio (driver_finance_app) a partir de
APP_DB_PASSWORD — não dá para parametrizar isso dentro de um arquivo .sql
versionado sem expor a senha em texto no repositório.

Uso: python tool/migrate.py
Requer as env vars DATABASE_URL (role admin/dona das tabelas, usada só
aqui) e APP_DB_PASSWORD (senha da role driver_finance_app usada pela API).
"""

import asyncio
import os
import sys
from pathlib import Path

import asyncpg

MIGRATIONS_DIR = Path(__file__).resolve().parent.parent / "migrations"
APP_ROLE = "driver_finance_app"


class MigrationError(RuntimeError):
    pass


async def _sync_app_role_password(conn: asyncpg.Connection) -> None:
    password = os.environ.get("APP_DB_PASSWORD")
    if not password:
        print(
            "APP_DB_PASSWORD não definida — pulando sync de senha da role "
            f"{APP_ROLE} (ok em ambientes que já a configuraram manualmente)",
            file=sys.stderr,
        )
        return
    role_exists = await conn.fetchval(
        "SELECT EXISTS (SELECT FROM pg_roles WHERE rolname = $1)", APP_ROLE
    )
    if not role_exists:
        return
    escaped = password.replace("'", "''")
    await conn.execute(f"ALTER ROLE {APP_ROLE} WITH LOGIN PASSWORD '{escaped}'")


async def run() -> None:
    database_url = os.environ.get("DATABASE_URL")
    if not database_url:
        raise MigrationError("DATABASE_URL não definida")

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

        await _sync_app_role_password(conn)
        print("Migrations em dia.")
    finally:
        await conn.close()


if __name__ == "__main__":
    try:
        asyncio.run(run())
    except MigrationError as exc:
        print(exc, file=sys.stderr)
        sys.exit(1)
