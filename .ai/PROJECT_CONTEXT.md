# Project Context

_Documento vivo — atualizado pelo Documentation Agent ao final de cada ciclo._
_Última atualização: 2026-06-26 | Fase: Implementation — Sprint 8 Completo_

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
- **Sprint atual:** Sprint 9 (a iniciar)
- **PRs mergeados:** #1 → #13 (todos com CI verde)
- **Features implementadas:** ver inventário abaixo
- **Features pendentes:** ver backlog residual abaixo

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

## Backlog Residual (não implementado)

| ID | Feature | MoSCoW | Pts | Obs |
|----|---------|--------|-----|-----|
| E6-US03 | Alertas push de manutenção (por km ou data) | M | 4 | Requer push notification setup |
| E7-US09 | Gráfico de lucro diário no dashboard | S | 4 | fl_chart disponível |
| E7-US04 | Ganho por hora (requer registro de horas) | S | 3 | Depende de campo de horas em Trip |
| E4-US06 | Despesas recorrentes (IPVA, seguro) | S | 3 | |
| E9-US03 | Push notification ao atingir meta diária | S | 3 | Junto com E6-US03 |
| E10-US01 | Edição de perfil (nome, foto) | S | 2 | |
| E5-US04 | Sugestão automática de odômetro | S | 2 | |
| E1-US02 | Apple Sign-In (iOS only) | S | 3 | Bloqueado por Apple Developer |
| E10-US04 | Export CSV de corridas e despesas | C | 4 | Requer share_plus |
| E7-US10 | ROI do veículo | C | 3 | |
| E8-US03 | Histórico de conversas IA | C | 3 | |
| E2-US05 | Plataforma customizada | C | 2 | |

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
| Supabase | Backend, Auth, DB, Edge Functions | Implementado (código) |
| Claude API (Anthropic) | Chat IA via Edge Function | Implementado (código) |
| Google Sign-In | Auth social | Implementado (código) |
| Apple Sign-In | Auth social (iOS) | Pendente |
| Sentry | Monitoramento de erros | Pendente configuração |

## Ações Pendentes do Usuário (infraestrutura)

| Ação | Prioridade |
|------|------------|
| Criar projeto Supabase e executar migrations | Alta |
| Configurar Google OAuth no Supabase Auth | Alta |
| Adicionar ANTHROPIC_API_KEY ao Supabase Vault | Alta |
| Deploy da Edge Function `ai-chat` | Alta |
| Adicionar SUPABASE_URL + SUPABASE_ANON_KEY ao GitHub Secrets | Alta |
| Configurar Sentry DSN | Média |

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
