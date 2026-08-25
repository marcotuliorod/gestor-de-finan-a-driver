# Matriz de Riscos — Driver Finance AI

_Gerado pelo Planner Agent | 2026-06-26_

**Nível de Risco:** Probabilidade (1-5) × Impacto (1-5) = Score (1-25)

---

## Matriz

| ID | Risco | Probabilidade | Impacto | Score | Nível |
|----|-------|--------------|---------|-------|-------|
| R01 | Conflitos de sincronização offline causam perda de dados | 3 | 5 | 15 | 🔴 Alto |
| R02 | Não conformidade com LGPD (dados pessoais) | 2 | 5 | 10 | 🟠 Médio |
| R03 | IA responde com dados incorretos ou inventados | 3 | 4 | 12 | 🔴 Alto |
| R04 | Limite de requests do backend próprio atingido (sem auto-scaling configurado) | 3 | 3 | 9 | 🟠 Médio |
| R05 | Dados de diferentes usuários vazam via RLS incorreta | 2 | 5 | 10 | 🟠 Médio |
| R06 | Cálculo de depreciação incorreto gera desconfiança | 3 | 3 | 9 | 🟠 Médio |
| R07 | Onboarding com muitas etapas → abandono alto | 4 | 3 | 12 | 🔴 Alto |
| R08 | Claude API tem latência > 5s → má experiência no chat | 3 | 3 | 9 | 🟠 Médio |
| R09 | Motoristas não adotam o hábito de registro diário | 4 | 4 | 16 | 🔴 Alto |
| R10 | Falha no Google Sign-In em dispositivos específicos | 2 | 4 | 8 | 🟠 Médio |
| R11 | Drift migration quebra banco local em update do app | 2 | 4 | 8 | 🟠 Médio |
| R12 | API key do Claude exposurada no cliente | 1 | 5 | 5 | 🟡 Baixo |
| R13 | Provedor de VPS descontinua serviço ou muda preço drasticamente | 1 | 4 | 4 | 🟡 Baixo |

---

## Detalhamento dos Riscos Críticos (Score ≥ 12)

### R01 — Conflitos de Sincronização

**Descrição:** Usuário edita dados offline por vários dias; ao sincronizar, conflito com registros no servidor causa sobreescrita ou duplicação de dados financeiros.

**Probabilidade:** Média (3) — motoristas frequentemente ficam sem internet
**Impacto:** Crítico (5) — perda de dados financeiros destrói a confiança

**Mitigações:**
1. Last-write-wins com base em `updated_at` (implementado no MVP)
2. Alertar usuário após 3 dias sem sincronização
3. Log de conflitos resolvidos (auditável pelo usuário)
4. Nunca sobrescrever sem ter backup local da versão anterior
5. Testar cenários de conflito com integration tests

**Plano de Contingência:** Se conflito não resolvido, manter ambas as versões e pedir ao usuário para escolher (v1.1).

---

### R03 — IA com Respostas Incorretas

**Descrição:** Claude responde com dados inventados ou calcula valores incorretamente, levando o motorista a tomar decisões financeiras erradas.

**Probabilidade:** Média (3) — LLMs podem "alucinar"
**Impacto:** Alto (4) — decisões financeiras baseadas em dados errados

**Mitigações:**
1. Sempre incluir os dados reais no contexto da mensagem (RAG)
2. Prompt instrui Claude explicitamente: "Nunca invente dados. Se não souber, diga."
3. Mostrar aviso na UI: "Baseado nos seus dados registrados"
4. Incluir os valores brutos após a resposta da IA para conferência
5. Sanitizar dados antes de enviar (sem PII desnecessária)

**Plano de Contingência:** Se problemas recorrentes reportados, adicionar disclaimer proeminente e opção de feedback por resposta.

---

### R07 — Abandono no Onboarding

**Descrição:** Onboarding com muitas etapas obrigatórias afasta motoristas antes de ver o valor do produto.

**Probabilidade:** Alta (4) — pesquisas mostram que cada etapa reduz conversão ~10%
**Impacto:** Médio (3) — usuários não ativados não geram valor

**Mitigações:**
1. Máximo de 3 etapas no onboarding inicial (veículo, plataformas, meta)
2. Permitir pular todas as etapas ("configurar depois")
3. Progredir com dados mínimos: só nome + 1 plataforma já é suficiente
4. Mostrar preview do dashboard com dados de exemplo antes de cadastrar

**Métricas de Monitoramento:** Taxa de conclusão de onboarding por etapa; se < 70% completam alguma etapa, simplificar.

---

### R09 — Não Adoção de Registro Diário

**Descrição:** O app só gera valor com dados consistentes. Se motoristas não registram corridas e despesas diariamente, o dashboard fica vazio e eles abandonam.

**Probabilidade:** Alta (4) — habituação requer esforço
**Impacto:** Alto (4) — sem dados, sem valor, sem retenção

**Mitigações:**
1. Registro de corrida em < 30 segundos (formulário mínimo)
2. Notificação push no final do turno: "Registre suas corridas de hoje"
3. Gamificação leve: streak de dias consecutivos registrados
4. Widget na home screen do Android (quick add)
5. Importação CSV como atalho para motoristas com histórico

**Indicador:** Se usuário não registra em 3 dias, enviar push de reengajamento.

---

## Riscos de Segurança e Privacidade

### R02 — LGPD

**Obrigações:**
- Termo de privacidade claro na tela de login
- Dados pessoais mínimos (email, nome — nenhum dado de localização sem consentimento)
- Direito ao esquecimento implementado via `delete_account` procedure
- Dados de motoristas de terceiros nunca são enviados para Claude API

**Checklist de Conformidade:**
- [ ] Política de privacidade publicada e linkada no login
- [ ] Consentimento explícito antes de coletar dados
- [ ] Função `delete_user_account` testada e funcionando
- [ ] Logs de acesso ao banco auditáveis
- [ ] Criptografia em trânsito (HTTPS via Caddy) e em repouso (configurar no volume do Postgres)

### R05 — RLS Incorreta (Vazamento de Dados)

**Controles:**
- Toda tabela tem RLS habilitada — verificado no Review Checklist Seção 2
- Testes de integração validam que user A não acessa dados de user B
- Auditoria de RLS a cada PR que toca banco de dados

---

## Monitoramento de Riscos

| Risco | Métrica de Monitoramento | Frequência |
|-------|------------------------|------------|
| R01 (conflitos) | Tamanho da sync queue; conflitos por usuário | Diária |
| R03 (IA incorreta) | Feedback negativo no chat | A cada report |
| R07 (onboarding) | Taxa de conclusão por etapa | Semanal |
| R09 (registro) | DAU, registros por usuário ativo | Semanal |
| R04 (limites backend próprio) | Monitoramento de uso do VPS | Semanal |
