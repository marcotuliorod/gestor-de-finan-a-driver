# Knowledge Base

_Consulte ANTES de gerar qualquer solução. Se a solução existe aqui, use-a diretamente._
_Atualizado pelo Documentation Agent ao final de cada ciclo de implementação._

---

## Como Usar

1. Busque pelo problema que você está tentando resolver
2. Se encontrar uma solução correspondente, **use o padrão exatamente como documentado**
3. Não reinvente soluções já existentes — isso gera inconsistências
4. Se criar uma solução nova que é reutilizável, peça ao Documentation Agent para adicioná-la aqui

---

## Como Adicionar uma Entrada

```
### [Título do Problema]
**Problema:** Descrição específica do problema resolvido
**Solução:** A abordagem adotada (resumo)
**Referência de código:** `src/path/to/file.dart` (linhas X-Y)
**Adicionado em:** YYYY-MM-DD
**Adicionado por:** [Nome do Agente]
**Ressalvas:** Limitações ou condições onde esta solução NÃO se aplica
```

---

## Categorias

### 1. Padrões de Autenticação

_Vazio — será preenchido quando auth for implementada_

---

### 2. Padrões de Consulta ao Banco de Dados

_Vazio — será preenchido quando queries complexas forem criadas_

---

### 3. Padrões de Tratamento de Erros

_Vazio — será preenchido com o padrão Either<Failure, T> estabelecido_

---

### 4. Padrões de Integração com APIs

_Vazio — será preenchido quando Claude API e Supabase forem integrados_

---

### 5. Soluções de Performance

_Vazio — será preenchido quando otimizações forem implementadas_

---

### 6. Soluções de Segurança

_Vazio — será preenchido com padrões de RLS, sanitização e validação_

---

### 7. Estratégias de Teste

_Vazio — será preenchido com factories, fixtures e padrões de mock_

---

### 8. Sincronização Offline / Sync

_Vazio — será preenchido com a estratégia de sync local ↔ Supabase_

---

## Componentes e Widgets Reutilizáveis

_Vazio — será preenchido conforme o design system for implementado_

---

## Modelos de Domínio Reutilizáveis

_Vazio — será preenchido conforme as entidades forem criadas_

---

## Regras de Negócio Documentadas

### Cálculo de Lucro Real

**Regra:** Lucro = Receita Bruta − Todas as Despesas do Período
- Receita Bruta: soma de `trips.gross_amount` no período
- Despesas: soma de `expenses.amount` no período (todas as categorias)
- Lucro Líquido: Receita Bruta − (Despesas Variáveis + Despesas Fixas proporcionais)
- Depreciação: calculada separadamente (não é caixa, mas impacta lucro real)

**Referência:** Ver `planning/07-DOMAIN_MODEL.md` — Value Object `Profit`

### Custo por Quilômetro

**Regra:** Custo/km = Total de Despesas do Período ÷ Km Rodados no Trabalho
- Usar `mileage.work_km` (não incluir km particular)
- Período: mesmo intervalo das despesas

### Depreciação do Veículo

**Regra simplificada (MVP):**
Depreciação Mensal = (Valor Compra − Valor Residual) ÷ Vida Útil em Meses
- Vida útil padrão: 60 meses (configurável por veículo)
- Valor residual padrão: 20% do valor de compra

### Meta Diária

**Regra:** Se meta mensal definida:
Meta Diária = Meta Mensal ÷ Dias Úteis no Mês
- Dias úteis: dias do mês − domingos (padrão; configurável)

### Consumo Médio

**Regra:** Consumo (km/L) = Total de Km Rodados ÷ Total de Litros Abastecidos
- Calculado por veículo
- Período: desde o último zeramento ou início do período selecionado
