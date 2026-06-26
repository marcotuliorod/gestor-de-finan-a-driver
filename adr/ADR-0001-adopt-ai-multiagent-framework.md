# ADR-0001: Adotar Framework Multi-Agente Baseado em Prompts

## Status
Accepted

## Data
2026-06-26

## Contexto

O projeto Driver Finance AI é complexo, envolvendo UI mobile, backend, banco de dados, sincronização offline, IA e múltiplas integrações futuras. Sem uma estrutura de desenvolvimento disciplinada, o custo de tokens de IA tende a explodir (contexto desnecessariamente grande), a qualidade do código fica inconsistente entre sessões, e decisões arquiteturais são tomadas de forma ad hoc e perdidas.

Precisamos de um sistema que minimize o consumo de tokens, divida trabalho entre agentes especializados, mantenha documentação viva e permita evolução incremental do produto.

## Decisão

Adotamos um framework de desenvolvimento multi-agente baseado em prompts, implementado como arquivos markdown no diretório `.ai/`. O framework define 12 agentes especializados, um workflow obrigatório de 9 etapas, orçamentos de tokens por complexidade, e documentação viva que evolui com o produto.

O framework é prompt-based (não há código de execução) — cada "agente" é uma definição de prompt que governa como Claude Code deve atuar ao executar aquele papel específico.

## Justificativa

- **Prompt-based vs código-executável:** Portável a qualquer stack, sem dependências de runtime. Qualquer sessão Claude Code pode usar o framework imediatamente.
- **Orçamentos de tokens explícitos:** Previne sessões que carregam contexto desnecessário e explodem o custo.
- **Workflow de 9 etapas com gates:** Previne implementação prematura e garante review e testes consistentes.
- **Documentação viva:** PROJECT_CONTEXT.md e KNOWLEDGE_BASE.md são atualizados automaticamente, eliminando drift entre código e documentação.

## Alternativas Consideradas

| Alternativa | Por que Rejeitada |
|-------------|------------------|
| Sem framework (ad hoc) | Inconsistência garantida entre sessões; custo de tokens imprevisível |
| Framework baseado em código (LangChain, CrewAI) | Requer runtime Python, adiciona dependências, não funciona no Claude Code web |
| Apenas CLAUDE.md sem estrutura .ai/ | Insuficiente para governar projeto de alta complexidade (score 21) |

## Consequências

### Positivas
- Consistência de padrões entre todas as sessões de desenvolvimento
- Custo de tokens previsível e controlável
- Decisões arquiteturais documentadas e acessíveis
- Onboarding de nova sessão: basta ler CLAUDE.md → .ai/ files

### Negativas
- Overhead inicial: criar todos os arquivos do framework antes de qualquer código
- Curva de aprendizado: desenvolvedores precisam entender o workflow

### Riscos
- Arquivos .ai/ podem ficar desatualizados se Documentation Agent não for acionado
- Mitigação: workflow obrigatório inclui etapa de documentação antes do merge

## Conformidade

O Review Agent verifica:
- Toda tarefa passou pelas 9 etapas do workflow
- PROJECT_CONTEXT.md foi atualizado após cada feature
- Nenhuma decisão arquitetural foi tomada sem ADR

## Originado por
Framework initialization — 2026-06-26
