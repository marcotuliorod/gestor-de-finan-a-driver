# Token Orchestration Protocol

_Consultado pelo Token Manager Agent e respeitado por todos os agentes._

---

## Tabela de Orçamento por Complexidade

| Nível | Score | Total | Cap Input | Cap Output | Contexto Max |
|-------|-------|-------|-----------|------------|--------------|
| Very Low | 0–5 | 2k tokens | 1.500 | 500 | 2–3 arquivos |
| Low | 6–10 | 5k tokens | 3.500 | 1.500 | 4–6 arquivos |
| Medium | 11–15 | 12k tokens | 8.000 | 4.000 | 7–10 arquivos |
| High | 16–20 | 25k tokens | 18.000 | 7.000 | 11–15 arquivos |
| Very High | 20+ | 50k tokens | 35.000 | 15.000 | 16–20 arquivos |

**Input cap** = tokens de contexto carregados (arquivos, histórico, exemplos)
**Output cap** = tokens gerados pelo agente (código, análise, documentação)

---

## Regras de Carregamento de Contexto por Tier

### Very Low (0–5)
- Máximo 3 arquivos no context package
- Carregar apenas: arquivo da tarefa + 1-2 arquivos diretamente modificados
- Proibido: carregar módulos inteiros, schemas completos, ou arquivos > 200 linhas

### Low (6–10)
- Máximo 6 arquivos
- Permitido: módulo completo de uma feature pequena
- Proibido: carregar features não relacionadas

### Medium (11–15)
- Máximo 10 arquivos
- Permitido: feature completa + core utilities relevantes
- Proibido: carregar todo o `src/`

### High (16–20)
- Máximo 15 arquivos
- Permitido: múltiplas features interconectadas + schema + architecture
- Proibido: carregar o projeto inteiro em uma única chamada de agente

### Very High (20+)
- Máximo 20 arquivos por agente
- **Obrigatório**: dividir em sub-tarefas paralelas se possível
- Cada agente paralelo recebe apenas seu slice de contexto
- Integration Agent une os resultados no final

---

## Formato de Declaração de Budget

Todo agente deve incluir este bloco **no início de sua resposta**:

```yaml
token_budget:
  tier: High
  score: 17
  total_tokens: 25000
  input_cap: 18000
  output_cap: 7000
  remaining: 25000        # decrementar a cada handoff
  cost_estimate_usd: 0.18 # (input × 0.000003) + (output × 0.000015)
  task_id: TASK-20260626-add-trip
```

---

## Rastreamento de Consumo em Handoffs

Quando uma tarefa passa por múltiplos agentes:

1. **Complexity Analyzer** declara o budget inicial
2. **Cada agente subsequente** decrementa `remaining` com base em sua estimativa de uso
3. **Integration Agent** registra o consumo total real nas métricas da tarefa

Exemplo de decremento:
```yaml
# Após Backend Agent usar ~8k tokens:
remaining: 25000 → 17000

# Após Frontend Agent usar ~6k tokens:
remaining: 17000 → 11000

# Após QA Agent usar ~3k tokens:
remaining: 11000 → 8000
```

---

## Protocolo quando Budget se Esgota

Se `remaining` cair abaixo de 2.000 tokens mid-task:

1. O agente atual para imediatamente
2. Escreve: `BUDGET_EXHAUSTED: [tokens usados] / [budget total]. Tarefas pendentes: [lista]`
3. O Integration Agent registra o estado parcial
4. O Planner é ativado para redistribuir as sub-tarefas restantes com novo budget

---

## Estimativa de Custo

Fórmula simplificada (Claude Sonnet 4.6):
```
custo = (tokens_input × $0.000003) + (tokens_output × $0.000015)
```

Referências por tier:
| Tier | Custo estimado/tarefa |
|------|-----------------------|
| Very Low | ~$0.01 |
| Low | ~$0.03 |
| Medium | ~$0.09 |
| High | ~$0.18 |
| Very High | ~$0.38 |

---

## Ajuste Dinâmico de Budget

O Token Manager pode **aumentar o budget** de uma tarefa se:
- Histórico das últimas 5 tarefas do mesmo tier mostra que o orçamento atual é sistematicamente insuficiente
- O aumento é registrado em `tasks/METRICS.md` com justificativa

O Token Manager pode **reduzir o budget** se:
- Tarefa usa consistentemente < 50% do orçamento do tier
- A redução é aplicada nas próximas 3 tarefas do mesmo tipo e tier

---

## Log de Métricas (`tasks/METRICS.md`)

Toda tarefa concluída registra uma linha:

```markdown
| TASK-ID | Data | Agente | Tier | Budget | Input Used | Output Used | Custo | Tempo | Sucesso |
|---------|------|--------|------|--------|------------|-------------|-------|-------|---------|
| TASK-20260626-add-trip | 2026-06-26 | Backend | High | 25k | 14.2k | 5.8k | $0.13 | 12min | ✓ |
```

Revisão semanal das métricas para ajuste dinâmico dos budgets.
