# Cronograma por Sprints — Driver Finance AI

_Atualizado em 2026-06-26 | Sprint 8 completo_

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

## 🔄 Sprint 9 — Polish Final + Backlog Must-Have (planejado)

**Objetivo:** Fechar o único Must Have pendente (alertas de manutenção), adicionar o gráfico de lucro diário, e polish de UX.

| Feature | MoSCoW | Pts |
|---------|--------|-----|
| E6-US03: Alertas push de manutenção (por km/data) | M | 4 |
| E7-US09: Gráfico de lucro diário no dashboard | S | 4 |
| E10-US01: Edição de perfil (nome) | S | 2 |
| E5-US04: Sugestão automática de odômetro | S | 2 |

---

## Backlog Pós-Sprint 9 (Should/Could Have)

| Feature | MoSCoW | Pts |
|---------|--------|-----|
| E4-US06: Despesas recorrentes (IPVA, seguro) | S | 3 |
| E9-US03: Push notification ao atingir meta | S | 3 |
| E7-US04: Ganho por hora | S | 3 |
| E10-US04: Export CSV | C | 4 |
| E1-US02: Apple Sign-In (iOS) | S | 3 |
| E7-US10: ROI do veículo | C | 3 |
| E8-US03: Histórico de conversas IA | C | 3 |

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
| Sprint 9 completo | A definir | 🔄 |
| **v1.0** | A definir | 🔄 |

---

## Dependências Críticas Restantes

| Dependência | Bloqueia | Status |
|------------|---------|--------|
| Supabase projeto criado + Auth configurado | Deploy | ⏳ Ação do usuário |
| ANTHROPIC_API_KEY no Supabase Vault | Chat IA | ⏳ Ação do usuário |
| Push notification provider (FCM/APNs) | E6-US03, E9-US03 | 🔄 Sprint 9 |
