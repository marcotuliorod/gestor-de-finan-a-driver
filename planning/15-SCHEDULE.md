# Cronograma por Sprints — Driver Finance AI

_Gerado pelo Planner Agent | 2026-06-26_
_Início previsto: Sprint 0 — Semana de 30 Jun 2026_

---

## Sprint 0 — Setup e Infraestrutura (1 semana, sem story points)

**Objetivo:** Projeto rodando end-to-end com CI verde.

### Tarefas Técnicas

**Supabase:**
- [ ] Criar projeto Supabase (produção + staging)
- [ ] Configurar Auth (Google Sign-In + Apple Sign-In)
- [ ] Criar schema inicial com todas as tabelas (migrations 0001-0010)
- [ ] Configurar RLS em todas as tabelas
- [ ] Deploy Edge Function `ai-chat` (stub que retorna "OK")
- [ ] Configurar Supabase Vault para secrets (ANTHROPIC_API_KEY)

**Flutter:**
- [ ] Criar projeto Flutter com estrutura Feature First
- [ ] Configurar dependências (pubspec.yaml): riverpod, drift, supabase_flutter, go_router, fl_chart, fpdart, intl, mocktail, flutter_lints
- [ ] Configurar Drift + banco local com tabelas espelho
- [ ] Configurar GoRouter com rotas placeholder
- [ ] Configurar tema (AppTheme light + dark)
- [ ] Configurar Riverpod com ProviderScope
- [ ] Configurar Sentry

**CI/CD:**
- [ ] GitHub Actions: lint + test + build APK (Android) em todo PR
- [ ] Coverage check: falha se < 80%
- [ ] Branch protection: PR obrigatório para main

**Definição de Pronto:**
- `flutter analyze` sem warnings
- `flutter test` passando (0 testes, mas pipeline funcionando)
- Build APK debug gerando com sucesso
- Login Google funcionando em emulador

---

## Sprint 1 — Auth, Onboarding e Cadastros (2 semanas, 20 pts)

**Objetivo:** Usuário consegue fazer login, configurar veículo e plataformas.

| Feature | Story Points | Agentes |
|---------|-------------|---------|
| E1-US01-03: Auth Google + sessão | 5 | Backend + Frontend |
| E1-US04: Delete account LGPD | 3 | Backend + Database |
| E1-US05-08: Onboarding 4 passos | 10 | Frontend |
| E2-US01-02: Veículo CRUD | 3 | Backend + Frontend + Database |
| E2-US04: Plataformas padrão | 2 | Backend + Frontend |

**Gate de Conclusão:**
- Login + logout funcionando no device físico
- Onboarding completo (pular + completar)
- Veículo e plataformas persistidos localmente + sync com Supabase

---

## Sprint 2 — Receitas e Despesas (2 semanas, 20 pts)

**Objetivo:** Usuário consegue registrar corridas e despesas (core do produto).

| Feature | Story Points | Agentes |
|---------|-------------|---------|
| E3-US01-03: Registro de corrida + extras | 6 | Backend + Frontend |
| E3-US04-05: Listagem + edição/exclusão | 5 | Frontend |
| E4-US01-03: Combustível completo + consumo médio | 8 | Backend + Frontend + Database |
| E5-US01-03: Quilometragem | 6 | Backend + Frontend |

**Gate de Conclusão:**
- Registro de corrida em < 30 segundos (medido em device físico)
- Consumo médio calculado automaticamente após 2 abastecimentos
- Km trabalho vs pessoal registrado e calculado corretamente

---

## Sprint 3 — Dashboard, Metas e Offline (2 semanas, 20 pts)

**Objetivo:** Dashboard com lucro real, meta diária e funcionamento offline.

| Feature | Story Points | Agentes |
|---------|-------------|---------|
| E4-US04-05: Despesas + totais por categoria | 6 | Backend + Frontend |
| E7-US01-05: Dashboard básico (lucro, meta, custo/km) | 13 | Backend + Frontend |
| E9-US01-04: Metas completo | 10 | Backend + Frontend |
| E10-US02-03-05: Dark mode + logout + combustível | 4 | Frontend |

**Gate de Conclusão (MVP Beta):**
- Dashboard mostra lucro real (receitas − despesas)
- Meta diária com progresso em % funcionando
- App funciona completamente offline (sem internet por 24h, registros persistem)
- Sync automático ao reconectar

---

**🎯 MVP Beta — Fim de Agosto 2026 (estimado)**

---

## Sprint 4 — Manutenções e Dashboard Avançado (2 semanas, 20 pts)

**Objetivo:** Alertas de manutenção + indicadores financeiros avançados.

| Feature | Story Points | Agentes |
|---------|-------------|---------|
| E6-US01-02: Registro + histórico manutenção | 5 | Backend + Frontend |
| E6-US03: Alertas automáticos (push notifications) | 4 | Backend + DevOps |
| E6-US04-05: Revisões programadas + custos | 5 | Frontend |
| E7-US06-07: Comparativo plataformas + ticket médio | 8 | Backend + Frontend |

**Gate de Conclusão:**
- Alerta de manutenção disparando corretamente por km
- Gráfico comparativo de plataformas funcionando

---

## Sprint 5 — Dashboard Completo e IA (parcial) (2 semanas, 20 pts)

**Objetivo:** Dashboard completo + início do módulo de IA.

| Feature | Story Points | Agentes |
|---------|-------------|---------|
| E7-US08-09: Depreciação + gráfico diário | 8 | Backend + Frontend |
| E8-US01-02: Chat IA básico + contexto do usuário | 13 | Backend + DevOps (Edge Function) |

**Gate de Conclusão:**
- Depreciação calculada e exibida no dashboard
- Chat de IA respondendo 6 perguntas sugeridas corretamente

---

## Sprint 6 — IA Completo, Polish e v1.0 (2 semanas, 14 pts)

**Objetivo:** IA refinada, bugs corrigidos, v1.0 pronta para lançamento.

| Feature | Story Points | Agentes |
|---------|-------------|---------|
| E8-US04: Perguntas sugeridas no chat | 2 | Frontend |
| E1-US02: Apple Sign-In iOS | 3 | Backend + Frontend |
| Polish: animações, empty states, error handling | 5 | Frontend |
| Bug bash: testes em devices físicos Android + iOS | 4 | QA |

**Gate de Conclusão (v1.0):**
- NPS ≥ 40 (beta testers)
- 0 crash rate em sessão normal
- Cobertura de testes ≥ 80%
- App submetido para App Store + Google Play

---

**🚀 v1.0 — Fim de Outubro 2026 (estimado)**

---

## Marcos Principais

| Marco | Data Estimada | Critério de Sucesso |
|-------|--------------|-------------------|
| Sprint 0 completo | 07 Jul 2026 | CI verde, login funcionando |
| Sprint 1 completo | 21 Jul 2026 | Onboarding funcional |
| Sprint 2 completo | 04 Ago 2026 | Registro de corrida em < 30s |
| **MVP Beta** | **18 Ago 2026** | Lucro real calculado, offline funciona |
| Sprint 4 completo | 15 Set 2026 | Alertas de manutenção ativos |
| Sprint 5 completo | 29 Set 2026 | IA respondendo perguntas |
| **v1.0** | **13 Out 2026** | Nas stores, NPS ≥ 40 |

---

## Dependências Críticas do Cronograma

| Dependência | Bloqueia | Mitigação |
|------------|---------|-----------|
| Supabase Auth configurado | Sprint 1 | Sprint 0 obrigatório primeiro |
| Schema DB criado | Sprint 1, 2 | Sprint 0 inclui migrations completas |
| Consumo calculado (Sprint 2) | Dashboard custo/km (Sprint 3) | Manter sequência |
| Receitas + Despesas (Sprint 2-3) | IA (Sprint 5) | IA precisa de dados para ser útil |
| ANTHROPIC_API_KEY configurada | Sprint 5 | DevOps no Supabase Vault no Sprint 0 |
