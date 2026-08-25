# Project Context

_Documento vivo — atualizado pelo Documentation Agent ao final de cada ciclo._
_Última atualização: 2026-08-25 | Fase: Implementation — migração Supabase → Postgres/FastAPI (Sprints 14-16) completa, ver `adr/ADR-0006`. Zero referências funcionais a Supabase restantes no código._

---

## Identidade do Projeto

| Campo | Valor |
|-------|-------|
| **Nome** | Driver Finance AI |
| **Repositório** | gestor-de-finan-a-driver |
| **Tipo** | Aplicativo móvel de gestão financeira |
| **Público** | Motoristas de aplicativo e entregadores (Uber, 99, inDrive, Táxi, Delivery) |
| **Plataformas** | iOS + Android (Flutter cross-platform) |
| **Idioma principal** | Português (BR) |

## Stack Tecnológica

| Camada | Tecnologia | Decisão |
|--------|-----------|---------|
| UI | Flutter (Dart) | ADR-0002 |
| Backend | Python/FastAPI (self-hosted, `backend/`) | ADR-0006 |
| Banco de dados | PostgreSQL self-hosted (Docker) | ADR-0006 |
| Banco local | SQLite via Drift | ADR-0005 |
| Armazenamento de estado | Riverpod v2 | — |
| Arquitetura | Clean Architecture + DDD + Feature First | ADR-0004 |
| Estratégia de dados | Offline First + Sync | ADR-0005 |
| Auth | JWT próprio (Google/Apple Sign-In nativos) | ADR-0006 |
| IA | Claude Haiku via endpoint FastAPI próprio (`/api/v1/ai/chat`) | ADR-0006 |
| Infra de produção | Docker Compose + Caddy (HTTPS automático) | `docs/DEPLOY.md` |
| CI/CD | GitHub Actions (`flutter analyze --fatal-infos` + `pytest`) | — |
| Charts | fl_chart 0.68 | — |

## Estado Atual

- **Fase:** Implementation
- **Sprint atual:** Sprint 13 completo; migração Supabase → Postgres/FastAPI (Sprints 14-16) **completa** — ver seções abaixo. Backend próprio no ar (localmente validado), zero dependência de Supabase no código.
- **PRs mergeados:** #1 → #25 (todos com CI verde)
- **Features implementadas:** ver inventário abaixo
- **Features pendentes:** ver backlog residual abaixo (reduzido a 2 itens — quase tudo do backlog original já foi entregue nos Sprints 9-13)

### Sprint 14 — Backend FastAPI + Auth (mergeado, PR #23)

`backend/` (FastAPI + asyncpg + PyJWT), `docker-compose.yml` + `.env.example` na raiz, migrations `0001-0003` (`users`, `refresh_tokens`, trigger), rotas `/api/v1/auth/{google,apple,refresh,logout,me,account}`. Flutter: `ApiClient`/`AuthSession` substituindo o Supabase Auth; Google Sign-In via `google_sign_in` nativo. Um bug de escopo de fixture (`asyncio_default_fixture_loop_scope`) só apareceu no CI, não localmente — corrigido em follow-up commit no mesmo PR.

### Sprint 15 — Migração das 9 tabelas de dados (mergeado, PR #24)

Migrations `0004-0012`: `vehicles`, `platforms`, `trips`, `expenses`, `fuel_records`, `mileage_records`, `maintenance_records`, `goals` (schema idêntico ao `supabase/migrations/`, trocando `auth.users`/`auth.uid()` pela role/`current_setting` própria) + `0012_create_app_role.sql`. Routers em `backend/app/resources/` (um por recurso, `PUT /{id}` idempotente + `DELETE` para trips/expenses/maintenance). Os 9 pares `*_repository_impl.dart`/`*_provider.dart` do Flutter reescritos, trocando `SupabaseClient`/`.upsert()` por `ApiClient`/`PUT`; falhas de sync agora vão para o Sentry (`ApiClient.reportSyncFailure`) em vez de serem descartadas silenciosamente.

**Achado de segurança importante durante a validação:** o teste de isolamento entre usuários (`test_rls_blocks_cross_user_delete`) revelou que a RLS estava **sendo ignorada** — a API conectava como a mesma role dona das tabelas, e o Postgres não aplica RLS ao dono/superuser independentemente das policies definidas. Corrigido criando uma role de baixo privilégio dedicada (`driver_finance_app`, migration `0012`) para o pool de runtime da API, mantendo a role original só para rodar migrations. Ver `app_database_url` vs `database_url` em `backend/app/core/config.py` e `APP_DB_PASSWORD` no `.env.example`/`docker-compose.yml`/CI. **Isso é o tipo de bug que só um teste de isolamento real pega — vale manter esse teste específico como guarda permanente contra regressão.**

Validado: 20/20 testes `pytest` localmente + CI verde (`flutter analyze`, `pytest`, build do APK) no PR #24.

`lib/core/network/supabase_client.dart` e o init condicional do Supabase em `main.dart` foram **mantidos propositalmente até o Sprint 16** — só o AI chat ainda usava `Supabase.instance.client`, então removê-los antes quebraria essa feature. Removidos no Sprint 16 (ver abaixo).

### Sprint 16 — AI chat + cleanup final do Supabase (completo)

`backend/app/ai/router.py` — porta fiel de `supabase/functions/ai-chat/index.ts` (Deno→Python): mesma lógica de contexto financeiro do mês (trips/expenses/goals via `asyncpg`, com `authenticated_conn`/RLS), mesmo prompt em português, chama Anthropic via SDK oficial `anthropic` (`AsyncAnthropic`) com `ANTHROPIC_API_KEY` como env var do container. Uma correção deliberada em relação ao original: passou a filtrar `deleted_at IS NULL` nas queries de trips/expenses (a Edge Function original não filtrava, o que podia incluir registros soft-deleted no contexto financeiro da IA — bug pré-existente, corrigido durante a portagem).

Flutter: `ai_chat_provider.dart` troca `Supabase.instance.client.functions.invoke('ai-chat', ...)` por `POST /api/v1/ai/chat` via `ApiClient`.

**Cleanup final:** removida a dependência `supabase_flutter` do `pubspec.yaml`; apagado `supabase/` inteiro (migrations + Edge Function); deletado `lib/core/network/supabase_client.dart` e o init condicional em `main.dart`; criado `adr/ADR-0006` (supersede ADR-0003; ADR-0005 atualizado); atualizadas as referências a Supabase em `.ai/*` (ARCHITECTURE, PROMPT_LIBRARY, DECISIONS, KNOWLEDGE_BASE, REVIEW_CHECKLIST, TASK_CLASSIFIER, AGENTS), `planning/*`, `CLAUDE.md`, `.github/workflows/ci.yml` (removidos os dart-defines `SUPABASE_URL`/`SUPABASE_ANON_KEY`, mortos desde que o último consumidor saiu), `.gitignore`, `macos/Runner/AppDelegate.swift`.

Documentos de planejamento pré-implementação com descrição técnica extensa do desenho original em Supabase (`planning/06-TECHNICAL_ARCHITECTURE.md`, `planning/09-API_CONTRACTS.md`) foram marcados com um aviso no topo como históricos/superseded (ver `adr/ADR-0006`), em vez de reescritos linha a linha — o código em `backend/` é a fonte da verdade agora.

**Critério objetivo de "zero Supabase" verificado:** `grep -rlI "supabase" . --exclude-dir=.git -i` só retorna: `pubspec.lock` (regenerado automaticamente por `flutter pub get` no CI, não editado à mão), e documentos explicitamente históricos (`adr/ADR-0003` marcado Superseded, `docs/EXECUTIVE_REPORT_2026-06-26.md`, `tasks/TASK-20260626-sprint0-setup.md`, e menções factuais/históricas dentro de ADRs e `.ai/DECISIONS.md` que narram a decisão anterior).

Validado: 23/23 testes `pytest` (20 anteriores + 3 novos de AI chat, incluindo teste de conteúdo real do prompt) contra Postgres real em container, build da imagem Docker de produção bem-sucedido. `flutter analyze`/`flutter test` **não foram executados neste ambiente** (Flutter/Dart indisponíveis) — validar via CI do PR antes de mergear.

### Infra — Docker pronto para produção (mergeado, PR #25)

Auditoria do `docker-compose.yml` (que só era usado para dev local) revelou vários gaps de produção: `postgres`/`api` publicavam porta direto no host (Postgres ficaria acessível publicamente num VPS sem firewall), sem HTTPS, sem `restart:` policy, sem limite de log, sem healthcheck na API, sem backup, sem runbook.

Corrigido com 3 arquivos compose: `docker-compose.yml` (base, agora "seguro por default" — sem porta pública em `postgres`/`api`, com `restart: unless-stopped`, `logging` limitado, healthcheck na API), `docker-compose.override.yml` (novo — carregado automaticamente só por `docker compose up` sem `-f`, republica as portas pra dev local, mantendo o fluxo já validado), `docker-compose.prod.yml` (novo — usado explicitamente em produção via `-f docker-compose.yml -f docker-compose.prod.yml`, adiciona Caddy para HTTPS automático via Let's Encrypt e um serviço `backup` sob profile, disparado por cron). `deploy/Caddyfile`, `deploy/backup.sh` e `docs/DEPLOY.md` (runbook completo de deploy) são novos. `backend/Dockerfile` passou a rodar como usuário não-root.

Validado localmente de ponta a ponta: `docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build` sobe limpo (migrations `0001-0012` aplicadas, API healthy, Caddy tenta emitir certificado real para o domínio placeholder e falha graciosamente como esperado — `api.example.com` é bloqueado pela política do Let's Encrypt), `postgres`/`api` confirmadamente sem porta pública (`docker compose port` vazio), e o serviço de backup gera um dump `.sql.gz` válido via `--profile backup run --rm backup`.

**Decisões deliberadas, documentadas como fora de escopo:** sem domínio real ainda (`api.example.com` como placeholder, trocar em produção), sem upload de backup pra storage externo (só local no VPS — perda total do VPS perde o backup junto), sem CI/CD automatizado de deploy (runbook documenta `git pull` + `up -d --build` manual via SSH).

## Proposta de Valor

> Motoristas sabem quanto recebem das plataformas, mas não sabem quanto realmente lucram.
> O Driver Finance AI transforma receitas, despesas e quilometragem em **lucro real**.

## Inventário de Features Implementadas

### ✅ Sprint 1 — Auth + Onboarding + Cadastros
| ID | Feature | Status |
|----|---------|--------|
| E1-US01-03 | Auth Google + sessão persistente | ✅ |
| E1-US04 | Delete account (LGPD) | ✅ |
| E1-US05-08 | Onboarding 4 passos (pular + completar) | ✅ |
| E2-US01-03 | Veículo CRUD + campos de depreciação | ✅ |
| E2-US04 | Plataformas padrão (Uber, 99, inDrive, Táxi, Delivery) | ✅ |

### ✅ Sprint 2 — Receitas e Despesas Core
| ID | Feature | Status |
|----|---------|--------|
| E3-US01-03 | Registro de corrida + bônus + gorjeta + cancelamento | ✅ |
| E3-US04-05 | Listagem + edição/exclusão (swipe) | ✅ |
| E4-US01-03 | Combustível + consumo médio automático + custo/km | ✅ |
| E4-US04-05 | Outras despesas + totais por categoria | ✅ |
| E5-US01-03 | Quilometragem trabalho vs pessoal | ✅ |

### ✅ Sprint 3 — Dashboard + Metas
| ID | Feature | Status |
|----|---------|--------|
| E7-US01-03 | Dashboard: KPIs (receita, despesas, lucro) + período | ✅ |
| E7-US05 | Custo por km no período | ✅ |
| E9-US01-04 | Metas mensais: definição + progresso + valor diário necessário | ✅ |
| E10-US02-03 | Dark mode + logout | ✅ |

### ✅ Sprint 4 — Relatórios + Charts
| ID | Feature | Status |
|----|---------|--------|
| — | Reports page: gráfico de barras (receita por dia) | ✅ |
| — | Reports page: gráfico de pizza (distribuição de despesas) | ✅ |
| — | Theme toggle (Auto / Claro / Escuro) | ✅ |
| — | Goal form page com cálculo de meta diária | ✅ |

### ✅ Sprint 5 — IA Conversacional
| ID | Feature | Status |
|----|---------|--------|
| E8-US01-02 | Chat IA com Claude Haiku via Supabase Edge Function | ✅ |
| — | Contexto financeiro do usuário injetado no prompt | ✅ |
| — | Sanitização de PII antes do envio | ✅ |

### ✅ Sprint 6 — Manutenções
| ID | Feature | Status |
|----|---------|--------|
| E6-US01-02 | Registro de manutenção + histórico completo | ✅ |
| — | Quick action no dashboard (+Manutenção) | ✅ |
| — | Acesso por Settings | ✅ |

### ✅ Sprint 7 — Analytics de Plataformas + Depreciação
| ID | Feature | Status |
|----|---------|--------|
| E7-US06-07 | Comparativo de plataformas + ticket médio (Reports) | ✅ |
| E7-US08 | Depreciação do veículo prorateada no dashboard | ✅ |

### ✅ Sprint 8 — Refinamentos UX
| ID | Feature | Status |
|----|---------|--------|
| E8-US04 | 6 perguntas sugeridas no chat IA | ✅ |
| E6-US04 | Próximas revisões com urgência na lista de manutenção | ✅ |
| E6-US05 | Card de custo total de manutenção | ✅ |
| E4-US07 | Filtro de período nas despesas (mês / 3 meses / ano) | ✅ |

### ✅ Sprint 9 — Polish Final + Backlog Must-Have
| ID | Feature | Status |
|----|---------|--------|
| E6-US03 | Alerta in-app de manutenção próxima (card no dashboard) | ✅ |
| E7-US09 | Gráfico de receita diária no dashboard | ✅ |
| E10-US01 | Edição de perfil (nome) via Settings | ✅ |

### ✅ Sprint 10 — Quick Wins
| ID | Feature | Status |
|----|---------|--------|
| E4-US06 | Despesas recorrentes (IPVA, seguro) — UI no VehicleFormPage | ✅ |
| E7-US10 | ROI do veículo no VehicleFormPage | ✅ |
| E1-US02 | Apple Sign-In (iOS) | ✅ |

### ✅ Sprint 11 — Dados e Exportação
| ID | Feature | Status |
|----|---------|--------|
| E8-US03 | Histórico de conversas IA (persistência + listagem) | ✅ |
| E10-US04 | Export CSV de corridas e despesas | ✅ |

### ✅ Sprint 12 — Ganho por Hora
| ID | Feature | Status |
|----|---------|--------|
| E7-US04 | Campo duração (min) na corrida + card R$/hora nos Relatórios | ✅ |

### ✅ Sprint 13 — Notificações Locais
| ID | Feature | Status |
|----|---------|--------|
| E9-US03 | Notificação local ao atingir meta mensal | ✅ |
| E6-US03 | Notificação local de manutenção ≤7 dias | ✅ |

### ✅ Estabilização de CI/Build Android (pós Sprint 13)
Core library desugaring, ajuste de versão do Flutter (3.35.7), `build-android` em PRs, correções de navegação/exclusão, target macOS adicionado.

## Backlog Residual (não implementado)

| ID | Feature | MoSCoW | Pts | Obs |
|----|---------|--------|-----|-----|
| E5-US04 | Sugestão automática de odômetro | S | 2 | |
| E2-US05 | Plataforma customizada | C | 2 | |

## Próxima Prioridade

Migração Supabase → Postgres/FastAPI **concluída** (Sprints 14-16, ver `adr/ADR-0006`). Próximos passos são de infraestrutura real (fora do código — ver "Ações Pendentes do Usuário" abaixo) e o backlog residual de produto (E5-US04, E2-US05).

## ADRs Ativos

| ADR | Título | Status |
|-----|--------|--------|
| ADR-0001 | Adotar framework multi-agente | Accepted |
| ADR-0002 | Flutter como plataforma UI | Accepted |
| ADR-0003 | Supabase + PostgreSQL como backend | Superseded por ADR-0006 |
| ADR-0004 | Clean Architecture + DDD + Feature First | Accepted |
| ADR-0005 | Offline First com SQLite + sync com backend próprio | Accepted (atualizado) |
| ADR-0006 | Backend próprio (Python/FastAPI) + Postgres self-hosted | Accepted |

## Decisões Técnicas Tomadas na Implementação

| Decisão | Contexto |
|---------|---------|
| `Color.withOpacity()` (não `withValues`) | Flutter 3.24 não tem `withValues(alpha:)` |
| `CardTheme` (não `CardThemeData`) | Flutter 3.24 |
| `fold<int>` com tipo explícito | Exigido pelo analyzer |
| `import ... as $db` para AppDatabase | Evita conflito de nome com entidades de domínio |
| `prefer_const_constructors` como erro fatal | `flutter analyze --fatal-infos` no CI |
| Claude Haiku (`claude-haiku-4-5-20251001`) | Custo-benefício para chat conversacional |
| Soft delete (`deletedAt`) | Dados financeiros nunca são apagados permanentemente |

## Dependências Externas

| Serviço | Uso | Status |
|---------|-----|--------|
| Backend próprio (`backend/`, Python/FastAPI) | Auth, dados, IA — self-hosted via Docker | Implementado e validado localmente; falta deploy real (ver ações pendentes) |
| Claude API (Anthropic) | Chat IA via endpoint FastAPI próprio (`/api/v1/ai/chat`) | Implementado (código); falta a chave real de produção |
| Google Sign-In | Auth social, `google_sign_in` nativo | Implementado (código); falta client ID real de produção |
| Apple Sign-In | Auth social (iOS) | Implementado (Sprint 10) |
| Sentry | Monitoramento de erros (crashes app + falhas de sync) | Pendente configuração do DSN de produção |

## Ações Pendentes do Usuário (infraestrutura)

| Ação | Prioridade |
|------|------------|
| Provisionar VPS real e seguir `docs/DEPLOY.md` | Alta |
| Registrar domínio real e trocar o placeholder `api.example.com` | Alta |
| Configurar Google/Apple OAuth client IDs reais de produção | Alta |
| Adicionar ANTHROPIC_API_KEY real como env var do container `api` | Alta |
| Configurar Sentry DSN | Média |

_Itens anteriores sobre provisionamento de projeto Supabase foram removidos — tornam-se obsoletos com a migração para backend próprio._

## Log de Alterações Recentes

| Data | Alteração | Sprint |
|------|-----------|--------|
| 2026-06-26 | Auth, Onboarding, Veículo, Plataformas | Sprint 1 |
| 2026-06-26 | Corridas, Combustível, Despesas, Quilometragem | Sprint 2 |
| 2026-06-26 | Dashboard KPIs, Metas, Dark mode | Sprint 3 |
| 2026-06-26 | Reports charts, Theme toggle, Goal form | Sprint 4 |
| 2026-06-26 | AI Chat via Edge Function (Claude Haiku) | Sprint 5 |
| 2026-06-26 | Manutenções CRUD | Sprint 6 |
| 2026-06-26 | Platform analytics (Reports) + Depreciação (Dashboard) | Sprint 7 |
| 2026-06-26 | AI suggestions ×6, Upcoming maintenance, Expense period filter | Sprint 8 |
| 2026-06-26 | Maintenance alert card, Daily revenue chart, Profile name edit | Sprint 9 |
| 2026-06-26 | Recurring expenses UI, Vehicle ROI, Apple Sign-In | Sprint 10 |
| 2026-06-26 | AI chat history, CSV export | Sprint 11 |
| 2026-06-26 | Trip duration field + R$/hora nos Relatórios | Sprint 12 |
| 2026-08-25 | Notificações locais (manutenção + meta) | Sprint 13 |
| 2026-08-25 | Estabilização de CI/build Android (desugaring, versão Flutter, target macOS) | Pós Sprint 13 |
| 2026-08-25 | Backend FastAPI próprio + auth (Google/Apple, JWT), substituindo Supabase Auth | Sprint 14 |
| 2026-08-25 | Migração das 9 tabelas de dados para o backend próprio; achado e corrigido bug de RLS ignorada | Sprint 15 |
| 2026-08-25 | Migração do AI chat + remoção total do Supabase do projeto (`adr/ADR-0006`) | Sprint 16 |
| 2026-08-25 | Docker de produção: HTTPS via Caddy, backup, hardening, runbook (`docs/DEPLOY.md`) | Infra |
