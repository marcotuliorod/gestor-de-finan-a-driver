# Task: TASK-20260626-sprint0-setup

## Status
IN_PROGRESS

## Criado em
2026-06-26

## Agente Designado
DevOps Agent + Backend Agent + Database Agent

## Plano de Origem
planning/15-SCHEDULE.md (Sprint 0)

## Descrição
Setup completo de infraestrutura: projeto Flutter com Feature First, projeto Supabase com todas as migrations, GitHub Actions CI/CD, e Edge Function stub de IA.

## Critérios de Aceite
- [x] Projeto Flutter criado com estrutura Feature First
- [x] pubspec.yaml com todas as dependências
- [x] analysis_options.yaml configurado
- [x] .gitignore configurado (exclui arquivos gerados)
- [x] GitHub Actions: lint + test pipeline
- [x] GitHub Actions: build APK (Android) em merges na main
- [x] Supabase projeto criado (driver-finance-ai, sa-east-1)
- [x] Migrations 0001–0010 criadas
- [x] RLS habilitada em todas as tabelas
- [x] Trigger updated_at em todas as tabelas com UPDATE
- [x] Edge Function ai-chat deployada (stub)
- [x] View monthly_summary criada
- [ ] Auth Google configurado (requer credenciais OAuth do usuário)
- [ ] Auth Apple configurado (requer Apple Developer account)
- [ ] ANTHROPIC_API_KEY no Supabase Vault (requer chave do usuário)
- [ ] SENTRY_DSN configurado (requer conta Sentry)
- [ ] GitHub Secrets: SUPABASE_URL, SUPABASE_ANON_KEY, SENTRY_DSN

## Scorecard de Complexidade
```yaml
complexity:
  ui: 1
  backend: 2
  database: 3
  apis: 1
  ai_ml: 0
  security: 2
  performance: 1
  infrastructure: 3
  integrations: 1
  total: 14
  tier: Medium
```

## Orçamento de Tokens
```yaml
token_budget:
  tier: Medium
  score: 14
  total_tokens: 12000
  input_cap: 8000
  output_cap: 4000
  remaining: 2000
  cost_estimate_usd: 0.05
```

## Context Package
- planning/06-TECHNICAL_ARCHITECTURE.md
- planning/08-DATA_MODEL.md
- planning/09-API_CONTRACTS.md
- planning/15-SCHEDULE.md
- .ai/CODING_STANDARDS.md

## Dependências
- Bloqueado por: nenhuma
- Desbloqueia: TASK-Sprint1 (Auth + Onboarding)

## Output do Agente

### Supabase
- Projeto: driver-finance-ai (ID: ccsylpjriyaypjpdccqx)
- URL: https://ccsylpjriyaypjpdccqx.supabase.co
- Região: sa-east-1 (São Paulo)
- Migrations aplicadas: 0001–0010

### Flutter
- pubspec.yaml com todas as dependências
- Estrutura Feature First completa
- Drift tabelas: Vehicles, Platforms, Trips, Expenses, FuelRecords, MileageRecords, MaintenanceRecords, Goals, AiConversations, AiMessages, SyncQueue
- GoRouter com todas as rotas placeholder
- AppTheme light + dark
- AppColors, AppTypography definidos
- Feature stubs: Auth, Dashboard, Trips, Expenses, Reports, AiChat, Settings

### CI/CD
- .github/workflows/ci.yml
- Jobs: analyze-and-test (todo PR) + build-android (merges na main)
- Cobertura 80% gate ativo

### Edge Function
- supabase/functions/ai-chat/index.ts (stub que valida JWT e retorna resposta placeholder)

## Pendências para o usuário
1. **Google OAuth**: criar credenciais em console.cloud.google.com → adicionar a Supabase Auth Providers
2. **Apple Sign-In**: configurar em developer.apple.com → adicionar a Supabase Auth Providers
3. **GitHub Secrets**: adicionar SUPABASE_URL, SUPABASE_ANON_KEY, SENTRY_DSN no repositório
4. **ANTHROPIC_API_KEY**: adicionar ao Supabase Vault quando tiver a chave

## Métricas
```yaml
metrics:
  input_tokens_used: 8000
  output_tokens_used: 4000
  estimated_cost_usd: 0.05
  duration_minutes: 15
  files_changed:
    - pubspec.yaml
    - analysis_options.yaml
    - .gitignore
    - .github/workflows/ci.yml
    - lib/main.dart
    - lib/app.dart
    - lib/core/router/app_router.dart
    - lib/core/errors/failures.dart
    - lib/core/ui/theme/app_colors.dart
    - lib/core/ui/theme/app_typography.dart
    - lib/core/ui/theme/app_theme.dart
    - lib/core/ui/components/app_shell.dart
    - lib/core/network/supabase_client.dart
    - lib/core/database/app_database.dart
    - lib/core/database/tables/ (11 files)
    - lib/features/ (8 feature stubs)
    - test/widget_test.dart
    - supabase/migrations/0001-0010.sql
    - supabase/functions/ai-chat/index.ts
  agent: DevOps Agent
  success: true
  escalated: false
  escalation_reason: ""
```
