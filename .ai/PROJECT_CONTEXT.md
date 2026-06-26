# Project Context

_Documento vivo — atualizado pelo Documentation Agent ao final de cada ciclo._
_Última atualização: 2026-06-26 | Fase: Planning Complete_

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
| Armazenamento de estado | Riverpod | — |
| Arquitetura | Clean Architecture + DDD + Feature First | ADR-0004 |
| Estratégia de dados | Offline First + Sync | ADR-0005 |
| Auth | Supabase Auth (social login: Google, Apple) | — |
| IA | Claude API (Anthropic) | — |
| CI/CD | GitHub Actions | — |
| Observabilidade | Sentry + Supabase Logs | — |

## Estado Atual

- **Fase:** Planning Complete
- **Sprint atual:** Sprint 0 (setup)
- **Features implementadas:** nenhuma
- **Features em planejamento:** todas (ver `planning/`)

## Proposta de Valor

> Motoristas sabem quanto recebem das plataformas, mas não sabem quanto realmente lucram.
> O Driver Finance AI transforma receitas, despesas e quilometragem em **lucro real**.

## Objetivos do Produto

1. Lucro diário / semanal / mensal com precisão
2. Custo por quilômetro e ganho por hora
3. Comparativo entre plataformas (Uber vs 99 vs inDrive)
4. Consumo médio e depreciação do veículo
5. Previsão de manutenções com alertas automáticos
6. Metas financeiras com acompanhamento em tempo real
7. IA conversacional respondendo perguntas sobre os dados do motorista

## Restrições e Requisitos Não Funcionais

| Requisito | Valor |
|-----------|-------|
| Tempo de resposta (ops locais) | < 300ms |
| Cobertura de testes | ≥ 80% |
| Conformidade | LGPD |
| Criptografia | em repouso + em trânsito |
| Offline | funcional sem conexão, sincronização automática |
| Escalabilidade | multi-usuário, dados isolados por RLS |

## Modelo de Domínio (alto nível)

```
Driver (Motorista)
  ├── Vehicles (Veículos)
  ├── Platforms (Plataformas: Uber, 99, inDrive...)
  ├── Trips (Corridas/Entregas)
  │     ├── income (receita bruta)
  │     ├── bonuses, tips, promotions
  │     └── platform_ref → Platform
  ├── Expenses (Despesas)
  │     ├── Fuel (Combustível)
  │     ├── Maintenance (Manutenções)
  │     ├── Fixed (IPVA, Seguro, Financiamento...)
  │     └── Variable (Lavagem, Pedágio, Estacionamento...)
  ├── Mileage (Quilometragem)
  │     ├── work_km vs personal_km
  │     └── vehicle_ref → Vehicle
  ├── Goals (Metas)
  │     ├── daily / monthly target
  │     └── progress tracking
  └── AIConversations (Histórico IA)
```

## Artefatos de Planejamento

| Arquivo | Descrição |
|---------|-----------|
| `planning/01-PRODUCT_VISION.md` | Visão do produto e métricas de sucesso |
| `planning/02-ROADMAP.md` | Roadmap por versões (MVP → v1.0 → v2.0) |
| `planning/03-BACKLOG.md` | Backlog completo com MoSCoW |
| `planning/04-PERSONAS.md` | 5 personas de motoristas |
| `planning/05-USER_JOURNEYS.md` | 8 jornadas críticas |
| `planning/06-TECHNICAL_ARCHITECTURE.md` | Arquitetura técnica detalhada |
| `planning/07-DOMAIN_MODEL.md` | Modelo de domínio DDD |
| `planning/08-DATA_MODEL.md` | Schema PostgreSQL completo + SQLite |
| `planning/09-API_CONTRACTS.md` | Contratos Supabase RPC + Edge Functions |
| `planning/10-WIREFRAMES.md` | Wireframes de todas as telas |
| `planning/11-DESIGN_SYSTEM.md` | Design system e tokens |
| `planning/12-TEST_PLAN.md` | Plano de testes com metas de cobertura |
| `planning/13-RISK_MATRIX.md` | Matriz de riscos |
| `planning/14-ESTIMATES.md` | Estimativas por épico |
| `planning/15-SCHEDULE.md` | Cronograma por sprints |

## ADRs Ativos

| ADR | Título | Status |
|-----|--------|--------|
| ADR-0001 | Adotar framework multi-agente | Accepted |
| ADR-0002 | Flutter como plataforma UI | Accepted |
| ADR-0003 | Supabase + PostgreSQL como backend | Accepted |
| ADR-0004 | Clean Architecture + DDD + Feature First | Accepted |
| ADR-0005 | Offline First com SQLite + sync Supabase | Accepted |

## Dependências Externas

| Serviço | Uso | Status |
|---------|-----|--------|
| Supabase | Backend, Auth, DB, Storage | Planejado |
| Claude API (Anthropic) | Módulo de IA conversacional | Planejado |
| Google Sign-In | Auth social | Planejado |
| Apple Sign-In | Auth social (iOS) | Planejado |
| Sentry | Monitoramento de erros | Planejado |

## Questões em Aberto

| Questão | Responsável | Prioridade |
|---------|-------------|------------|
| Modelo Claude a usar (Haiku vs Sonnet) para custo-benefício do chat IA | Architect | Alta |
| Estratégia de conflito offline (last-write-wins vs merge) | Architect | Alta |
| Política de retenção de dados para LGPD | — | Média |

## Log de Alterações Recentes

| Data | Alteração | Agente |
|------|-----------|--------|
| 2026-06-26 | Inicialização do framework e planejamento completo | Framework Init |
