# Mandatory Development Workflow

_Nunca pule etapas. Nunca reordene. Cada etapa tem gate de entrada e saída._

---

## O Workflow Obrigatório

```
┌─────────────┐
│  1. Análise │ ← Entrada: requisito bruto
└──────┬──────┘
       │ Gate: requisito compreendido, questões abertas identificadas
       ▼
┌──────────────────┐
│  2. Planejamento │ ← Planner Agent
└────────┬─────────┘
         │ Gate: plano aprovado, tasks criadas em tasks/
         ▼
┌──────────────────────┐
│  3. Classificação    │ ← Complexity Analyzer + Token Manager
└──────────┬───────────┘
           │ Gate: scorecard + budget declarado em cada task file
           ▼
┌──────────────────────┐
│  4. Distribuição     │ ← Planner (re-engajado)
└──────────┬───────────┘
           │ Gate: context packages definidos, agentes designados
           ▼
┌────────────────────────────────────────────────────┐
│  5. Implementação (pode ser paralelo)              │
│  Backend Agent | Frontend Agent | Database Agent   │
│  DevOps Agent  | (outros conforme necessário)      │
└───────────────────────────┬────────────────────────┘
                            │ Gate: todos outputs produzidos, sem ESCALATE pendente
                            ▼
┌───────────────┐
│  6. Review    │ ← Review Agent
└──────┬────────┘
       │ Gate: APROVADO (zero FAILs no checklist)
       ▼
┌─────────────┐
│  7. Testes  │ ← QA Agent
└──────┬──────┘
       │ Gate: testes passando, cobertura ≥ 80%
       ▼
┌──────────────────┐
│  8. Documentação │ ← Documentation Agent
└────────┬─────────┘
         │ Gate: PROJECT_CONTEXT.md atualizado, KNOWLEDGE_BASE.md atualizado
         ▼
┌──────────┐
│  9. Merge│ ← Integration Agent
└──────────┘
  Gate: sem conflitos, métricas registradas, task marcada COMPLETE
```

---

## Detalhamento por Etapa

### Etapa 1: Análise

**Responsável:** Qualquer agente pode fazer análise inicial; Planner formaliza.

**Entrada:** Requisito bruto do usuário (texto livre)

**Ações:**
- Ler PROJECT_CONTEXT.md para entender o contexto atual
- Identificar o que já existe vs o que precisa ser criado
- Listar questões abertas que bloqueiam o planejamento

**Saída:** Lista de questões abertas + confirmação de que o requisito é compreendido

**Gate de saída:** Todas as questões abertas resolvidas (pelo usuário ou por inferência justificada)

---

### Etapa 2: Planejamento

**Responsável:** Planner Agent

**Entrada:** Requisito compreendido + PROJECT_CONTEXT.md + ARCHITECTURE.md

**Ações:**
- Decompor em tarefas atômicas
- Identificar dependências
- Criar arquivos em `tasks/TASK-[date]-[slug].md`
- Criar `planning/PLAN-[date]-[slug].md`

**Saída:** Plano com tarefas, dependências, grafo de paralelização

**Gate de saída:** Cada tarefa tem: ID único, agente designado, dependências listadas, critérios de aceite

---

### Etapa 3: Classificação

**Responsável:** Complexity Analyzer → Token Manager

**Entrada:** Cada arquivo de tarefa individual

**Ações:**
- Score das 9 dimensões por tarefa
- Lookup do tier de budget
- Declarar budget em cada task file

**Saída:** Scorecard YAML + budget declaration em cada task file

**Gate de saída:** Todo task file tem scorecard + budget preenchidos

---

### Etapa 4: Distribuição

**Responsável:** Planner Agent (re-engajado)

**Entrada:** Tasks classificadas com budgets

**Ações:**
- Definir context package (lista exata de arquivos) para cada agente
- Confirmar grupos de paralelização
- Validar que nenhum agente receberá mais arquivos que seu tier permite

**Saída:** Context packages definidos por tarefa

**Gate de saída:** Cada tarefa tem seu context package listado no task file

---

### Etapa 5: Implementação

**Responsáveis:** Backend, Frontend, Database, DevOps Agents (conforme necessário)

**Regra de paralelização:**
- Tarefas SEM dependência entre si: rodam em paralelo
- Tarefas COM dependência: serial (A completa antes de B iniciar)
- Máximo 4 agentes em paralelo por ciclo

**Ações de cada agente:**
1. Consultar KNOWLEDGE_BASE.md (soluções existentes)
2. Consultar PROMPT_LIBRARY.md (templates aplicáveis)
3. Implementar seguindo CODING_STANDARDS.md
4. Produzir artefatos listados no output contract do agente

**ESCALATE:** Se qualquer agente escrever `ESCALATE: [motivo]`, parar o ciclo. Planner redistribui.

**Gate de saída:** Todos os artefatos produzidos, nenhum ESCALATE pendente

---

### Etapa 6: Review

**Responsável:** Review Agent (nunca o agente que implementou)

**Entrada:** Todos os artefatos da Etapa 5 + REVIEW_CHECKLIST.md

**Ações:**
- Avaliar cada item das 6 seções do checklist
- Produzir relatório PASS/FAIL/N/A
- Listar mudanças obrigatórias para cada FAIL

**Gate de saída:**
- Decisão = APROVADO (zero FAILs)
- Se REPROVADO: artefatos voltam para a Etapa 5 (o agente relevante corrige)
- Máximo 2 ciclos de correção antes de escalonar para o usuário

---

### Etapa 7: Testes

**Responsável:** QA Agent

**Entrada:** Artefatos aprovados na Etapa 6

**Ações:**
- Criar testes: unit, widget, integration conforme TEST_PLAN.md
- Verificar cobertura ≥ 80% no novo código
- Documentar edge cases não cobertos

**Gate de saída:**
- Todos os testes passando
- Cobertura ≥ 80%
- Lista de edge cases documentada (para backlog futuro se não cobertos)

---

### Etapa 8: Documentação

**Responsável:** Documentation Agent

**Entrada:** Artefatos aprovados + testes passando

**Ações:**
- Atualizar PROJECT_CONTEXT.md (Feature Inventory, Estado Atual, Log)
- Atualizar KNOWLEDGE_BASE.md se padrão reutilizável foi criado
- Criar/atualizar docs/ se feature é visível ao usuário
- Criar ADR se decisão arquitetural foi tomada durante implementação

**Gate de saída:**
- PROJECT_CONTEXT.md atualizado com a feature
- KNOWLEDGE_BASE.md atualizado se aplicável

---

### Etapa 9: Merge

**Responsável:** Integration Agent

**Entrada:** Todos os artefatos de agentes paralelos + arquivos de métricas

**Ações:**
- Verificar consistência entre outputs paralelos
- Resolver conflitos (documentar cada resolução)
- Registrar métricas em `tasks/METRICS.md`
- Marcar task como COMPLETE

**Gate de saída:**
- Task file com status = COMPLETE
- Métricas registradas
- Nenhum conflito não resolvido

---

## Regras de Paralelização

### Pode rodar em paralelo:
- Backend + Frontend na Etapa 5 (se não dependentes)
- Database + Backend (se schema já definido)
- QA + Documentation (se em tasks separadas independentes)

### Nunca paralelizar:
- Etapas 1-4 (são gates seriais)
- Review e Implementação (Review depende da Implementação)
- Merge com qualquer outra etapa (é o ponto de integração)

---

## Protocolo ESCALATE

Qualquer agente pode escrever `ESCALATE: [motivo]` em qualquer etapa.

**Quando usar:**
- Contexto insuficiente para prosseguir com segurança
- Dependência externa não documentada
- Risco que excede o budget atual
- Conflito com ADR existente

**O que acontece:**
1. Agente para imediatamente e escreve o motivo
2. Task file recebe status = ESCALATED
3. Planner é ativado
4. Planner avalia: resolve a questão, redistribui a tarefa, ou escala para o usuário
5. Task retoma da etapa onde foi escalonada (não do início)

---

## Protocolo de Rollback

Se a Etapa 6 (Review) reprovar 2 vezes:
1. Tarefa recebe status = BLOCKED
2. Planner é ativado
3. Planner decide: redesenhar a tarefa, ou escalar para o usuário
4. Uma nova task é criada para a correção (nunca modifica a original com falha)
