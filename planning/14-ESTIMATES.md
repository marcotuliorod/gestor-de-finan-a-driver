# Estimativas — Driver Finance AI

_Gerado pelo Planner Agent | 2026-06-26_
_Base: 1 desenvolvedor + Claude Code | Velocidade: ~20 story points/sprint de 2 semanas_

---

## Premissas

- **Time:** 1 desenvolvedor full-stack + Claude Code como par
- **Velocidade assumida:** 20 story points por sprint (2 semanas)
- **Sprint 0:** Setup e infraestrutura — não conta story points de produto
- **Complexidade:** Escores do TASK_CLASSIFIER.md aplicados para validar estimates
- **Buffer:** 20% adicionado ao total para imprevistos

---

## Estimativas por Épico

### ÉPICO 1: Autenticação e Onboarding

| ID | Histórias (Must) | Pontos | Complexidade |
|----|-----------------|--------|-------------|
| E1-US01 a US03 | Google Auth + sessão persistente | 5 | Média |
| E1-US04 | Delete account (LGPD) | 3 | Média |
| E1-US05 a US08 | Onboarding (4 passos) | 10 | Média |
| **Total Épico 1** | | **18** | |

### ÉPICO 2: Cadastros

| ID | Histórias (Must) | Pontos | Complexidade |
|----|-----------------|--------|-------------|
| E2-US01 a US02 | Veículo CRUD | 3 | Baixa |
| E2-US04 | Plataformas (padrão) | 2 | Muito Baixa |
| E2-US07 | Categorias de despesa | 1 | Muito Baixa |
| **Total Épico 2** | | **6** | |

### ÉPICO 3: Receitas (Trips)

| ID | Histórias (Must) | Pontos | Complexidade |
|----|-----------------|--------|-------------|
| E3-US01 a US03 | Registro de corrida com extras | 6 | Baixa |
| E3-US04 a US05 | Listagem + edição/exclusão | 5 | Baixa |
| **Total Épico 3** | | **11** | |

### ÉPICO 4: Despesas

| ID | Histórias (Must) | Pontos | Complexidade |
|----|-----------------|--------|-------------|
| E4-US01 a US03 | Combustível completo (consumo médio) | 8 | Média |
| E4-US04 a US05 | Despesas + total por categoria | 6 | Baixa |
| **Total Épico 4** | | **14** | |

### ÉPICO 5: Quilometragem

| ID | Histórias (Must) | Pontos | Complexidade |
|----|-----------------|--------|-------------|
| E5-US01 a US03 | Registro km + totais | 6 | Baixa |
| **Total Épico 5** | | **6** | |

### ÉPICO 6: Manutenções

| ID | Histórias (Must + Should) | Pontos | Complexidade |
|----|--------------------------|--------|-------------|
| E6-US01 a US02 | Registro + histórico | 5 | Baixa |
| E6-US03 | Alertas automáticos (push notifications) | 4 | Média |
| E6-US04 a US05 | Revisões programadas + custos | 5 | Baixa |
| **Total Épico 6** | | **14** | |

### ÉPICO 7: Dashboard e Indicadores

| ID | Histórias (Must) | Pontos | Complexidade |
|----|-----------------|--------|-------------|
| E7-US01 a US03 | Dashboard básico (receita, despesas, lucro) | 8 | Média |
| E7-US04 a US05 | Lucro/hora + custo/km | 5 | Média |
| E7-US06 a US07 | Comparativo plataformas + ticket médio | 8 | Alta |
| E7-US08 a US09 | Depreciação + gráfico diário | 8 | Alta |
| **Total Épico 7** | | **29** | |

### ÉPICO 8: IA Conversacional

| ID | Histórias | Pontos | Complexidade |
|----|-----------|--------|-------------|
| E8-US01 a US02 | Chat IA com dados do usuário | 13 | Muito Alta |
| E8-US04 | Perguntas sugeridas | 2 | Muito Baixa |
| **Total Épico 8** | | **15** | |

### ÉPICO 9: Metas

| ID | Histórias (Must) | Pontos | Complexidade |
|----|-----------------|--------|-------------|
| E9-US01 a US04 | Meta completa + notificações | 10 | Média |
| **Total Épico 9** | | **10** | |

### ÉPICO 10: Configurações

| ID | Histórias (Must) | Pontos | Complexidade |
|----|-----------------|--------|-------------|
| E10-US03 + US05 | Logout + tipo combustível | 2 | Muito Baixa |
| E10-US02 | Dark mode | 2 | Baixa |
| **Total Épico 10** | | **4** | |

---

## Resumo de Estimativas

| Épico | Must + Should Points | Versão |
|-------|---------------------|--------|
| E1: Auth + Onboarding | 18 | MVP |
| E2: Cadastros | 6 | MVP |
| E3: Receitas | 11 | MVP |
| E4: Despesas | 14 | MVP |
| E5: Quilometragem | 6 | MVP |
| E7: Dashboard Básico (US01-05) | 13 | MVP |
| E9: Metas | 10 | MVP |
| E10: Configurações | 4 | MVP |
| **Subtotal MVP (Must)** | **82** | |
| Buffer 20% | 16 | |
| **Total MVP com buffer** | **98** | |
| | | |
| E6: Manutenções | 14 | v1.0 |
| E7: Dashboard Avançado (US06-09) | 16 | v1.0 |
| E8: IA Conversacional | 15 | v1.0 |
| **Subtotal v1.0** | **45** | |
| Buffer 20% | 9 | |
| **Total v1.0 com buffer** | **54** | |

---

## Velocidade e Cronograma Estimado

| Sprint | Story Points | Entregas |
|--------|-------------|---------|
| Sprint 0 (setup) | 0 pts | Infra, backend próprio, CI/CD, projeto Flutter |
| Sprint 1 | 20 pts | E1 (Auth + Onboarding) + E2 (Cadastros) |
| Sprint 2 | 20 pts | E3 (Trips) + E4 parcial (Combustível + Despesas básicas) |
| Sprint 3 | 20 pts | E4 resto + E5 (Km) + E9 (Metas) + E7 básico + E10 |
| ← MVP Beta — 6 semanas → | | |
| Sprint 4 | 20 pts | E6 (Manutenções completo) + E7 avançado parcial |
| Sprint 5 | 20 pts | E7 avançado + E8 IA parcial |
| Sprint 6 | 14 pts | E8 IA completo + polish + bugs |
| ← v1.0 — 12 semanas → | | |

**Total estimado:**
- MVP Beta: 6 semanas (~3 sprints de desenvolvimento)
- v1.0 completo: 12 semanas (~6 sprints de desenvolvimento)

---

## Notas sobre Estimativas

- Points aumentados em 20% para épicos de alta complexidade (E7, E8) por risco de refactoring
- Estimativas não incluem: design de telas (wireframes já prontos), configuração de infraestrutura (sprint 0), testes de usuário
- Claude Code como co-desenvolvedor reduz estimativas em ~30% vs desenvolvimento solo tradicional
