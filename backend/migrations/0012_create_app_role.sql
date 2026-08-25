-- Role de baixo privilégio usada pelo pool de runtime da API (ver
-- app_database_url em config.py). Sem esta role separada, a API conectaria
-- como a mesma role dona das tabelas, e o Postgres ignora RLS para o dono
-- da tabela (e para superusers) independentemente das policies definidas —
-- ou seja, ENABLE ROW LEVEL SECURITY não teria efeito nenhum na prática.
-- A senha desta role é definida separadamente por tool/migrate.py a partir
-- de APP_DB_PASSWORD (não dá para parametrizar ALTER ROLE ... PASSWORD em
-- SQL puro sem expor a senha em texto no arquivo de migration).
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'driver_finance_app') THEN
    CREATE ROLE driver_finance_app LOGIN;
  END IF;
END
$$;

GRANT USAGE ON SCHEMA public TO driver_finance_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO driver_finance_app;

-- Cobre tabelas criadas por migrations futuras (ex.: ai_conversations no
-- Sprint 16) sem precisar de uma nova migration de GRANT a cada vez.
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO driver_finance_app;
