# Architecture

_Atualizado pelo Architect Agent. Consulte antes de qualquer decisão técnica._

---

## Visão Geral do Sistema

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter App                          │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ Presentation│  │   Domain     │  │    Data      │  │
│  │  (Widgets)  │→ │  (Entities   │→ │(Repositories │  │
│  │  (Riverpod) │  │  Use Cases)  │  │  + Sources)  │  │
│  └─────────────┘  └──────────────┘  └──────┬───────┘  │
└─────────────────────────────────────────────┼───────────┘
                                              │
              ┌───────────────────────────────┤
              ↓                               ↓
   ┌──────────────────┐            ┌──────────────────┐
   │  Local SQLite    │            │  Backend próprio  │
   │  (Drift ORM)     │◄──sync────►│  (Python/FastAPI  │
   │  Offline-First   │            │  + Postgres)      │
   └──────────────────┘            └────────┬─────────┘
                                              │
                                   ┌──────────────────┐
                                   │  Claude API       │
                                   │  (chamada server- │
                                   │   side pela API)  │
                                   └──────────────────┘
```

## Camadas e Responsabilidades

### Presentation Layer (`src/features/*/presentation/`)
- Widgets Flutter (stateless preferível)
- State management via Riverpod (StateNotifier / AsyncNotifier)
- Sem lógica de negócio — delega para Use Cases via providers
- Componentes do design system em `src/core/ui/`

### Domain Layer (`src/features/*/domain/`)
- Entidades puras (sem dependências externas)
- Use Cases (um por operação de negócio)
- Interfaces de repositórios (abstrações)
- Domain Events para operações críticas
- Zero imports de Flutter ou de clientes de rede (Dio/ApiClient) nesta camada

### Data Layer (`src/features/*/data/`)
- Implementações dos repositórios
- Data Sources: `local/` (Drift) e `remote/` (`ApiClient` → backend FastAPI próprio)
- Mappers: entidade de domínio ↔ modelo de dados
- Sync Service: coordena local ↔ remote

### Core (`src/core/`)
```
src/core/
  ui/           — design system, temas, widgets globais
  network/      — ApiClient (Dio), AuthSession, interceptors
  database/     — banco Drift, migrations locais
  auth/         — serviço de autenticação
  ai/           — cliente Claude API
  utils/        — extensões, formatadores
  errors/       — tipos de erro e tratamento
  sync/         — motor de sincronização offline
```

## Organização Feature First

```
src/features/
  auth/
    domain/       entities/, use_cases/, repositories/
    data/         repositories/, sources/, models/
    presentation/ pages/, widgets/, providers/
  dashboard/
  trips/          (corridas)
  expenses/       (despesas)
  mileage/        (quilometragem)
  maintenance/    (manutenções)
  goals/          (metas)
  ai_chat/        (módulo IA)
  reports/        (relatórios)
  vehicles/       (veículos)
  platforms/      (plataformas)
  settings/       (configurações)
```

## Padrões Aprovados

| Padrão | Contexto | Referência |
|--------|---------|------------|
| Repository Pattern | Abstração de fontes de dados | ADR-0004 |
| Use Case (Interactor) | Uma classe por operação de negócio | ADR-0004 |
| Result Type | Erros explícitos sem exceções não tratadas | CODING_STANDARDS.md |
| Riverpod AsyncNotifier | State management para dados assíncronos | — |
| Drift + migrations | SQLite local com versionamento | ADR-0005 |
| RLS (Row Level Security) | Isolamento de dados por usuário no Postgres, via role de baixo privilégio dedicada | ADR-0006 |
| Optimistic UI | Atualiza local imediatamente, sincroniza depois | ADR-0005 |
| Soft Delete | Registros marcados como deleted_at, nunca removidos fisicamente | — |

## Anti-Padrões Proibidos

| Anti-padrão | Por quê proibido | ADR |
|-------------|-----------------|-----|
| Lógica de negócio em Widget | Viola Clean Architecture | ADR-0004 |
| Acesso direto ao `ApiClient`/`AuthSession` na Presentation (fora de providers dedicados como `currentUserIdProvider`) | Viola separação de camadas | ADR-0004 |
| Singleton global mutable | Dificulta testes e sync | — |
| Hard delete de dados financeiros | Requisito de auditoria + LGPD | — |
| Secrets no código-fonte | Risco de segurança | — |
| `dynamic` ou `var` sem tipo explícito no Dart | Dificulta manutenção | CODING_STANDARDS.md |

## Modelo de Segurança

- **Auth:** JWT próprio (access curto + refresh rotativo/revogável), emitido pelo backend após validar OAuth (Google/Apple)
- **RLS:** Todas as tabelas de dados do usuário têm policies que filtram por `current_setting('app.current_user_id', true)::uuid`; a API roda com uma role Postgres de baixo privilégio dedicada (não a role dona das tabelas), senão o Postgres ignora RLS silenciosamente
- **Dados locais:** SQLite não criptografado (dados em device seguro); sincronização via HTTPS
- **Secrets:** Nunca no código — variáveis de ambiente (`.env`, nunca commitado)
- **LGPD:** Dados pessoais mínimos; direito ao esquecimento via `delete_account` procedure
- **API IA:** Nunca enviar PII bruto para Claude API — sanitizar antes

## Estratégia Offline First

```
Write:  Escreve local → marca como pending_sync → UI atualiza imediatamente
Read:   Lê do local (sempre rápido)
Sync:   Push fire-and-forget → PUT/DELETE no backend próprio → em sucesso: marca
        synced; em falha: reporta ao Sentry, tenta de novo na próxima escrita
        (sem fila de retry dedicada ainda — ver limitações conhecidas em ADR-0006)
```

## Fluxo de Dados — Registro de Corrida

```
User input → TripPage widget
  → AddTripNotifier (Riverpod)
    → AddTripUseCase
      → TripRepository.save(trip)
        → LocalTripDataSource.insert(trip) [Drift, síncrono]
        → SyncQueue.add(trip.id) [async]
  → UI atualiza (optimistic)
  [background]
  → TripRepositoryImpl._doSync → ApiClient PUT /api/v1/trips/{id} [backend próprio]
  → SyncQueue.remove(trip.id)
```

## Tecnologia — Decisões Pendentes

| Item | Opções | Status |
|------|--------|--------|
| Modelo Claude (chat IA) | Haiku 4.5 vs Sonnet 4.6 | Aberto |
| Conflict resolution strategy | Last-write-wins vs Merge | Aberto |
| Charting library | fl_chart vs syncfusion | Aberto |
