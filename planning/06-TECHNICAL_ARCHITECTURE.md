# Arquitetura Técnica — Driver Finance AI

_Gerado pelo Architect Agent | 2026-06-26 | Ver também: ARCHITECTURE.md, ADR-0002 a ADR-0006_

> **⚠️ Documento histórico/pré-implementação.** Escrito antes do Sprint 1, quando o
> plano de backend era Supabase. O projeto migrou para backend próprio em
> Python/FastAPI + Postgres self-hosted (ver `.ai/ARCHITECTURE.md` e `adr/ADR-0006`
> para o estado atual real) — as menções a Supabase abaixo (SDK, Edge Functions,
> Realtime, Vault) não se aplicam mais.

---

## Visão Geral

```
┌─────────────────────────────────────────────────────────────────┐
│                       Flutter App                               │
│  ┌────────────────────────────────────────────────────────┐    │
│  │                 Presentation Layer                      │    │
│  │  Pages │ Widgets │ Riverpod Providers │ Navigation     │    │
│  └──────────────────────┬─────────────────────────────────┘    │
│                         │ usa Use Cases via Providers           │
│  ┌──────────────────────▼─────────────────────────────────┐    │
│  │                   Domain Layer                          │    │
│  │  Entities │ Value Objects │ Use Cases │ Repo Interfaces │    │
│  │  Domain Events │ Failures │ Business Rules              │    │
│  └──────────────────────┬─────────────────────────────────┘    │
│                         │ Repository Pattern (interfaces)       │
│  ┌──────────────────────▼─────────────────────────────────┐    │
│  │                    Data Layer                           │    │
│  │  ┌──────────────────┐    ┌────────────────────────┐   │    │
│  │  │  Local Sources   │    │   Remote Sources        │   │    │
│  │  │  Drift (SQLite)  │◄──►│   Supabase Client      │   │    │
│  │  │  SyncQueue       │    │   Edge Functions        │   │    │
│  │  └──────────────────┘    └────────────────────────┘   │    │
│  └────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
         │                              │
         ▼                              ▼
┌──────────────────┐          ┌──────────────────────────┐
│  SQLite Local    │          │       Supabase            │
│  (Drift ORM)     │          │  ┌──────────────────┐    │
│                  │          │  │   PostgreSQL DB   │    │
│  - trips         │  sync ◄──►  │   (com RLS)       │    │
│  - expenses      │          │  └──────────────────┘    │
│  - mileage       │          │  ┌──────────────────┐    │
│  - maintenance   │          │  │   Auth (JWT)      │    │
│  - goals         │          │  └──────────────────┘    │
│  - sync_queue    │          │  ┌──────────────────┐    │
└──────────────────┘          │  │  Edge Functions   │    │
                              │  │  (Deno/TypeScript)│    │
                              │  └────────┬─────────┘    │
                              └───────────┼──────────────┘
                                          │
                                          ▼
                               ┌──────────────────┐
                               │   Claude API      │
                               │   (Anthropic)     │
                               │   AI Chat Module  │
                               └──────────────────┘
```

---

## Stack Completa

| Componente | Tecnologia | Versão |
|-----------|-----------|--------|
| UI Framework | Flutter | 3.24+ |
| Linguagem | Dart | 3.5+ |
| State Management | Riverpod | 2.x (com riverpod_annotation) |
| Código Gerado | build_runner + riverpod_generator | latest |
| Local DB | Drift (SQLite) | 2.x |
| Remote Backend | Supabase | latest |
| Supabase SDK | supabase_flutter | 2.x |
| Auth Social | google_sign_in + sign_in_with_apple | latest |
| HTTP Client | supabase_flutter (interno) | — |
| Navegação | go_router | 14.x |
| Tratamento de Erros | fpdart (Either, Option) | 1.x |
| DI/IoC | Riverpod (providers como DI) | — |
| Charting | fl_chart | 0.68+ |
| Formatação | intl | 0.19+ |
| Testes | flutter_test + mocktail | latest |
| Golden Tests | golden_toolkit | latest |
| Linter | flutter_lints + custom_lint | latest |
| CI/CD | GitHub Actions | — |
| Observabilidade | Sentry | latest |
| IA | Claude API (Anthropic) via Edge Function | — |

---

## Estrutura de Pastas Completa

```
lib/
├── main.dart                    # entry point
├── app.dart                     # MaterialApp + GoRouter setup
├── core/
│   ├── ui/
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── app_colors.dart
│   │   │   └── app_typography.dart
│   │   ├── components/          # design system widgets
│   │   │   ├── metric_card.dart
│   │   │   ├── currency_field.dart
│   │   │   ├── platform_badge.dart
│   │   │   └── ...
│   │   └── extensions/          # BuildContext extensions
│   ├── auth/
│   │   ├── auth_service.dart
│   │   └── auth_provider.dart
│   ├── database/
│   │   ├── app_database.dart    # Drift database
│   │   ├── app_database.g.dart
│   │   └── tables/             # Drift table definitions
│   ├── network/
│   │   └── supabase_client.dart
│   ├── sync/
│   │   ├── sync_service.dart
│   │   └── sync_queue.dart
│   ├── ai/
│   │   └── ai_service.dart      # Claude API via Supabase Edge Function
│   ├── errors/
│   │   ├── failures.dart
│   │   └── exceptions.dart
│   └── utils/
│       ├── currency_formatter.dart
│       ├── date_utils.dart
│       └── validators.dart
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── entities/driver.dart
│   │   │   ├── repositories/auth_repository.dart
│   │   │   └── use_cases/
│   │   │       ├── sign_in_with_google.dart
│   │   │       ├── sign_out.dart
│   │   │       └── delete_account.dart
│   │   ├── data/
│   │   │   ├── repositories/auth_repository_impl.dart
│   │   │   └── sources/supabase_auth_source.dart
│   │   └── presentation/
│   │       ├── pages/login_page.dart
│   │       ├── pages/onboarding_page.dart
│   │       └── providers/auth_provider.dart
│   ├── dashboard/
│   ├── trips/
│   ├── expenses/
│   ├── mileage/
│   ├── maintenance/
│   ├── goals/
│   ├── ai_chat/
│   ├── reports/
│   ├── vehicles/
│   ├── platforms/
│   └── settings/

test/
├── core/
├── features/
│   ├── trips/
│   │   ├── domain/
│   │   └── data/
│   └── ...
└── helpers/
    ├── factories/              # test data factories
    └── mocks/                 # shared mocks

supabase/
├── migrations/               # SQL migrations
└── functions/
    └── ai-chat/
        └── index.ts          # Edge Function — Claude API
```

---

## Fluxo de Sincronização Offline → Online

```
┌─────────────────────────────────────────────────────┐
│                   WRITE FLOW                         │
│                                                      │
│  User Action                                         │
│       │                                              │
│       ▼                                              │
│  UseCase.execute(data)                               │
│       │                                              │
│       ▼                                              │
│  RepositoryImpl.save(entity)                        │
│       │                                              │
│       ├──► LocalSource.insert(model)  [< 50ms]      │
│       │         │                                    │
│       │         └──► SQLite persisted               │
│       │                                              │
│       ├──► SyncQueue.add(id, 'upsert')  [async]     │
│       │                                              │
│       └──► return Right(entity)  [UI updates]       │
│                                                      │
│  [Background Worker — runs every 30s or on reconnect]│
│       │                                              │
│       ▼                                              │
│  SyncService.processQueue()                          │
│       │                                              │
│       ├── SyncQueue.getPending()                     │
│       │                                              │
│       ├── RemoteSource.upsert(model)  [Supabase]    │
│       │     │                                        │
│       │     ├── Success → SyncQueue.markSynced(id)  │
│       │     │                                        │
│       │     └── Failure → retry (max 3, backoff)    │
│       │                                              │
│       └── Conflict → last_write_wins(local, remote) │
└─────────────────────────────────────────────────────┘
```

---

## Fluxo de IA — Chat com Contexto do Usuário

```
User: "Quanto ganhei na Uber este mês?"
        │
        ▼ [Flutter App]
┌──────────────────────────────────┐
│  AIChatUseCase.ask(question)     │
│  → Busca dados do contexto       │
│    (trips, expenses do mês)      │
│  → Cria ContextPayload sanitizado│
│    (sem nome, sem dados pessoais)│
└──────────────────┬───────────────┘
                   │ HTTPS POST
                   ▼
┌──────────────────────────────────┐
│  Supabase Edge Function          │
│  ai-chat/index.ts                │
│                                  │
│  1. Valida JWT do usuário        │
│  2. Verifica payload sanitizado  │
│  3. Monta prompt para Claude     │
│  4. Chama Claude API (Sonnet)    │
│  5. Retorna resposta             │
└──────────────────┬───────────────┘
                   │
                   ▼
┌──────────────────────────────────┐
│  Claude API (Anthropic)          │
│  Modelo: claude-sonnet-4-6       │
│  Contexto: dados do usuário      │
│  Resposta: linguagem natural PT  │
└──────────────────────────────────┘
                   │
                   ▼
        UI: exibe resposta em bolha de chat
```

---

## Padrão de Navegação (GoRouter)

```
/ (raiz)
├── /login                    — LoginPage (pública)
├── /onboarding               — OnboardingPage (primeira vez)
└── /app                      — Shell com BottomNavigationBar
    ├── /app/dashboard        — DashboardPage (home)
    ├── /app/trips            — TripListPage
    │   └── /app/trips/add    — AddTripPage
    ├── /app/expenses         — ExpenseListPage
    │   └── /app/expenses/add — AddExpensePage
    ├── /app/reports          — ReportsPage
    ├── /app/ai               — AIChatPage
    └── /app/settings         — SettingsPage
        ├── /app/settings/vehicle  — VehiclePage
        ├── /app/settings/goals    — GoalsPage
        └── /app/settings/platforms — PlatformsPage
```

---

## Requisitos Não Funcionais e Como São Atendidos

| Requisito | Como é Atendido |
|-----------|----------------|
| < 300ms ops locais | Leitura/escrita via Drift (SQLite) — geralmente < 20ms |
| Offline first | Drift como fonte primária; sync assíncrona |
| LGPD | RLS no Supabase; delete_account procedure; dados mínimos |
| Criptografia em trânsito | HTTPS (Supabase default) |
| Criptografia em repouso | SQLite sem criptografia (device seguro); Supabase criptografa dados em repouso |
| 80% cobertura de testes | flutter_test + mocktail; CI gate no GitHub Actions |
| Escalabilidade | Supabase escala horizontalmente; RLS garante isolamento |
| Observabilidade | Sentry para crashes; Supabase Logs para queries e Edge Functions |
