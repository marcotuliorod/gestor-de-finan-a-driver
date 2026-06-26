# Jornadas do Usuário — Driver Finance AI

_Gerado pelo Planner Agent | 2026-06-26_

---

## Jornada 1: Primeiro Acesso e Onboarding

**Persona principal:** Todos
**Objetivo:** Configurar o app e fazer o primeiro registro

```
Carlos abre o app pela primeira vez
         │
         ▼
┌─────────────────────┐
│  Tela de Boas-Vindas │ ← logo + tagline + botão "Entrar com Google"
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│  Google OAuth       │ ← popup nativo
└─────────┬───────────┘
          │ ← criado no Supabase, sessão iniciada
          ▼
┌─────────────────────────────┐
│  Onboarding — Passo 1/4     │
│  "Qual é o seu veículo?"    │ ← marca, modelo, ano, combustível
└─────────┬───────────────────┘
          │
          ▼
┌─────────────────────────────┐
│  Onboarding — Passo 2/4     │
│  "Em quais plataformas      │ ← multi-select: Uber, 99, inDrive,
│   você trabalha?"           │   Táxi, Delivery, Outro
└─────────┬───────────────────┘
          │
          ▼
┌─────────────────────────────┐
│  Onboarding — Passo 3/4     │
│  "Qual a sua meta mensal?"  │ ← valor em R$; cálculo automático/dia
└─────────┬───────────────────┘
          │
          ▼
┌─────────────────────────────┐
│  Onboarding — Passo 4/4     │
│  "Tudo pronto!"             │ ← resumo + botão "Começar"
└─────────┬───────────────────┘
          │
          ▼
┌─────────────────────┐
│  Dashboard (vazio)  │ ← estado empty com CTA "Registre sua primeira corrida"
└─────────────────────┘
```

**Pontos de Fricção a Evitar:**
- Não forçar preenchimento de todos os campos no onboarding — permitir pular
- Salvar localmente imediatamente; não esperar sync com Supabase para avançar

---

## Jornada 2: Registro Diário de Corridas (Fluxo Principal)

**Persona principal:** Carlos (Uber Full-Time)
**Objetivo:** Registrar o dia de trabalho ao final do turno

```
Carlos termina o turno (22h)
         │
         ▼
┌──────────────────────┐
│  Abre o Dashboard    │ ← vê resumo do dia incompleto
└──────────┬───────────┘
           │ toca "+" (FAB)
           ▼
┌──────────────────────────────┐
│  Seleciona "Corrida"         │ ← bottom sheet: Corrida / Despesa / Km
└──────────┬───────────────────┘
           │
           ▼
┌──────────────────────────────────────┐
│  Formulário de Corrida               │
│  Plataforma: [Uber ▼]               │
│  Valor bruto: R$ [___]              │
│  Data: [hoje]                       │
│  + Bônus / Gorjeta (opcional)       │
└──────────┬───────────────────────────┘
           │ "Salvar"
           ▼
┌──────────────────────┐
│  Feedback: ✓ Salvo!  │ ← snackbar verde; salvo localmente < 100ms
└──────────┬───────────┘
           │ (opcional) adiciona mais corridas do dia
           ▼
┌──────────────────────────────────────┐
│  Dashboard atualizado                │
│  "Hoje: R$ 180 (meta: R$200 — 90%)" │ ← atualizado em tempo real
└──────────────────────────────────────┘
```

**Métricas de Sucesso desta Jornada:**
- Tempo para registrar 1 corrida: < 30 segundos
- Taxa de conclusão: > 90% (usuário que abre o form salva)

---

## Jornada 3: Registro de Abastecimento

**Persona principal:** João (Entregador)
**Objetivo:** Registrar abastecimento de forma rápida

```
João para no posto e abastece (R$ 60, 5L, km atual: 85.430)
         │ abre o app
         ▼
┌──────────────────────┐
│  Toca "+" → Despesa  │
└──────────┬───────────┘
           │ categoria: Combustível (sugerida como primeira)
           ▼
┌──────────────────────────────────────┐
│  Formulário de Combustível           │
│  Tipo: [Gasolina ▼]                 │
│  Valor: R$ [60]                     │
│  Litros: [5]                        │
│  Km atual: [85.430]                 │
│  (Preço/L: calculado automaticamente│
│   → R$ 12,00/L)                     │
└──────────┬───────────────────────────┘
           │ "Salvar"
           ▼
┌──────────────────────────────────────┐
│  ✓ Salvo! Consumo médio: 10,2 km/L  │ ← snackbar com dado calculado
└──────────────────────────────────────┘
```

**Nota de UX:** Mostrar cálculo imediato (preço/L, consumo) recompensa o motorista e confirma que os dados estão corretos.

---

## Jornada 4: Visualização do Dashboard

**Persona principal:** Amanda (Multi-Plataforma)
**Objetivo:** Revisar performance da semana

```
Amanda abre o app na segunda-feira pela manhã
         │
         ▼
┌─────────────────────────────────────────┐
│  Dashboard — Esta Semana                │
│  ┌─────────┐ ┌─────────┐ ┌──────────┐ │
│  │ Receita │ │Despesas │ │  Lucro   │ │
│  │R$1.842  │ │ R$394   │ │ R$1.448  │ │
│  └─────────┘ └─────────┘ └──────────┘ │
│                                         │
│  Meta mensal: 62% ████████░░░░░░       │
│                                         │
│  Plataforma mais lucrativa: Uber ★     │
│  Lucro/hora: R$ 28,40                  │
└──────────┬──────────────────────────────┘
           │ Amanda toca em "Plataformas"
           ▼
┌──────────────────────────────────────────┐
│  Comparativo de Plataformas              │
│  Uber:   R$960  | 32 corridas | R$30/h  │
│  99:     R$488  | 19 corridas | R$25/h  │
│  inDrive: R$394 | 15 corridas | R$26/h  │
└──────────────────────────────────────────┘
```

---

## Jornada 5: Conversa com IA

**Persona principal:** Amanda
**Objetivo:** Tomar decisão com base em dados

```
Amanda: "Qual plataforma valeu mais a pena esta semana?"
         │
         ▼
┌──────────────────────────────────────────────────────┐
│  IA carregando... (< 3s)                             │
└──────────┬───────────────────────────────────────────┘
           │
           ▼
┌──────────────────────────────────────────────────────┐
│  IA: "Esta semana, a Uber foi sua plataforma mais    │
│  lucrativa. Você ganhou R$ 960 em 32 corridas,       │
│  com um lucro por hora de R$ 30. A 99 ficou em       │
│  segundo lugar com R$ 488 e R$ 25/h. Considerando    │
│  que você trabalhou mais horas na Uber, ela foi       │
│  tanto a mais rentável quanto a mais eficiente."     │
└──────────┬───────────────────────────────────────────┘
           │
Amanda: "E o que eu precisaria faturar hoje para       │
         bater minha meta do mês?"                     │
           │
           ▼
┌──────────────────────────────────────────────────────┐
│  IA: "Sua meta mensal é R$ 4.000. Você já ganhou     │
│  R$ 2.488 este mês. Faltam 12 dias úteis.            │
│  Você precisa de R$ 1.512 nos próximos 12 dias —     │
│  R$ 126 por dia. Hoje, para bater a cota diária,     │
│  você precisa de R$ 126 líquidos."                   │
└──────────────────────────────────────────────────────┘
```

**Restrição de Privacidade:** A IA recebe apenas dados do próprio Amanda. Nenhum dado de outros usuários é enviado para o contexto.

---

## Jornada 6: Alerta de Manutenção

**Persona principal:** Carlos
**Objetivo:** Receber alerta e registrar manutenção preventiva

```
Sistema detecta: km atual (87.500) próximo de troca de óleo (meta: 87.000)
         │
         ▼
┌──────────────────────────────────────┐
│  Notificação push                    │
│  "⚠️ Troca de óleo atrasada!         │
│   Seu veículo está com 500km além    │
│   do prazo. Agende já!"             │
└──────────┬───────────────────────────┘
           │ Carlos toca na notificação
           ▼
┌──────────────────────────────────────┐
│  Tela de Manutenções                 │
│  Próximas revisões:                  │
│  [!] Troca de óleo — ATRASADA       │
│  [ ] Revisão geral — em 2.500km     │
│  [ ] Troca de pneus — em 15.000km  │
└──────────┬───────────────────────────┘
           │ Carlos toca em "Registrar troca de óleo"
           ▼
┌──────────────────────────────────────┐
│  Formulário de Manutenção            │
│  Tipo: Troca de óleo                │
│  Custo: R$ [___]                    │
│  Km atual: [87.500]                 │
│  Próxima troca: km [92.500] (auto)  │
│  Ou data: [____]                    │
└──────────┬───────────────────────────┘
           │ "Salvar"
           ▼
┌──────────────────────────────────────┐
│  ✓ Registrado! Próxima troca de     │
│  óleo: 92.500 km ou em 6 meses      │
└──────────────────────────────────────┘
```

---

## Jornada 7: Acompanhamento de Meta

**Persona principal:** Carlos
**Objetivo:** Checar progresso da meta no fim do dia

```
Carlos fecha o app e recebe notificação:
┌─────────────────────────────────────┐
│  🎯 Meta de hoje atingida!          │
│  Você ganhou R$ 212 hoje.           │
│  Está R$ 12 acima da meta diária.  │
└─────────────────────────────────────┘
```

Ou, se não atingiu:
```
┌─────────────────────────────────────┐
│  📊 Resumo do dia                   │
│  Você ganhou R$ 165 hoje.           │
│  Meta: R$ 200. Faltaram R$ 35.     │
│  Esta semana: 68% da meta mensal.  │
└─────────────────────────────────────┘
```

---

## Jornada 8: Comparativo entre Plataformas

**Persona principal:** Fernanda (Part-Time, Uber + 99)
**Objetivo:** Decidir em qual plataforma focar no próximo fim de semana

```
Fernanda abre relatórios no domingo à noite
         │
         ▼
┌─────────────────────────────────────────────┐
│  Relatório — Outubro 2026                   │
│                                             │
│  UBER                                       │
│  Receita: R$ 820 | Corridas: 28             │
│  Horas: 12h | Lucro/hora: R$ 42,50         │
│                                             │
│  99                                         │
│  Receita: R$ 310 | Corridas: 14             │
│  Horas: 6h | Lucro/hora: R$ 32,00         │
│                                             │
│  ► Uber foi 33% mais lucrativa por hora    │
└─────────────────────────────────────────────┘
```

Fernanda toma a decisão: focar na Uber nos próximos fins de semana.

---

## Mapa de Jornadas × Funcionalidades

| Jornada | Features Necessárias |
|---------|---------------------|
| 1: Onboarding | E1-F2, E2-F1, E2-F2, E9-US01 |
| 2: Registro de corrida | E3-F1, Dashboard básico |
| 3: Abastecimento | E4-F1 completo |
| 4: Dashboard | E7-F1, E7-F2 parcial |
| 5: Chat IA | E8 completo |
| 6: Manutenção | E6 completo + notificações |
| 7: Meta | E9 completo + notificações |
| 8: Comparativo | E7-US06, E7-US07, Relatórios |
