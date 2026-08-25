# Prompt Library

_Consulte ANTES de criar qualquer prompt do zero. Use `{{VARIÁVEL}}` para substituição._

---

## Índice

1. [CRUD — Flutter + backend FastAPI](#1-crud--flutter--backend-fastapi)
2. [REST API — Endpoint FastAPI](#2-rest-api--endpoint-fastapi)
3. [Flutter Widget — Feature Screen](#3-flutter-widget--feature-screen)
4. [Flutter Widget — Reusable Component](#4-flutter-widget--reusable-component)
5. [React Component (futuro)](#5-react-component-futuro)
6. [Node.js Service (futuro)](#6-nodejs-service-futuro)
7. [Python Module (futuro)](#7-python-module-futuro)
8. [Test Suite — Dart/Flutter](#8-test-suite--dartflutter)
9. [Refactoring](#9-refactoring)
10. [Performance Optimization](#10-performance-optimization)
11. [Database Migration — PostgreSQL (backend/migrations)](#11-database-migration--postgresql-backendmigrations)
12. [Security Hardening](#12-security-hardening)

---

## 1. CRUD — Flutter + backend FastAPI

**Use quando:** Criar operações completas de criação, leitura, atualização e exclusão para uma entidade.

**Variáveis:**
- `{{ENTITY_NAME}}` — ex: `Trip`, `Expense`, `Vehicle`
- `{{TABLE_NAME}}` — ex: `trips`, `expenses`, `vehicles`
- `{{FIELDS_WITH_TYPES}}` — ex: `amount: double, platform_id: String, trip_date: DateTime`
- `{{VALIDATION_RULES}}` — ex: `amount > 0, platform_id obrigatório, trip_date não futura`
- `{{SOFT_DELETE}}` — `true` ou `false`

```
Implemente um módulo CRUD completo para a entidade {{ENTITY_NAME}} no projeto Driver Finance AI.

Stack: Flutter/Dart (Clean Architecture, Riverpod, Drift local) + backend próprio
Python/FastAPI (asyncpg, Postgres self-hosted).

Entidade:
- Nome: {{ENTITY_NAME}}
- Tabela: {{TABLE_NAME}}
- Campos: {{FIELDS_WITH_TYPES}}
- Validações: {{VALIDATION_RULES}}
- Soft delete: {{SOFT_DELETE}}

Estrutura a criar (Feature First):
lib/features/[feature]/
  domain/
    entities/{{entity_name}}.dart           — entidade pura
    repositories/{{entity_name}}_repository.dart — interface
    use_cases/add_{{entity_name}}.dart
    use_cases/get_{{entity_name}}s.dart
    use_cases/update_{{entity_name}}.dart
    use_cases/delete_{{entity_name}}.dart
  data/
    repositories/{{entity_name}}_repository_impl.dart — Drift local + ApiClient remoto
  presentation/
    providers/{{entity_name}}_provider.dart  — Riverpod AsyncNotifier
    pages/{{entity_name}}_list_page.dart
    pages/{{entity_name}}_form_page.dart
    widgets/{{entity_name}}_card.dart

backend/app/resources/{{table_name}}.py — router FastAPI (ver trips.py como referência)
backend/migrations/{{NNNN}}_create_{{table_name}}.sql

Padrões obrigatórios:
- Use Either<Failure, T> para todos os use cases
- Drift table com todas as colunas necessárias incluindo soft delete
- RLS no Postgres (policy: current_setting('app.current_user_id', true)::uuid = user_id)
- Offline First: escreve local → `PUT /api/v1/{{table_name}}/{id}` fire-and-forget via `ApiClient`
  (falha de sync vai para `ApiClient.reportSyncFailure`, nunca descartada silenciosamente)
- Riverpod: AsyncNotifier com estados loading/data/error

Consulte KNOWLEDGE_BASE.md antes de criar. Consulte CODING_STANDARDS.md para nomenclatura.
Saída: apenas código com paths. Sem prosa. Inclua stubs de teste (pytest no backend, flutter_test no app).
```

---

## 2. REST API — Endpoint FastAPI

**Use quando:** Criar endpoint novo no backend (`backend/app/resources/` ou `backend/app/{domínio}/`).

**Variáveis:**
- `{{ENDPOINT_NAME}}` — ex: `monthly-summary`, `platform-stats`
- `{{HTTP_METHOD}}` — `GET`, `POST`, `PUT`, `DELETE`
- `{{PARAMETERS}}` — path/query/body params
- `{{RETURN_SHAPE}}` — schema Pydantic de resposta
- `{{BUSINESS_LOGIC}}` — descrição da lógica
- `{{AUTH_REQUIREMENT}}` — `authenticated` (via `Depends(current_user_id)`) ou público

```
Crie um endpoint {{HTTP_METHOD}} `/api/v1/{{ENDPOINT_NAME}}` no backend FastAPI.

Parâmetros: {{PARAMETERS}}
Retorno: {{RETURN_SHAPE}}
Auth: {{AUTH_REQUIREMENT}}
Lógica: {{BUSINESS_LOGIC}}

Produza:
1. Router em backend/app/resources/{{resource_name}}.py (ou novo módulo, seguindo o
   padrão de backend/app/auth/router.py e backend/app/resources/trips.py)
2. Schema(s) Pydantic para request/response
3. Query via asyncpg usando `Depends(authenticated_conn)` (RLS já escopa por usuário)
   e `Depends(current_user_id)` quando precisar do id explicitamente
4. Tratamento de erro: deixe `asyncpg.PostgresError` propagar (o handler global em
   main.py já mapeia para 400); use HTTPException para 401/403/404 explícitos
5. Registre o router em backend/app/main.py

Padrão de erro (automático via exception handler global):
{ "detail": "mensagem" }

Teste em backend/tests/test_{{resource_name}}.py com pytest + httpx.AsyncClient
(ver test_resources.py para o padrão de fixtures `client`/`authed_client`).

Consulte ARCHITECTURE.md (seção de segurança e RLS) antes de implementar.
```

---

## 3. Flutter Widget — Feature Screen (Página completa)

**Use quando:** Criar uma página completa de uma feature.

**Variáveis:**
- `{{SCREEN_NAME}}` — ex: `DashboardPage`, `AddTripPage`
- `{{WIREFRAME}}` — conteúdo do wireframe da tela
- `{{USE_CASES_AVAILABLE}}` — lista de use cases já implementados
- `{{STATE_SHAPE}}` — dados que a tela precisa mostrar
- `{{NAVIGATION_ACTIONS}}` — para onde pode navegar

```
Crie a tela {{SCREEN_NAME}} para o app Driver Finance AI em Flutter.

Wireframe: {{WIREFRAME}}
Use Cases disponíveis: {{USE_CASES_AVAILABLE}}
Estado da tela: {{STATE_SHAPE}}
Navegação: {{NAVIGATION_ACTIONS}}

Estrutura:
src/features/[feature]/presentation/
  pages/{{screen_name_snake}}.dart          — página principal
  providers/{{feature}}_notifier.dart       — AsyncNotifier (se necessário)
  widgets/                                  — widgets específicos desta tela

Regras:
- ConsumerWidget (Riverpod) para toda tela que lê estado
- Separar em widgets menores (máx 50 linhas por widget)
- Loading state: CircularProgressIndicator centralizado
- Error state: mensagem + botão de retry
- Empty state: ilustração + call to action
- Sem lógica de negócio — delegar ao provider → use case
- Acessibilidade: semanticLabel onde necessário, tamanho mínimo de toque 44px
- Respeitar tokens de design system: cores, espaçamento, tipografia

Consulte planning/11-DESIGN_SYSTEM.md para tokens e componentes disponíveis.
Saída: código com paths. Sem prosa.
```

---

## 4. Flutter Widget — Reusable Component

**Use quando:** Criar um widget reutilizável no design system.

**Variáveis:**
- `{{WIDGET_NAME}}` — ex: `MetricCard`, `PlatformBadge`, `CurrencyField`
- `{{WIDGET_PURPOSE}}` — o que ele exibe/faz
- `{{PARAMETERS}}` — props que recebe
- `{{VARIANTS}}` — variações visuais (ex: small/large, success/warning/error)

```
Crie o widget reutilizável {{WIDGET_NAME}} para o design system do Driver Finance AI.

Propósito: {{WIDGET_PURPOSE}}
Parâmetros: {{PARAMETERS}}
Variantes: {{VARIANTS}}

Localização: src/core/ui/components/{{widget_name_snake}}.dart

Regras:
- StatelessWidget ou ConsumerWidget (nunca StatefulWidget para UI pura)
- const constructor obrigatório
- Parâmetros tipados, required onde não há default razoável
- Documentar parâmetros não óbvios com comentário de 1 linha
- Testar com golden test (1 screenshot por variante)
- Funciona em dark mode e light mode
- Responde a MediaQuery.textScaleFactor

Saída: widget + golden test. Sem prosa.
```

---

## 5. React Component (futuro)

**Use quando:** Painel web admin ou landing page em React.

```
Crie o componente React {{COMPONENT_NAME}} para o painel admin do Driver Finance AI.

Props: {{PROPS_DEFINITION}}
Estado: {{STATE_SHAPE}}
Styling: Tailwind CSS
Fetching: React Query / SWR

Regras:
- Functional component com TypeScript strict
- Props tipadas com interface (não type)
- Sem any implícito
- Acessibilidade: ARIA roles, keyboard navigation
- Teste com React Testing Library: happy path + 1 failure

Saída: .tsx + .test.tsx. Sem prosa.
```

---

## 6. Node.js Service (futuro)

**Use quando:** Criar serviço backend Node/TypeScript independente.

```
Implemente o serviço Node.js/TypeScript: {{SERVICE_NAME}}

Responsabilidade: {{SINGLE_RESPONSIBILITY}}
Dependências injetadas: {{DEPENDENCY_LIST}}
Métodos públicos: {{METHOD_SIGNATURES}}
Tratamento de erro: Result<T, E> ou throw com tipos tipados
Logging: pino com campos de contexto: {{CONTEXT_FIELDS}}
Config via env: {{ENV_VARS}}

Regras: TypeScript strict, sem any, dependency injection manual (sem framework DI).
Saída: implementação + unit tests (Jest). Sem prosa.
```

---

## 7. Python Module (futuro)

**Use quando:** Scripts de processamento, ML pipeline, ou worker Python.

```
Implemente o módulo Python: {{MODULE_NAME}}

Propósito: {{PURPOSE}}
Python: 3.12+
Type hints: obrigatório em toda função pública
Dependências: {{PACKAGE_LIST}}
Interface pública: {{FUNCTION_SIGNATURES}}
Exceções customizadas: {{CUSTOM_EXCEPTIONS}}
Logging: structlog com fields: {{CONTEXT_FIELDS}}

Regras: PEP8, black formatter, mypy strict, sem globals mutáveis.
Saída: implementação + pytest. Sem prosa.
```

---

## 8. Test Suite — Dart/Flutter

**Use quando:** Criar testes para código já implementado.

**Variáveis:**
- `{{SUBJECT}}` — o que está sendo testado
- `{{TEST_TYPE}}` — `unit`, `widget`, `integration`, `golden`
- `{{HAPPY_PATH_SCENARIOS}}` — cenários de sucesso
- `{{FAILURE_SCENARIOS}}` — cenários de falha
- `{{MOCKS_NEEDED}}` — dependências a mockar

```
Crie testes {{TEST_TYPE}} para {{SUBJECT}} no projeto Driver Finance AI.

Framework: flutter_test + mocktail
Código a testar: {{IMPLEMENTATION_CONTENT}}

Cenários de sucesso: {{HAPPY_PATH_SCENARIOS}}
Cenários de falha: {{FAILURE_SCENARIOS}}
Mocks necessários: {{MOCKS_NEEDED}}

Regras:
- Nomenclatura: test_[o_que]_[quando]_[esperado]
- Arrange / Act / Assert separados por linha em branco
- Sem acesso a banco real ou API real
- setUp() para inicializar SUT e mocks
- tearDown() se houver recursos a liberar
- Meta: cobrir todos os cenários listados acima + edge cases óbvios

Localização: tests/[feature]/[layer]/[subject]_test.dart

Saída: apenas código de teste. Sem prosa.
```

---

## 9. Refactoring

**Use quando:** Melhorar código existente sem mudar comportamento externo.

```
Refatore {{TARGET_FILE}} com objetivo: {{REFACTORING_GOAL}}.

Problema atual: {{PROBLEM_DESCRIPTION}}
Padrão a aplicar: {{PATTERN_FROM_ARCHITECTURE}}
Interface pública: deve permanecer idêntica
Testes que devem continuar passando: {{TEST_FILE_LIST}}

Restrições:
- Não adicione funcionalidade nova
- Não quebre interfaces existentes
- Siga CODING_STANDARDS.md
- Adicione comentário no topo do arquivo refatorado explicando o que mudou e por quê

Saída: arquivo refatorado completo. Sem prosa.
```

---

## 10. Performance Optimization

**Use quando:** Otimizar operação específica com baseline medido.

```
Otimize {{TARGET}} para atingir {{PERFORMANCE_GOAL}}.

Baseline atual: {{CURRENT_METRIC}}
Meta: {{TARGET_METRIC}}
Dados de profiling: {{PROFILE_RESULTS}}

Abordagens permitidas: {{APPROVED_APPROACHES}}
Proibido: {{FORBIDDEN_APPROACHES}}

Regras:
- Não altere interfaces públicas
- Documente cada otimização com comentário explicando o porquê
- Adicione benchmark test se ainda não existir

Saída: arquivos modificados. Sem prosa.
```

---

## 11. Database Migration — PostgreSQL (backend/migrations)

**Use quando:** Criar ou alterar schema do banco de dados.

**Variáveis:**
- `{{MIGRATION_PURPOSE}}` — ex: `add_tips_to_trips`
- `{{TABLE_CHANGES}}` — tabelas criadas/alteradas
- `{{ROW_COUNT_ESTIMATE}}` — estimativa de linhas afetadas
- `{{ZERO_DOWNTIME}}` — `true` ou `false`

```
Crie migração Postgres: {{MIGRATION_PURPOSE}}

Mudanças:
- Tabelas: {{TABLE_CHANGES}}
- Colunas: {{COLUMN_CHANGES}}
- Índices: {{INDEX_CHANGES}}
- Constraints: {{CONSTRAINT_CHANGES}}

Transformação de dados: {{DATA_TRANSFORMATION_IF_ANY}}
Linhas estimadas afetadas: {{ROW_COUNT_ESTIMATE}}
Zero-downtime obrigatório: {{ZERO_DOWNTIME}}

Regras:
- Toda nova tabela: id UUID PK, user_id FK REFERENCES users(id) ON DELETE CASCADE,
  created_at, updated_at, deleted_at
- RLS obrigatória: policy usando current_setting('app.current_user_id', true)::uuid = user_id
  (ver backend/migrations/0004_create_vehicles.sql como referência)
- GRANT automático para a role driver_finance_app via ALTER DEFAULT PRIVILEGES já
  configurado em 0012_create_app_role.sql — não precisa repetir por migration
- Índice em toda FK e coluna frequente em WHERE
- Comentários SQL nas regras de negócio não óbvias
- Este runner (backend/tool/migrate.py) não tem Down migration automático —
  migrations são sempre forward-only; para reverter, escreva uma nova migration
  numerada que desfaz a anterior

Localização: backend/migrations/{{NNNN}}_{{MIGRATION_PURPOSE}}.sql (próximo número
sequencial disponível)

Saída: SQL da migration. Sem prosa.
```

---

## 12. Security Hardening

**Use quando:** Aplicar melhorias de segurança a componente existente.

```
Aplique hardening de segurança em {{TARGET_COMPONENT}}.

Ameaças a mitigar: {{THREATS}}
Requisitos de segurança: {{SECURITY_REQUIREMENTS}}
Mudanças em auth/authz: {{AUTH_CHANGES}}
Validação de input: {{VALIDATION_RULES}}
O que deve ser logado: {{AUDIT_LOG_ITEMS}}

Regras:
- Não quebre funcionalidade existente
- Consulte REVIEW_CHECKLIST.md Seção 2 como guia
- Secrets: nunca no código — use env vars (`.env`, nunca commitado)
- Dados enviados para Claude API: sanitize antes (remova nome, CPF, telefone)
- Erros ao usuário: nunca exponha detalhes internos

Saída: arquivos modificados + lista de mudanças de segurança aplicadas. Sem prosa.
```
