# Architectural Decision Records

_ADRs documentam decisões arquiteturais significativas. Consulte `.ai/DECISIONS.md` para o índice._

## Template de ADR

```markdown
# ADR-[número]: [Título]

## Status
[Proposed | Accepted | Deprecated | Superseded by ADR-N]

## Data
[YYYY-MM-DD]

## Contexto
[Qual é a situação que força uma decisão? Quais restrições existem?
3-6 frases. Tom neutro e factual.]

## Decisão
[O que foi decidido? Uma afirmação clara e direta.
Em seguida, detalhamento da abordagem escolhida.]

## Justificativa
[Por que esta opção em vez das alternativas? Quais critérios foram usados?]

## Alternativas Consideradas
| Alternativa | Por que Rejeitada |
|-------------|------------------|

## Consequências
### Positivas
- [benefício 1]

### Negativas
- [custo/desvantagem 1]

### Riscos
- [risco 1]

## Conformidade
[Como verificamos que esta decisão está sendo seguida?
O que o Review Agent deve checar?]

## ADRs Relacionados
- ADR-N: [título] ([como se relaciona])

## Originado por
Task: [TASK-ID] / Plan: [PLAN-ID] / [Outro contexto]
```

## Lista de ADRs

| ID | Título | Status |
|----|--------|--------|
| [ADR-0001](ADR-0001-adopt-ai-multiagent-framework.md) | Adotar Framework Multi-Agente Baseado em Prompts | Accepted |
| [ADR-0002](ADR-0002-flutter-cross-platform.md) | Flutter como Plataforma UI Cross-Platform | Accepted |
| [ADR-0003](ADR-0003-supabase-postgresql.md) | Supabase + PostgreSQL como Backend | Superseded by ADR-0006 |
| [ADR-0004](ADR-0004-clean-architecture-ddd-feature-first.md) | Clean Architecture + DDD + Feature First | Accepted |
| [ADR-0005](ADR-0005-offline-first-sqlite-sync.md) | Offline First com SQLite (Drift) + Sync com backend próprio | Accepted |
| [ADR-0006](ADR-0006-postgres-backend-proprio-python.md) | Backend próprio (Python/FastAPI) + Postgres self-hosted, substituindo Supabase | Accepted |
