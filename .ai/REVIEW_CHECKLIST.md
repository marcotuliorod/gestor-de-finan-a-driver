# Review Checklist

_Aplicado pelo Review Agent em toda tarefa antes de passar para Testes._
_Marque: PASS / FAIL / N/A. Nenhum FAIL pode prosseguir sem correção._

---

## Como Usar

O Review Agent deve:
1. Receber todos os artefatos da Etapa 5 (Implementação)
2. Declarar o agente originador dos artefatos
3. Avaliar cada item abaixo
4. Produzir o relatório no formato definido no fim deste arquivo
5. Decisão final: APROVADO (zero FAILs) ou REPROVADO

---

## Seção 1: Corretude

- [ ] A implementação atende todos os critérios de aceite da tarefa
- [ ] Edge cases identificados no planejamento estão tratados
- [ ] Não há regressão: comportamento existente não relacionado permanece inalterado
- [ ] Paths de erro retornam falhas explícitas (não silenciosas)
- [ ] Valores de retorno são consistentes com os contratos declarados

## Seção 2: Segurança

- [ ] Nenhum secret hardcoded no código ou em comentários
- [ ] Todo input do usuário é validado antes de ser usado
- [ ] Autenticação/autorização está presente em todo novo endpoint/operação
- [ ] Nenhuma superfície de SQL injection (use prepared statements ou ORM)
- [ ] RLS está ativa nas novas tabelas/operações de banco
- [ ] Dados enviados para Claude API foram sanitizados (sem PII bruto)
- [ ] Dependências adicionadas não possuem CVEs conhecidos

## Seção 3: Qualidade de Código

- [ ] Código segue CODING_STANDARDS.md em todos os aspectos
- [ ] Nenhuma função com mais de 20 linhas sem justificativa
- [ ] Sem duplicação: verificar KNOWLEDGE_BASE.md se solução já existia
- [ ] Nomenclatura clara e consistente com o restante do projeto
- [ ] Sem `print()` ou `debugPrint()` sem flag de debug
- [ ] Sem `dynamic` ou `var` sem tipo explícito (Dart)
- [ ] Sem TODO sem issue linkada

## Seção 4: Conformidade Arquitetural

- [ ] Nenhuma violação dos padrões aprovados em ARCHITECTURE.md
- [ ] Nenhum anti-padrão proibido em ARCHITECTURE.md
- [ ] Novas dependências adicionadas ao PROJECT_CONTEXT.md
- [ ] ADR criado se decisão arquitetural foi tomada
- [ ] Widgets não contêm lógica de negócio
- [ ] Domain layer não importa Flutter ou Supabase
- [ ] Repositórios acessados apenas via interfaces (não implementações concretas)

## Seção 5: Testes

- [ ] Testes unitários existem para toda nova lógica de negócio
- [ ] Happy path testado
- [ ] Pelo menos 2 cenários de falha testados por função crítica
- [ ] Testes são determinísticos (sem dependência de tempo ou aleatoriedade não seedada)
- [ ] Mocks usados para dependências externas
- [ ] Nenhum teste acessa banco real ou API real

## Seção 6: Documentação

- [ ] Docstrings em todas as funções públicas (quando não óbvio pelo nome)
- [ ] Mudanças de API refletidas em `planning/09-API_CONTRACTS.md`
- [ ] Se nova feature visível ao usuário: entrada em `docs/`
- [ ] Se padrão reutilizável criado: entrada em KNOWLEDGE_BASE.md

---

## Formato do Relatório de Revisão

```markdown
## Relatório de Revisão — [TASK-ID]

**Agente originador:** [nome do agente que implementou]
**Revisor:** Review Agent
**Data:** [YYYY-MM-DD]

### Seção 1: Corretude
- [x] A implementação atende todos os critérios de aceite — PASS
- [ ] Edge cases identificados no planejamento estão tratados — FAIL
  - Arquivo: `src/features/trips/domain/use_cases/add_trip.dart:45`
  - Problema: Valor negativo não é validado
  - Correção: Adicionar `if (amount < 0) return Left(ValidationFailure('Amount must be positive'))`

### Seção 2: Segurança
- [x] Nenhum secret hardcoded — PASS
- [x] Input validado — PASS
- [x] RLS ativa — PASS
- N/A (restantes não aplicáveis a esta tarefa)

### Seção 3: Qualidade de Código
[...]

### Seção 4: Conformidade Arquitetural
[...]

### Seção 5: Testes
[...]

### Seção 6: Documentação
[...]

---

### Resumo

| Seção | PASS | FAIL | N/A |
|-------|------|------|-----|
| Corretude | 4 | 1 | 0 |
| Segurança | 3 | 0 | 4 |
| Qualidade | 7 | 0 | 0 |
| Arquitetura | 6 | 0 | 1 |
| Testes | 5 | 0 | 0 |
| Documentação | 2 | 0 | 4 |

**Total PASS:** 27
**Total FAIL:** 1
**Decisão: REPROVADO**

### Mudanças Obrigatórias (para re-trabalho)

1. `src/features/trips/domain/use_cases/add_trip.dart:45` — Adicionar validação de valor negativo no campo `amount`
```

---

## Critérios de Aprovação Automática (Fast Track)

Uma tarefa pode ser aprovada sem revisão completa **apenas se** todas as condições:
- Score de complexidade Very Low (0–5)
- Nenhuma mudança de banco de dados
- Nenhuma mudança de autenticação/autorização
- Nenhuma feature nova — apenas correção de texto, estilo ou ajuste de configuração

Mesmo em Fast Track, Seção 2 (Segurança) é sempre executada.
