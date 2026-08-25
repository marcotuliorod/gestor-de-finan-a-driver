# Project Context

_Documento vivo — atualizado pelo Documentation Agent ao final de cada ciclo._
_Última atualização: 2026-08-25 | Fase: Implementation — Sprint 13 Completo + estabilização de CI Android. Próxima prioridade: migração Supabase → Postgres/FastAPI (Sprints 14-16, ver ADR-0006 planejado)._

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
| Backend | Supabase | ADR-0003 |
| Banco de dados | PostgreSQL (Supabase) | ADR-0003 |
| Banco local | SQLite via Drift | ADR-0005 |
| Armazenamento de estado | Riverpod v2 | — |
| Arquitetura | Clean Architecture + DDD + Feature First | ADR-0004 |
| Estratégia de dados | Offline First + Sync | ADR-0005 |
| Auth | Supabase Auth (Google Sign-In) | — |
| IA | Claude Haiku via Supabase Edge Function | — |
| CI/CD | GitHub Actions (`flutter analyze --fatal-infos`) | — |
| Charts | fl_chart 0.68 | — |

## Estado Atual

- **Fase:** Implementation
- **Sprint atual:** Sprint 13 completo; **Sprint 14 (backend + auth) mergeado via PR #23**; **Sprint 15 (migração das 9 tabelas de dados) implementado nesta sessão**, ver abaixo — ainda não commitado/revisado em PR; Sprint 16 (AI chat + cleanup final do Supabase) pendente
- **PRs mergeados:** #1 → #23 (todos com CI verde)
- **Features implementadas:** ver inventário abaixo
- **Features pendentes:** ver backlog residual abaixo (reduzido a 2 itens — quase tudo do backlog original já foi entregue nos Sprints 9-13)

### Sprint 14 — Backend FastAPI + Auth (mergeado, PR #23)

`backend/` (FastAPI + asyncpg + PyJWT), `docker-compose.yml` + `.env.example` na raiz, migrations `0001-0003` (`users`, `refresh_tokens`, trigger), rotas `/api/v1/auth/{google,apple,refresh,logout,me,account}`. Flutter: `ApiClient`/`AuthSession` substituindo o Supabase Auth; Google Sign-In via `google_sign_in` nativo. Um bug de escopo de fixture (`asyncio_default_fixture_loop_scope`) só apareceu no CI, não localmente — corrigido em follow-up commit no mesmo PR.

### Sprint 15 — Migração das 9 tabelas de dados (implementado, não commitado)

Migrations `0004-0012`: `vehicles`, `platforms`, `trips`, `expenses`, `fuel_records`, `mileage_records`, `maintenance_records`, `goals` (schema idêntico ao `supabase/migrations/`, trocando `auth.users`/`auth.uid()` pela role/`current_setting` própria) + `0012_create_app_role.sql`. Routers em `backend/app/resources/` (um por recurso, `PUT /{id}` idempotente + `DELETE` para trips/expenses/maintenance). Os 9 pares `*_repository_impl.dart`/`*_provider.dart` do Flutter reescritos, trocando `SupabaseClient`/`.upsert()` por `ApiClient`/`PUT`; falhas de sync agora vão para o Sentry (`ApiClient.reportSyncFailure`) em vez de serem descartadas silenciosamente.

**Achado de segurança importante durante a validação:** o teste de isolamento entre usuários (`test_rls_blocks_cross_user_delete`) revelou que a RLS estava **sendo ignorada** — a API conectava como a mesma role dona das tabelas, e o Postgres não aplica RLS ao dono/superuser independentemente das policies definidas. Corrigido criando uma role de baixo privilégio dedicada (`driver_finance_app`, migration `0012`) para o pool de runtime da API, mantendo a role original só para rodar migrations. Ver `app_database_url` vs `database_url` em `backend/app/core/config.py` e `APP_DB_PASSWORD` no `.env.example`/`docker-compose.yml`/CI. **Isso é o tipo de bug que só um teste de isolamento real pega — vale manter esse teste específico como guarda permanente contra regressão.**

Validado localmente: 20/20 testes `pytest` (auth + 9 recursos, incluindo o teste de isolamento acima) contra Postgres real em container, e build da imagem Docker de produção bem-sucedido. `flutter analyze`/`flutter test` **não foram executados** — Flutter/Dart não estão disponíveis no ambiente onde este trabalho foi preparado — revisar/rodar antes de commitar/mergear.

`lib/core/network/supabase_client.dart` e o init condicional do Supabase em `main.dart` continuam **mantidos** — só o AI chat (Sprint 16) ainda usa `Supabase.instance.client` (via `functions.invoke('ai-chat', ...)`), então removê-los agora ainda quebraria essa feature.

### Infra — Docker pronto para produção (implementado, não commitado)

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

## Próxima Prioridade: Migração Supabase → Postgres/FastAPI (Sprints 14-16)

Decisão do usuário: remover toda referência ao Supabase do projeto, substituindo por Postgres puro self-hosted (Docker/VPS) + backend próprio em **Python/FastAPI**. Detalha o design, schema, faseamento e riscos no plano de implementação da sessão (backend FastAPI + asyncpg + JWT próprio + verificação Google/Apple via JWKS + RLS via `current_setting`). Um novo `adr/ADR-0006` será criado ao final do Sprint 16, superseding ADR-0003 e atualizando ADR-0005. Ver seção "Dependências Externas" abaixo, que muda de "Supabase" para "Postgres self-hosted + backend próprio" ao longo dessa migração.

## ADRs Ativos

| ADR | Título | Status |
|-----|--------|--------|
| ADR-0001 | Adotar framework multi-agente | Accepted |
| ADR-0002 | Flutter como plataforma UI | Accepted |
| ADR-0003 | Supabase + PostgreSQL como backend | Accepted |
| ADR-0004 | Clean Architecture + DDD + Feature First | Accepted |
| ADR-0005 | Offline First com SQLite + sync Supabase | Accepted |

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
| Supabase | Backend, Auth, DB, Edge Functions | Implementado (código) — **em migração para Postgres self-hosted + backend próprio Python/FastAPI, Sprints 14-16** |
| Claude API (Anthropic) | Chat IA via Edge Function | Implementado (código) — migra para endpoint FastAPI no Sprint 16 (SDK oficial `anthropic` Python) |
| Google Sign-In | Auth social | Implementado (código, via `signInWithOAuth` do Supabase) — migra para `google_sign_in` nativo no Sprint 14 |
| Apple Sign-In | Auth social (iOS) | Implementado (Sprint 10) |
| Sentry | Monitoramento de erros | Pendente configuração |

## Ações Pendentes do Usuário (infraestrutura)

| Ação | Prioridade |
|------|------------|
| Provisionar VPS + Docker para Postgres + backend FastAPI (Sprint 14) | Alta |
| Configurar Google/Apple OAuth client IDs para o backend próprio (Sprint 14) | Alta |
| Adicionar ANTHROPIC_API_KEY como env var do container `api` (Sprint 16) | Alta |
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
