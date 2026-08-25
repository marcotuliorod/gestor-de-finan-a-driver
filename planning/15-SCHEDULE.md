# Cronograma por Sprints — Driver Finance AI

_Atualizado em 2026-08-25 | Sprint 13 completo + estabilização de CI Android_

---

## ✅ Sprint 0 — Setup e Infraestrutura

**Status:** COMPLETO

- [x] Projeto Flutter com estrutura Feature First
- [x] Drift + banco local com tabelas espelho
- [x] GoRouter com rotas
- [x] Tema AppTheme light + dark
- [x] Riverpod com ProviderScope
- [x] GitHub Actions: `flutter analyze --fatal-infos` em todo PR
- [x] Branch protection: PR obrigatório para main

---

## ✅ Sprint 1 — Auth, Onboarding e Cadastros

**Status:** COMPLETO (PR #1, #2 mergeados)

| Feature | Status |
|---------|--------|
| E1-US01-03: Auth Google + sessão | ✅ |
| E1-US04: Delete account LGPD | ✅ |
| E1-US05-08: Onboarding 4 passos | ✅ |
| E2-US01-03: Veículo CRUD + depreciação | ✅ |
| E2-US04: Plataformas padrão | ✅ |

---

## ✅ Sprint 2 — Receitas e Despesas

**Status:** COMPLETO (PR #3, #4 mergeados)

| Feature | Status |
|---------|--------|
| E3-US01-05: Corridas + listagem + edição/exclusão | ✅ |
| E4-US01-05: Combustível + outras despesas + custo/km | ✅ |
| E5-US01-03: Quilometragem trabalho vs pessoal | ✅ |

---

## ✅ Sprint 3 — Dashboard + Metas

**Status:** COMPLETO (PR #5, #6 mergeados)

| Feature | Status |
|---------|--------|
| E7-US01-03,05: Dashboard KPIs + custo/km | ✅ |
| E9-US01-04: Metas mensais com progresso | ✅ |
| E10-US02-03: Dark mode + logout | ✅ |

---

## ✅ Sprint 4 — Relatórios e Charts

**Status:** COMPLETO (PR #7, #8 mergeados)

| Feature | Status |
|---------|--------|
| Reports: gráfico de barras receita por dia | ✅ |
| Reports: gráfico de pizza distribuição de despesas | ✅ |
| Theme toggle (Auto / Claro / Escuro) | ✅ |
| Goal form com meta diária calculada | ✅ |

---

## ✅ Sprint 5 — IA Conversacional

**Status:** COMPLETO (PR #9, #10 mergeados)

| Feature | Status |
|---------|--------|
| E8-US01-02: Chat IA com Claude Haiku + contexto do usuário | ✅ |
| Edge Function `ai-chat` (Deno + Supabase) | ✅ |
| Sanitização de PII | ✅ |

---

## ✅ Sprint 6 — Manutenções

**Status:** COMPLETO (PR #11 mergeado)

| Feature | Status |
|---------|--------|
| E6-US01-02: Registro de manutenção + histórico | ✅ |
| Quick action no dashboard | ✅ |
| Acesso via Settings | ✅ |

---

## ✅ Sprint 7 — Platform Analytics + Depreciação

**Status:** COMPLETO (PR #12 mergeado)

| Feature | Status |
|---------|--------|
| E7-US06-07: Comparativo plataformas + ticket médio | ✅ |
| E7-US08: Depreciação prorateada no dashboard | ✅ |

---

## ✅ Sprint 8 — Refinamentos UX

**Status:** COMPLETO (PR #13 mergeado)

| Feature | Status |
|---------|--------|
| E8-US04: 6 perguntas sugeridas no chat IA | ✅ |
| E6-US04: Próximas revisões com urgência | ✅ |
| E6-US05: Card de custo total de manutenção | ✅ |
| E4-US07: Filtro de período nas despesas | ✅ |

---

## ✅ Sprint 9 — Polish Final + Backlog Must-Have

**Status:** COMPLETO (PR #16 mergeado)

| Feature | Status |
|---------|--------|
| E6-US03: Alerta in-app de manutenção próxima (dashboard card) | ✅ |
| E7-US09: Gráfico de receita diária no dashboard | ✅ |
| E10-US01: Edição de perfil (nome) via Settings | ✅ |

---

## ✅ Sprint 10 — Quick Wins

**Status:** COMPLETO (PR #17 mergeado)

| Feature | Status |
|---------|--------|
| E4-US06: Despesas recorrentes UI (IPVA, seguro) | ✅ |
| E7-US10: ROI do veículo no VehicleFormPage | ✅ |
| E1-US02: Apple Sign-In (iOS) | ✅ |

---

## ✅ Sprint 11 — Dados e Exportação

**Status:** COMPLETO (PR #18 mergeado)

| Feature | Status |
|---------|--------|
| E8-US03: Histórico de conversas IA (persistência + listagem) | ✅ |
| E10-US04: Export CSV de corridas e despesas | ✅ |

---

## ✅ Sprint 12 — Ganho por Hora

**Status:** COMPLETO (PR #19 mergeado)

| Feature | Status |
|---------|--------|
| E7-US04: Schema migration `duration_minutes` (Drift + Supabase) | ✅ |
| E7-US04: Campo "Duração (min)" no formulário de corrida | ✅ |
| E7-US04: Card R$/hora nos Relatórios (condicional) | ✅ |

---

## ✅ Sprint 13 — Notificações Locais (manutenção + meta)

**Status:** COMPLETO (PR #20 mergeado)

| Feature | Status |
|---------|--------|
| E9-US03: Notificação local ao atingir meta mensal | ✅ |
| E6-US03: Notificação local de manutenção ≤7 dias | ✅ |

Implementado com notificações locais (`flutter_local_notifications`), sem dependência de Firebase/FCM.

---

## ✅ Estabilização de CI/Build Android (pós Sprint 13)

**Status:** COMPLETO (PRs #21, #22 mergeados)

| Item | Status |
|------|--------|
| Core library desugaring no `android/` (requisito de dependências mais novas) | ✅ |
| Ajuste de versão do Flutter (3.44.4 → 3.35.7) para build estável | ✅ |
| `build-android` passa a rodar também em Pull Requests | ✅ |
| Correções de navegação, exclusão de corridas e plataformas | ✅ |
| Target macOS adicionado | ✅ |

---

## 🔄 Sprint 14-16 — Migração Supabase → Postgres self-hosted (Python/FastAPI)

**Status:** Sprint 14 mergeado (PR #23); Sprint 15 implementado, aguardando PR; Sprint 16 pendente (`adr/ADR-0006` a ser criado nele encerra a migração)

Decisão do usuário: remover toda dependência do Supabase (Auth, Postgrest, Edge Functions), substituindo por Postgres puro self-hosted (Docker/VPS) + backend próprio em Python/FastAPI.

| Sprint | Escopo | Status |
|--------|--------|--------|
| Sprint 14 | Infra (Docker Compose Postgres+API) + backend FastAPI skeleton + Auth completo (Google/Apple/JWT próprio) | ✅ (PR #23) |
| Sprint 15 | Migração das 9 tabelas de dados (trips, expenses, fuel_records, vehicles, goals, platforms, maintenance_records, mileage_records) | ✅ implementado, aguardando PR |
| Sprint 16 | Migração do AI chat (Edge Function → endpoint FastAPI) + remoção total de `supabase_flutter`/`supabase/` + atualização de ADRs e docs | ⏳ |

Esta migração substitui as "Dependências Críticas" de Supabase listadas abaixo — elas deixam de bloquear o projeto, pois o backend próprio elimina a necessidade de provisionar um projeto Supabase.

---

## Marcos

| Marco | Data Real / Estimada | Status |
|-------|---------------------|--------|
| Sprint 0 completo | 2026-06-26 | ✅ |
| Sprint 1 completo | 2026-06-26 | ✅ |
| Sprint 2 completo | 2026-06-26 | ✅ |
| **MVP Beta** (Sprints 1-3) | **2026-06-26** | ✅ **Atingido** |
| Sprint 4 completo | 2026-06-26 | ✅ |
| Sprint 5 completo | 2026-06-26 | ✅ |
| Sprint 6 completo | 2026-06-26 | ✅ |
| Sprint 7 completo | 2026-06-26 | ✅ |
| Sprint 8 completo | 2026-06-26 | ✅ |
| Sprint 9 completo | 2026-06-26 | ✅ |
| Sprint 10 completo | 2026-06-26 | ✅ |
| Sprint 11 completo | 2026-06-26 | ✅ |
| Sprint 12 completo | 2026-06-26 | ✅ |
| Sprint 13 completo | 2026-08-25 | ✅ |
| Estabilização de CI Android | 2026-08-25 | ✅ |
| Sprint 14 (backend + auth) | A definir | ⏳ |
| Sprint 15 (dados) | A definir | ⏳ |
| Sprint 16 (AI chat + cleanup Supabase) | A definir | ⏳ |
| **v1.0** | A definir | 🔄 |

---

## Dependências Críticas Restantes

| Dependência | Bloqueia | Status |
|------------|---------|--------|
| Migração Supabase → Postgres/FastAPI (Sprints 14-16) | Elimina a dependência de provisionar Supabase | 🔄 Em planejamento |
| ANTHROPIC_API_KEY no backend próprio (env var do container) | Chat IA | ⏳ Ação do usuário (Sprint 16) |
