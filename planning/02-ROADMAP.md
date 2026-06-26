# Roadmap por Versões — Driver Finance AI

_Gerado pelo Planner Agent | 2026-06-26_

---

## MVP — Fundação (Sprint 0–3, ~6 semanas)

**Objetivo:** Motorista consegue registrar receitas e despesas e ver seu lucro real.
**Gate de aceitação:** 10 motoristas beta usam o app por 2 semanas e conseguem responder "quanto ganhei essa semana" usando o app.

### Funcionalidades MVP

**Cadastro e Onboarding**
- [ ] Autenticação social (Google)
- [ ] Cadastro de perfil do motorista
- [ ] Cadastro de veículo (1 veículo)
- [ ] Cadastro de plataformas ativas (Uber, 99, inDrive, Táxi, Delivery)

**Receitas**
- [ ] Registro manual de corrida (plataforma, valor bruto, data)
- [ ] Campos: plataforma, valor bruto, bônus, gorjeta, cancelamentos
- [ ] Listagem de corridas por dia/semana/mês

**Despesas**
- [ ] Registro de despesa com categoria
- [ ] Categorias: Combustível, Lavagem, Pedágio, Seguro, IPVA, Licenciamento, Financiamento, Estacionamento, Internet, Manutenção, Outros
- [ ] Listagem de despesas por período

**Quilometragem**
- [ ] Registro de km inicial e final do dia
- [ ] Diferenciação km trabalho vs km particular

**Dashboard Básico**
- [ ] Lucro do dia (receita − despesas do dia)
- [ ] Lucro da semana
- [ ] Lucro do mês
- [ ] Custo por km (simples)
- [ ] Meta diária com progresso

**Infraestrutura**
- [ ] Supabase setup (auth + banco + RLS)
- [ ] Offline First com SQLite Drift
- [ ] CI/CD básico (GitHub Actions: lint + test + build)

---

## v1.0 — Inteligência (Sprint 4–6, ~6 semanas)

**Objetivo:** Indicadores avançados + IA conversacional + experiência polida.
**Gate de aceitação:** NPS ≥ 40, retenção D30 ≥ 30%.

### Funcionalidades v1.0

**Dashboard Avançado**
- [ ] Gráfico de lucro por dia (linha)
- [ ] Gráfico de despesas por categoria (pizza)
- [ ] Comparativo entre plataformas (barras)
- [ ] Ganho por hora trabalhada
- [ ] Lucro por km
- [ ] Ticket médio por corrida
- [ ] Taxa de ocupação (horas trabalhadas / horas disponíveis)

**IA Conversacional**
- [ ] Chat com Claude API usando dados do usuário como contexto
- [ ] Perguntas suportadas:
  - "Quanto ganhei na Uber este mês?"
  - "Qual foi meu melhor dia?"
  - "Quanto custa manter meu veículo?"
  - "Qual horário gera maior lucro?"
  - "Quanto preciso faturar hoje para atingir minha meta?"
- [ ] Histórico de conversas

**Manutenções**
- [ ] Registro de manutenção com tipo, custo e km
- [ ] Histórico completo por veículo
- [ ] Alertas: troca de óleo, revisão, pneus (baseado em km + tempo)

**Depreciação**
- [ ] Cálculo automático de depreciação mensal do veículo
- [ ] Valor residual configurável

**Melhorias de UX**
- [ ] Onboarding guiado com tutorial
- [ ] Notificações push: meta diária atingida, alerta de manutenção
- [ ] Apple Sign-In (iOS)
- [ ] Dark mode

**Receitas Avançadas**
- [ ] Importação via CSV (formato Uber/99)

---

## v2.0 — Automação (Sprint 7–12, ~12 semanas)

**Objetivo:** Reduzir ao máximo o trabalho manual do motorista.
**Gate de aceitação:** 50% dos usuários ativos nunca precisam inserir corrida manualmente.

### Funcionalidades v2.0

**Importação Automática**
- [ ] OCR de comprovantes (foto → dados extraídos)
- [ ] Leitura de PDFs de extrato Uber/99
- [ ] Importação por e-mail (forward para e-mail especial)

**Integração Financeira**
- [ ] Open Finance (leitura de conta bancária)
- [ ] Conciliação automática de receitas vs depósitos

**Inteligência Avançada**
- [ ] Machine Learning: previsão de demanda por horário e região
- [ ] Sugestão de horários mais lucrativos
- [ ] Alerta de queda de lucratividade por plataforma

**Social e Gamificação**
- [ ] Metas gamificadas (conquistas, streaks)
- [ ] Ranking anônimo por região (opt-in)
- [ ] Comunidade de motoristas

**Planejamento Tributário**
- [ ] Cálculo de impostos para MEI
- [ ] Relatório para declaração de IR

**Multi-veículo**
- [ ] Gestão de frota pessoal (até 3 veículos)
- [ ] Métricas comparativas por veículo

---

## Funcionalidades Descartadas do MVP

| Feature | Motivo | Candidato para |
|---------|--------|---------------|
| Integração bancária | Complexidade regulatória | v2.0 |
| OCR de comprovantes | Requer infraestrutura ML | v2.0 |
| Multi-veículo | Aumenta complexidade do MVP | v2.0 |
| Ranking entre motoristas | Privacidade sensível | v2.0 (opt-in) |
| Planejamento tributário | Fora do escopo core | v2.0 |
| Importação API plataformas | APIs não são públicas | Backlog |
