# Tasks Directory

_Rastreamento de tarefas com métricas. Gerenciado pelo Planner Agent e Integration Agent._

## Formato de Arquivo de Tarefa

Toda tarefa tem seu próprio arquivo: `TASK-YYYYMMDD-[slug].md`

### Status Possíveis
- `PENDING` — aguardando início
- `IN_PROGRESS` — agente trabalhando
- `ESCALATED` — aguardando Planner resolver bloqueio
- `REVIEW` — aguardando Review Agent
- `COMPLETE` — concluído e mergeado
- `BLOCKED` — reprovado 2x no Review; aguarda decisão
- `FAILED` — abandonado com documentação do motivo

## Template de Tarefa

```markdown
# Task: TASK-YYYYMMDD-[slug]

## Status
PENDING

## Criado em
YYYY-MM-DD

## Agente Designado
[Nome do Agente]

## Plano de Origem
planning/PLAN-[date]-[slug].md

## Descrição
[O que precisa ser feito — 2-5 frases]

## Critérios de Aceite
- [ ] critério 1
- [ ] critério 2

## Scorecard de Complexidade
```yaml
complexity:
  ui: 0
  backend: 0
  database: 0
  apis: 0
  ai_ml: 0
  security: 0
  performance: 0
  infrastructure: 0
  integrations: 0
  total: 0
  tier: Very Low
```

## Orçamento de Tokens
```yaml
token_budget:
  tier: Very Low
  score: 0
  total_tokens: 2000
  input_cap: 1500
  output_cap: 500
  remaining: 2000
  cost_estimate_usd: 0.01
```

## Context Package
(lista exata de arquivos que este agente recebe)

## Dependências
- Bloqueado por: [TASK-IDs ou "nenhuma"]
- Desbloqueia: [TASK-IDs]

## Output do Agente
(preenchido pelo agente ao concluir)

## Resultado do Review
(preenchido pelo Review Agent)

## Métricas
```yaml
metrics:
  input_tokens_used: 0
  output_tokens_used: 0
  estimated_cost_usd: 0.00
  duration_minutes: 0
  files_changed: []
  agent: ""
  success: null
  escalated: false
  escalation_reason: ""
```

## Log de ESCALATE
(preenchido se ESCALATE foi acionado)
```

---

## Métricas Consolidadas (METRICS.md)

Ver `tasks/METRICS.md` para o log de todas as tarefas concluídas.

| TASK-ID | Data | Agente | Tier | Input | Output | Custo | Tempo | Sucesso |
|---------|------|--------|------|-------|--------|-------|-------|---------|
| (vazio — preenchido pelo Integration Agent) |
