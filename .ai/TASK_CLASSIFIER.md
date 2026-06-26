# Task Classifier

_Usado pelo Complexity Analyzer Agent. Consulte antes de scorear qualquer tarefa._

---

## Processo de Classificação

```
1. Leia a descrição completa da tarefa
2. Score cada dimensão (0-3) usando as rubricas abaixo
3. Some os 9 scores
4. Lookup do tier na tabela de TOKEN_ORCHESTRATION.md
5. Embeda o bloco YAML no arquivo da tarefa
```

---

## Rubricas por Dimensão

### 1. UI / Frontend (0–3)

| Score | Critério |
|-------|---------|
| **0** | Sem mudanças visuais |
| **1** | Ajuste de estilo, texto, cor ou ícone em componente existente |
| **2** | Nova tela simples ou novo componente reutilizável |
| **3** | Dashboard com gráficos, animações complexas, fluxo multi-step, acessibilidade crítica |

### 2. Backend / Lógica de Negócio (0–3)

| Score | Critério |
|-------|---------|
| **0** | Sem lógica de negócio nova |
| **1** | Use case simples (CRUD básico, validação trivial) |
| **2** | Cálculo financeiro, regras de negócio com condicionais, orquestração de 2-3 repositórios |
| **3** | Algoritmo complexo (ex: cálculo de depreciação, reconciliação de sincronização, agente IA) |

### 3. Banco de Dados (0–3)

| Score | Critério |
|-------|---------|
| **0** | Sem mudanças no schema |
| **1** | Adicionar coluna nullable ou criar índice simples |
| **2** | Nova tabela com FK, ou alteração em tabela existente com dados |
| **3** | Migração com transformação de dados, mudança breaking, ou impacto em RLS de outras features |

### 4. APIs Externas (0–3)

| Score | Critério |
|-------|---------|
| **0** | Sem chamadas externas novas |
| **1** | Chamada read-only a API documentada (Supabase REST simples) |
| **2** | Operação de escrita, OAuth flow, ou Supabase Edge Function |
| **3** | Webhook, realtime subscription, API não documentada, ou integração com plataforma externa |

### 5. IA / ML (0–3)

| Score | Critério |
|-------|---------|
| **0** | Sem componente de IA |
| **1** | Chamada simples ao Claude API (prompt → resposta) |
| **2** | Chain de prompts, RAG com dados do usuário, ou formatação de contexto complexa |
| **3** | Orquestração multi-agente, fine-tuning, ou processamento de documentos (OCR, PDF) |

### 6. Segurança (0–3)

| Score | Critério |
|-------|---------|
| **0** | Sem superfície de segurança nova |
| **1** | Validação de input adicional em endpoint existente |
| **2** | Mudança em autenticação/autorização, nova policy de RLS, ou endpoint novo exposto |
| **3** | Criptografia, gestão de secrets, compliance LGPD, ou auditoria de dados sensíveis |

### 7. Performance (0–3)

| Score | Critério |
|-------|---------|
| **0** | Sem requisito de performance específico |
| **1** | Operação local < 500ms (padrão Flutter) |
| **2** | Exige < 300ms local, paginação de listas grandes, ou cache de dados |
| **3** | Realtime, < 100ms, processamento de grandes datasets, ou sync de conflitos simultâneos |

### 8. Infraestrutura (0–3)

| Score | Critério |
|-------|---------|
| **0** | Sem mudanças de infra |
| **1** | Mudança em variável de ambiente ou configuração de arquivo |
| **2** | Novo serviço, novo step de CI, ou configuração de ambiente adicional |
| **3** | Multi-região, auto-scaling, disaster recovery, ou mudança em pipeline de produção |

### 9. Integrações (0–3)

| Score | Critério |
|-------|---------|
| **0** | Sem integração nova |
| **1** | Chamada a serviço interno já configurado |
| **2** | Novo SDK de terceiro ou integração com plataforma (ex: upload OCR) |
| **3** | Protocolo complexo, sincronização bidirecional em tempo real, ou Open Finance |

---

## Exemplos Classificados

### Exemplo 1 — Muito Baixo (score 3)
**Tarefa:** "Mudar o texto do botão 'Salvar' para 'Registrar' na tela de corrida"

```yaml
complexity:
  ui: 1           # mudança de texto em componente existente
  backend: 0
  database: 0
  apis: 0
  ai_ml: 0
  security: 0
  performance: 0
  infrastructure: 0
  integrations: 0
  total: 1
  tier: Very Low
```

### Exemplo 2 — Baixo (score 8)
**Tarefa:** "Adicionar campo 'gorjeta' ao registro de corrida (UI + backend + banco)"

```yaml
complexity:
  ui: 2           # novo campo em tela existente
  backend: 1      # use case simples — adicionar campo ao save
  database: 1     # adicionar coluna nullable em trips
  apis: 0
  ai_ml: 0
  security: 1     # validar que valor é positivo
  performance: 0
  infrastructure: 0
  integrations: 0
  total: 5
  tier: Very Low
```

### Exemplo 3 — Médio (score 12)
**Tarefa:** "Dashboard semanal com gráfico de lucro por dia e comparativo de plataformas"

```yaml
complexity:
  ui: 3           # gráficos, múltiplos componentes visuais complexos
  backend: 2      # cálculo de lucro por período, agrupamento por plataforma
  database: 1     # nova query agregada (view ou função)
  apis: 1         # Supabase RPC para dados agregados
  ai_ml: 0
  security: 1     # RLS nos dados do dashboard
  performance: 2  # < 300ms para carregar dashboard
  infrastructure: 0
  integrations: 0
  total: 10
  tier: Low
```

### Exemplo 4 — Muito Alto (score 22)
**Tarefa:** "Módulo de IA conversacional para responder perguntas sobre os dados do motorista"

```yaml
complexity:
  ui: 3           # chat UI com bolhas, histórico, input com voz futura
  backend: 3      # orquestração: buscar dados do usuário, montar contexto, chamar API
  database: 2     # tabela de conversas, histórico, contexto persistido
  apis: 2         # Supabase Edge Function + Claude API
  ai_ml: 3        # RAG com dados do usuário, formatação de contexto, multi-turn
  security: 3     # sanitização antes de enviar para Claude, LGPD, dados financeiros
  performance: 2  # resposta IA < 3s, streaming preferível
  infrastructure: 2 # Edge Function deployment, secrets para API key Claude
  integrations: 2   # Claude API como serviço externo
  total: 22
  tier: Very High
```

---

## Output Format Obrigatório

O Complexity Analyzer deve produzir exatamente este YAML embedado no arquivo da tarefa:

```yaml
complexity:
  ui: 0           # justificativa em 1 linha
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

Seguido da declaração de budget gerada pelo Token Manager Agent.
