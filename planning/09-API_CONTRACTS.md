# Contratos de API — Driver Finance AI

_Gerado pelo Architect Agent | 2026-06-26_

> **⚠️ Documento histórico/pré-implementação.** Escrito antes do Sprint 1, quando o
> plano era usar Supabase (REST auto-gerado via Postgrest + RPC + Edge Functions).
> O projeto migrou para um backend próprio em Python/FastAPI (ver `adr/ADR-0006`) —
> os endpoints reais são REST convencionais (`PUT`/`DELETE /api/v1/{recurso}/{id}`,
> não a sintaxe `?campo=eq.valor` do Postgrest abaixo). Para os contratos atuais,
> consulte o código em `backend/app/resources/` e `backend/app/auth/router.py`
> diretamente — são a fonte da verdade agora, não este documento.

---

## Autenticação

### Auth Flow — Google Sign-In

```
Flutter: GoogleSignIn().signIn()
  → idToken obtido
  → supabase.auth.signInWithIdToken(provider: OAuthProvider.google, idToken: idToken)
  → Session JWT retornado
  → Armazenar sessão (supabase_flutter faz automaticamente)
```

### Auth Flow — Apple Sign-In (iOS)

```
Flutter: SignInWithApple.getAppleIDCredential(scopes: [email, fullName])
  → identityToken obtido
  → supabase.auth.signInWithIdToken(provider: OAuthProvider.apple, idToken: identityToken)
  → Session JWT retornado
```

### Renovação de Token

_Gerenciada automaticamente pelo `supabase_flutter`._

### Sign Out

```dart
await supabase.auth.signOut();
// Limpar SQLite local após sign out (dados do usuário)
```

---

## REST API — Supabase Auto-Gerado

_Acesso via `supabase_flutter`. RLS garante isolamento. Todos os endpoints requerem JWT._

### Trips

```
GET    /rest/v1/trips?trip_date=gte.2026-06-01&trip_date=lte.2026-06-30&order=trip_date.desc
POST   /rest/v1/trips
PATCH  /rest/v1/trips?id=eq.{uuid}
```

_Payload de criação:_
```json
{
  "platform_id": "uuid",
  "gross_amount_cents": 4500,
  "bonus_amount_cents": 0,
  "tip_amount_cents": 200,
  "promotion_cents": 0,
  "cancellation_cents": 0,
  "trip_date": "2026-06-26"
}
```

### Expenses

```
GET    /rest/v1/expenses?expense_date=gte.{date}&expense_date=lte.{date}&order=expense_date.desc
POST   /rest/v1/expenses
PATCH  /rest/v1/expenses?id=eq.{uuid}
```

### Vehicles, Platforms, Maintenance, Goals

_Mesmas convenções REST — GET/POST/PATCH com filtros por query params._

---

## RPC Functions (Supabase PostgreSQL Functions)

### `get_monthly_summary`

_Retorna resumo financeiro do usuário para um mês específico._

**Definição SQL:**
```sql
CREATE OR REPLACE FUNCTION get_monthly_summary(p_year INT, p_month INT)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_start DATE := make_date(p_year, p_month, 1);
    v_end   DATE := (v_start + INTERVAL '1 month' - INTERVAL '1 day')::DATE;
BEGIN
    RETURN json_build_object(
        'total_income_cents',   (
            SELECT COALESCE(SUM(gross_amount_cents + bonus_amount_cents +
                               tip_amount_cents + promotion_cents + cancellation_cents), 0)
            FROM trips
            WHERE user_id = v_user_id
              AND trip_date BETWEEN v_start AND v_end
              AND deleted_at IS NULL
        ),
        'total_expenses_cents', (
            SELECT COALESCE(SUM(amount_cents), 0)
            FROM expenses
            WHERE user_id = v_user_id
              AND expense_date BETWEEN v_start AND v_end
              AND deleted_at IS NULL
        ),
        'trip_count',           (
            SELECT COUNT(*) FROM trips
            WHERE user_id = v_user_id
              AND trip_date BETWEEN v_start AND v_end
              AND deleted_at IS NULL
        ),
        'total_work_km',        (
            SELECT COALESCE(SUM(work_km), 0) FROM mileage_records
            WHERE user_id = v_user_id
              AND record_date BETWEEN v_start AND v_end
              AND deleted_at IS NULL
        )
    );
END;
$$;
```

**Chamada Flutter:**
```dart
final result = await supabase.rpc('get_monthly_summary', params: {
  'p_year': 2026,
  'p_month': 6,
});
```

**Resposta:**
```json
{
  "total_income_cents": 483200,
  "total_expenses_cents": 94500,
  "trip_count": 152,
  "total_work_km": 2840
}
```

---

### `get_platform_summary`

_Comparativo de receita por plataforma em um período._

```sql
CREATE OR REPLACE FUNCTION get_platform_summary(p_start DATE, p_end DATE)
RETURNS TABLE(
    platform_id UUID,
    platform_type TEXT,
    custom_name TEXT,
    total_income_cents BIGINT,
    trip_count BIGINT
)
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT
        p.id AS platform_id,
        p.type AS platform_type,
        p.custom_name,
        COALESCE(SUM(t.gross_amount_cents + t.bonus_amount_cents + t.tip_amount_cents
                     + t.promotion_cents + t.cancellation_cents), 0) AS total_income_cents,
        COUNT(t.id) AS trip_count
    FROM platforms p
    LEFT JOIN trips t ON t.platform_id = p.id
                     AND t.trip_date BETWEEN p_start AND p_end
                     AND t.deleted_at IS NULL
    WHERE p.user_id = auth.uid()
      AND p.deleted_at IS NULL
    GROUP BY p.id, p.type, p.custom_name;
$$;
```

---

### `get_fuel_consumption`

_Consumo médio do veículo (km/L)._

```sql
CREATE OR REPLACE FUNCTION get_fuel_consumption(p_vehicle_id UUID)
RETURNS NUMERIC
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT
        CASE
            WHEN SUM(fr.liters) > 0
            THEN ROUND((MAX(fr.odometer) - MIN(fr.odometer))::NUMERIC / SUM(fr.liters), 2)
            ELSE NULL
        END
    FROM fuel_records fr
    WHERE fr.user_id = auth.uid()
      AND fr.vehicle_id = p_vehicle_id
    HAVING COUNT(*) >= 2;
$$;
```

---

### `delete_user_account`

_Exclui todos os dados do usuário (LGPD — direito ao esquecimento)._

```sql
CREATE OR REPLACE FUNCTION delete_user_account()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE v_user_id UUID := auth.uid();
BEGIN
    -- Soft delete de todos os dados
    UPDATE trips SET deleted_at = NOW() WHERE user_id = v_user_id;
    UPDATE expenses SET deleted_at = NOW() WHERE user_id = v_user_id;
    UPDATE mileage_records SET deleted_at = NOW() WHERE user_id = v_user_id;
    UPDATE maintenance_records SET deleted_at = NOW() WHERE user_id = v_user_id;
    UPDATE vehicles SET deleted_at = NOW() WHERE user_id = v_user_id;
    UPDATE platforms SET deleted_at = NOW() WHERE user_id = v_user_id;
    -- Remove conversas de IA (dados sensíveis)
    DELETE FROM ai_messages WHERE user_id = v_user_id;
    DELETE FROM ai_conversations WHERE user_id = v_user_id;
    -- Remove o usuário do Auth (irrevogável)
    PERFORM auth.admin_delete_user(v_user_id);
END;
$$;
```

---

## Edge Functions (Deno/TypeScript)

### `ai-chat` — Chat com Claude API

**Endpoint:** `POST /functions/v1/ai-chat`
**Auth:** Bearer JWT obrigatório

**Request:**
```typescript
interface AIChatRequest {
  question: string;           // pergunta do usuário (max 500 chars)
  conversation_id?: string;   // para manter histórico (opcional)
  context: UserDataContext;   // dados financeiros do usuário
}

interface UserDataContext {
  period: { start: string; end: string };  // ISO dates
  summary: {
    total_income_cents: number;
    total_expenses_cents: number;
    trip_count: number;
    total_work_km: number;
  };
  platforms: Array<{
    name: string;
    income_cents: number;
    trip_count: number;
  }>;
  top_expense_categories: Array<{
    category: string;
    amount_cents: number;
  }>;
  goal?: {
    monthly_target_cents: number;
    current_profit_cents: number;
    days_remaining: number;
  };
}
```

**Response:**
```typescript
interface AIChatResponse {
  answer: string;             // resposta em PT-BR
  conversation_id: string;    // UUID para continuar a conversa
}
```

**Implementação:**
```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import Anthropic from "npm:@anthropic-ai/sdk";
import { createClient } from "npm:@supabase/supabase-js";

serve(async (req) => {
  // 1. Validar JWT
  const authHeader = req.headers.get('Authorization');
  const supabase = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_ANON_KEY')!);
  const { data: { user }, error } = await supabase.auth.getUser(authHeader?.replace('Bearer ', '') ?? '');
  if (error || !user) return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401 });

  // 2. Parse body
  const body: AIChatRequest = await req.json();

  // 3. Montar prompt com contexto do usuário (SEM PII)
  const systemPrompt = buildSystemPrompt(body.context);

  // 4. Chamar Claude API
  const anthropic = new Anthropic({ apiKey: Deno.env.get('ANTHROPIC_API_KEY')! });
  const message = await anthropic.messages.create({
    model: 'claude-sonnet-4-6',
    max_tokens: 500,
    system: systemPrompt,
    messages: [{ role: 'user', content: body.question }],
  });

  // 5. Salvar no histórico (se conversation_id fornecido)
  // ...

  return new Response(JSON.stringify({
    answer: message.content[0].text,
    conversation_id: body.conversation_id ?? crypto.randomUUID(),
  }), { headers: { 'Content-Type': 'application/json' } });
});

function buildSystemPrompt(ctx: UserDataContext): string {
  return `Você é um assistente financeiro pessoal para motoristas de aplicativo.
Responda APENAS com base nos dados financeiros fornecidos abaixo.
Responda em português do Brasil. Seja direto e use números concretos.
Nunca invente dados. Se não souber, diga que não tem informação suficiente.

DADOS DO MOTORISTA (período: ${ctx.period.start} a ${ctx.period.end}):
- Receita total: R$ ${(ctx.summary.total_income_cents / 100).toFixed(2)}
- Despesas totais: R$ ${(ctx.summary.total_expenses_cents / 100).toFixed(2)}
- Lucro: R$ ${((ctx.summary.total_income_cents - ctx.summary.total_expenses_cents) / 100).toFixed(2)}
- Corridas: ${ctx.summary.trip_count}
- Km trabalhados: ${ctx.summary.total_work_km}
${ctx.goal ? `- Meta mensal: R$ ${(ctx.goal.monthly_target_cents / 100).toFixed(2)} | Dias restantes: ${ctx.goal.days_remaining}` : ''}

POR PLATAFORMA:
${ctx.platforms.map(p => `- ${p.name}: R$ ${(p.income_cents / 100).toFixed(2)} (${p.trip_count} corridas)`).join('\n')}`;
}
```

---

## Supabase Realtime (para sync de alertas)

```dart
// Ouvir alertas de manutenção gerados pelo backend
supabase.channel('maintenance-alerts')
  .onPostgresChanges(
    event: PostgresChangeEvent.insert,
    schema: 'public',
    table: 'maintenance_records',
    filter: PostgresChangeFilter(
      type: FilterType.eq,
      column: 'user_id',
      value: currentUserId,
    ),
    callback: (payload) => _handleMaintenanceAlert(payload),
  )
  .subscribe();
```

---

## Erros Padrão

```json
// 400 Bad Request
{ "error": "invalid_input", "message": "Campo 'amount_cents' deve ser positivo" }

// 401 Unauthorized
{ "error": "unauthorized", "message": "Token inválido ou expirado" }

// 404 Not Found
{ "error": "not_found", "message": "Registro não encontrado" }

// 500 Internal Error
{ "error": "internal_error", "message": "Erro interno. Tente novamente em instantes." }
```
