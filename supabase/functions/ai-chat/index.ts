import Anthropic from 'npm:@anthropic-ai/sdk@0.27.0';
import { createClient } from 'npm:@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
};

interface Message {
  role: 'user' | 'assistant';
  content: string;
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: authHeader } } },
    );

    const {
      data: { user },
      error: userError,
    } = await supabase.auth.getUser();

    if (userError || !user) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const { messages } = (await req.json()) as { messages: Message[] };

    // Gather this-month financial context
    const now = new Date();
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1).toISOString();

    const [tripsResult, expensesResult, goalsResult] = await Promise.all([
      supabase
        .from('trips')
        .select(
          'gross_amount_cents, bonus_amount_cents, tip_amount_cents, promotion_cents, cancellation_cents',
        )
        .eq('user_id', user.id)
        .gte('trip_date', monthStart),
      supabase
        .from('expenses')
        .select('amount_cents, category')
        .eq('user_id', user.id)
        .gte('expense_date', monthStart),
      supabase
        .from('goals')
        .select('monthly_target_cents, working_days_per_month')
        .eq('user_id', user.id)
        .order('created_at', { ascending: false })
        .limit(1),
    ]);

    const trips = (tripsResult.data ?? []) as Record<string, number>[];
    const expenses = (expensesResult.data ?? []) as Record<
      string,
      string | number
    >[];
    const goal = (goalsResult.data?.[0] ?? null) as {
      monthly_target_cents: number;
      working_days_per_month: number;
    } | null;

    const totalIncomeCents = trips.reduce(
      (sum, t) =>
        sum +
        Number(t.gross_amount_cents) +
        Number(t.bonus_amount_cents) +
        Number(t.tip_amount_cents) +
        Number(t.promotion_cents) +
        Number(t.cancellation_cents),
      0,
    );

    const totalExpensesCents = expenses.reduce(
      (sum, e) => sum + Number(e.amount_cents),
      0,
    );

    const fuelCents = expenses
      .filter((e) => e.category === 'fuel')
      .reduce((sum, e) => sum + Number(e.amount_cents), 0);

    const fmt = (cents: number) =>
      `R$ ${(cents / 100).toFixed(2).replace('.', ',')}`;

    const monthName = now.toLocaleDateString('pt-BR', {
      month: 'long',
      year: 'numeric',
    });

    const contextLines = [
      `Corridas realizadas: ${trips.length}`,
      `Receita total: ${fmt(totalIncomeCents)}`,
      `Despesas totais: ${fmt(totalExpensesCents)}`,
      `Combustível: ${fmt(fuelCents)}`,
      `Outras despesas: ${fmt(totalExpensesCents - fuelCents)}`,
      `Lucro líquido: ${fmt(totalIncomeCents - totalExpensesCents)}`,
    ];

    if (goal) {
      const pct =
        goal.monthly_target_cents > 0
          ? ((totalIncomeCents / goal.monthly_target_cents) * 100).toFixed(0)
          : '0';
      contextLines.push(
        `Meta mensal: ${fmt(goal.monthly_target_cents)}`,
        `Progresso da meta: ${pct}%`,
        `Dias de trabalho/mês: ${goal.working_days_per_month}`,
      );
    }

    const systemPrompt =
      `Você é um assistente financeiro especializado para motoristas de aplicativo ` +
      `(Uber, 99, inDrive) no Brasil.\n` +
      `Responda SEMPRE em português brasileiro, de forma clara, direta e amigável.\n` +
      `Use exclusivamente os dados reais do motorista abaixo — não invente números.\n\n` +
      `DADOS FINANCEIROS — ${monthName}:\n` +
      contextLines.map((l) => `• ${l}`).join('\n') +
      `\n\nINSTRUÇÕES:\n` +
      `- Cite os valores reais ao responder perguntas numéricas\n` +
      `- Se perguntarem sobre dados indisponíveis, diga claramente\n` +
      `- Dê dicas práticas quando relevante\n` +
      `- Respostas concisas: máximo 3 parágrafos`;

    const anthropic = new Anthropic({
      apiKey: Deno.env.get('ANTHROPIC_API_KEY') ?? '',
    });

    const aiResponse = await anthropic.messages.create({
      model: 'claude-haiku-4-5-20251001',
      max_tokens: 1024,
      system: systemPrompt,
      messages: messages.map((m) => ({ role: m.role, content: m.content })),
    });

    const content =
      aiResponse.content[0].type === 'text'
        ? aiResponse.content[0].text
        : '';

    return new Response(JSON.stringify({ content }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (error) {
    console.error('ai-chat error:', error);
    return new Response(JSON.stringify({ error: 'Internal server error' }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
