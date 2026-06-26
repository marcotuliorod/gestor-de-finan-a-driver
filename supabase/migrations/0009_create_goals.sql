CREATE TABLE goals (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                 UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  monthly_target_cents    INTEGER NOT NULL CHECK (monthly_target_cents > 0),
  working_days_per_month  INTEGER NOT NULL DEFAULT 26,
  period_start            DATE NOT NULL,
  period_end              DATE NOT NULL,
  created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE goals ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users_own_goals" ON goals USING (auth.uid() = user_id);
CREATE INDEX idx_goals_user_period ON goals(user_id, period_start);

CREATE TRIGGER set_goals_updated_at
  BEFORE UPDATE ON goals
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
