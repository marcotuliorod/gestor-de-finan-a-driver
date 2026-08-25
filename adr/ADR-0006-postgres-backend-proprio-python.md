# ADR-0006: Backend próprio (Python/FastAPI) + Postgres self-hosted, substituindo Supabase

## Status
Accepted

## Data
2026-08-25

## Contexto

O projeto adotou Supabase como Backend-as-a-Service em ADR-0003. O usuário decidiu remover toda dependência do Supabase do projeto, substituindo-o por PostgreSQL puro self-hosted (Docker/VPS) — sem nenhuma referência a Supabase restando no código.

Como Postgres puro não oferece OAuth nem API REST por conta própria, a remoção do Supabase exigiu também construir um backend próprio para assumir os papéis que o Supabase cumpria: autenticação (Google/Apple Sign-In), API REST para as 9 tabelas de dados do app, e o proxy server-side para a Claude API (chat IA).

Achado relevante que reduziu o risco da migração: não havia projeto Supabase provisionado nem usuários/dados reais em produção no momento da decisão — a migração partiu de terreno limpo, sem dado de produção a migrar.

## Decisão

Adotamos um backend próprio em **Python/FastAPI** (`backend/`) rodando sobre **Postgres self-hosted** via Docker Compose, implementado em 3 fases incrementais (Sprints 14-16) para nunca deixar o app quebrado:

- **Sprint 14** — infraestrutura (Docker Compose Postgres+API) e autenticação completa (Google/Apple via verificação de JWKS, JWT próprio com refresh rotativo/revogável)
- **Sprint 15** — migração das 9 tabelas de dados (trips, expenses, fuel_records, vehicles, goals, platforms, maintenance_records, mileage_records)
- **Sprint 16** — migração do chat IA (Edge Function → endpoint FastAPI) e remoção total de `supabase_flutter`/`supabase/`

### Escolhas técnicas

| Decisão | Escolha |
|---|---|
| Framework | FastAPI sobre Uvicorn (ASGI), tipagem via Pydantic v2 |
| Acesso a dados | `asyncpg` com SQL cru (sem ORM) — schema/migrations próximos do que já existia |
| Migrations | Runner Python próprio (`backend/tool/migrate.py`) sobre SQL numerado, tabela `schema_migrations` |
| Autenticação | JWT próprio (access curto + refresh rotativo), emitido após validar OAuth |
| Google Sign-In | `google_sign_in` nativo no Flutter (troca do fluxo de redirect via `signInWithOAuth`, que nunca chegou a funcionar nativamente — sem URL scheme configurado) |
| Apple Sign-In | Mantém `sign_in_with_apple` client-side; backend valida contra o JWKS da Apple |
| Autorização | RLS real no Postgres, `auth.uid()` → `current_setting('app.current_user_id', true)::uuid` |
| Cliente Anthropic | SDK oficial `anthropic` (Python) |
| Cliente HTTP no Flutter | `dio`, via `ApiClient` (interceptor de refresh automático em 401) |
| Hosting | Docker Compose em VPS — `postgres:16` + `api` (`python:3.12-slim`) atrás de Caddy (HTTPS automático) |

## Justificativa

- Elimina dependência de fornecedor terceiro para a funcionalidade central do app (o próprio ADR-0003 já previa esta rota de saída: "SQL padrão PostgreSQL permite migração; self-hosting é viável")
- Controle total sobre custo, dados e infraestrutura
- Migração das 9 tabelas foi mecânica (schema quase idêntico, só trocando `auth.users`/`auth.uid()` pela role/`current_setting` próprios)

## Alternativas Consideradas

| Alternativa | Por que Rejeitada |
|-------------|------------------|
| Backend em Dart (dart_frog) | Primeira proposta, corrigida pelo usuário para Python/FastAPI — mesma linguagem do app tinha apelo, mas o usuário preferiu o ecossistema Python/FastAPI (mais maduro para OAuth/JWT, SDK oficial da Anthropic em Python) |
| Manter Supabase | Rejeitado — decisão explícita do usuário de eliminar a dependência |
| Autorização só em nível de aplicação (sem RLS) | Mais simples de implementar, mas remove uma camada de defesa — mantivemos RLS real, ver risco abaixo sobre a role de baixo privilégio |

## Consequências

### Positivas
- Zero dependência de Supabase — controle total da infraestrutura
- RLS real no Postgres continua isolando dados por usuário
- SDK oficial da Anthropic em Python é mais direto que a alternativa Dart (biblioteca de terceiros)
- Migração feita em 3 sprints incrementais, sem quebrar o app em nenhum momento

### Negativas
- Time agora opera duas linguagens de servidor (Dart no app, Python no backend) em vez de uma stack unificada
- Operação de infraestrutura (VPS, backups, TLS, monitoramento) passa a ser responsabilidade própria, não mais terceirizada
- Sync continua write-only e fire-and-forget (sem fila de retry, sem pull de dados) — mesma limitação que existia com Supabase, não resolvida nesta migração

### Riscos
- **RLS pode ser silenciosamente ignorada** se a API conectar como a role dona das tabelas (Postgres não aplica RLS a superusers/donos de tabela, independente das policies definidas) — descoberto durante a validação do Sprint 15 via teste de isolamento entre usuários. Mitigado com uma role de baixo privilégio dedicada (`driver_finance_app`, `backend/migrations/0012_create_app_role.sql`) para o pool de runtime da API; a role original fica só para migrations. **O teste `test_rls_blocks_cross_user_delete` (`backend/tests/test_resources.py`) é a guarda permanente contra regressão neste ponto — nunca remover.**
- Verificação de JWKS (Google/Apple) mal implementada abriria brecha de auth — mitigado com testes de unidade usando tokens assinados por chave de teste
- Backup do Postgres em produção só existe localmente no VPS (cron + rotação, sem upload externo) — perda total do VPS perde o backup junto; decisão deliberada de manter simples por ora (ver `docs/DEPLOY.md`)

## Conformidade

O Review Agent verifica:
- Nenhum import de `supabase_flutter` ou referência a `supabase/` no código
- Toda tabela de dados do usuário tem RLS habilitada com policy usando `current_setting('app.current_user_id', true)::uuid`
- Pool de runtime da API (`app_database_url`) nunca aponta para a role admin/dona das tabelas (`database_url`) — só o runner de migrations usa essa
- Nenhuma chave de API (Anthropic, JWT secret) hardcoded ou exposta ao cliente Flutter
- Endpoints novos seguem o padrão de `backend/app/resources/trips.py` (upsert idempotente + `Depends(authenticated_conn)`)

## ADRs Relacionados
- ADR-0003: Decisão original de adotar Supabase — superseded por este ADR
- ADR-0005: Offline First com SQLite + sync — atualizado para referenciar o backend próprio como destino do sync em vez do Supabase
- ADR-0004: Repository pattern continua abstraindo local vs remote; a troca de backend ficou majoritariamente confinada à camada `data/`, confirmando a tese do ADR-0004

## Originado por
Decisão do usuário, sessão de 2026-08-25 — "Planeje a alteração da estrutura para usar somente o postgres ao invés do Supabase. Não deverá existir nenhuma referência ao Supabase no projeto."
