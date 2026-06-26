CREATE TABLE ai_conversations (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title      TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE ai_messages (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES ai_conversations(id) ON DELETE CASCADE,
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role            TEXT NOT NULL CHECK (role IN ('user','assistant')),
  content         TEXT NOT NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE ai_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users_own_conversations" ON ai_conversations USING (auth.uid() = user_id);
CREATE POLICY "users_own_messages" ON ai_messages USING (auth.uid() = user_id);

CREATE TRIGGER set_ai_conversations_updated_at
  BEFORE UPDATE ON ai_conversations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Monthly summary view
CREATE VIEW monthly_summary AS
SELECT
  t.user_id,
  DATE_TRUNC('month', t.trip_date) AS month,
  SUM(
    t.gross_amount_cents + t.bonus_amount_cents + t.tip_amount_cents
    + t.promotion_cents + t.cancellation_cents
  ) AS total_income_cents,
  COUNT(t.id) AS trip_count
FROM trips t
WHERE t.deleted_at IS NULL
GROUP BY t.user_id, DATE_TRUNC('month', t.trip_date);
