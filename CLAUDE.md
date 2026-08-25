# Driver Finance AI — Claude Code Session Configuration

## Leia Estes Arquivos Antes de Qualquer Ação (em ordem)

1. `.ai/PROJECT_CONTEXT.md` — estado atual do produto e tech stack
2. `.ai/ARCHITECTURE.md` — padrões, camadas e restrições estruturais
3. `.ai/KNOWLEDGE_BASE.md` — soluções reutilizáveis (consulte antes de gerar código)
4. `.ai/WORKFLOW.md` — workflow obrigatório de 9 etapas
5. `.ai/AGENTS.md` — definições e prompts dos 12 agentes
6. `.ai/TASK_CLASSIFIER.md` — classifique a tarefa antes de distribuí-la
7. `.ai/TOKEN_ORCHESTRATION.md` — declare o orçamento de tokens antes de trabalhar
8. `.ai/PROMPT_LIBRARY.md` — templates reutilizáveis por tipo de tarefa

## Protocolo de Início de Sessão

```
1. Leia PROJECT_CONTEXT.md → entenda o estado atual
2. Leia ARCHITECTURE.md → internalize as restrições
3. Consulte KNOWLEDGE_BASE.md → soluções já existentes
4. Identifique o tipo de tarefa → use TASK_CLASSIFIER.md
5. Carregue o agente correto → use AGENTS.md
6. Verifique PROMPT_LIBRARY.md → templates aplicáveis
7. Declare orçamento de tokens (TOKEN_ORCHESTRATION.md)
8. Execute o workflow obrigatório (WORKFLOW.md)
```

## Workflow Obrigatório (nunca pule etapas)

```
Análise → Planejamento → Classificação → Distribuição
→ Implementação → Review → Testes → Documentação → Merge
```

Cada etapa tem gate de entrada e saída definidos em WORKFLOW.md.

## O Que Você NÃO Pode Fazer

- Pular qualquer etapa do workflow
- Carregar o projeto inteiro no contexto sem classificação de complexidade
- Gerar código sem primeiro consultar KNOWLEDGE_BASE.md
- Tomar decisões arquiteturais sem criar um ADR em `adr/`
- Aprovar o próprio trabalho (Review Agent não pode revisar sua própria saída)
- Fazer merge de trabalho paralelo sem passar pelo Integration Agent

## Protocolo ESCALATE

Escreva `ESCALATE: [motivo]` e pare imediatamente quando detectar:
- Contexto insuficiente para prosseguir com segurança
- Dependência externa não documentada em PROJECT_CONTEXT.md
- Risco que excede o nível do orçamento de tokens atual
- Conflito com decisões existentes em ARCHITECTURE.md ou `adr/`

O Planner Agent será re-ativado para redistribuir a tarefa.

## Mapa de Diretórios

```
CLAUDE.md          — este arquivo (entrada da sessão)
.ai/               — governança do framework (nunca apagar)
adr/               — Architectural Decision Records (auto-gerados)
docs/              — documentação para usuários
planning/          — artefatos de planejamento (Planner Agent)
tasks/             — rastreamento de tarefas com métricas
src/               — código-fonte da aplicação
tests/             — suítes de teste
```

## Stack do Projeto

Flutter + Python/FastAPI + PostgreSQL (self-hosted) | Clean Architecture + DDD + Feature First | Offline First
