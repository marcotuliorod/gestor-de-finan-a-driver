from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    database_url: str
    # Conexão usada pelo pool de runtime da API — deve apontar para a role
    # de baixo privilégio (driver_finance_app), NUNCA para a role
    # dona/superuser das tabelas (database_url), senão RLS é ignorada
    # silenciosamente (Postgres não aplica RLS a superusers/donos de tabela).
    app_database_url: str
    jwt_secret: str
    access_token_expire_minutes: int = 15
    refresh_token_expire_days: int = 30
    google_client_id: str = ""
    apple_bundle_id: str = ""
    cors_origins: str = "*"
    anthropic_api_key: str = ""


settings = Settings()
