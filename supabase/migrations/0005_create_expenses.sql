CREATE TABLE expenses (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  vehicle_id      UUID REFERENCES vehicles(id),
  category        TEXT NOT NULL CHECK (category IN (
                    'fuel','car_wash','toll','insurance','vehicle_tax','licensing',
                    'financing','parking','internet','maintenance','tire_change',
                    'oil_change','other'
                  )),
  amount_cents    INTEGER NOT NULL CHECK (amount_cents > 0),
  description     TEXT,
  expense_date    DATE NOT NULL,
  is_recurring    BOOLEAN NOT NULL DEFAULT false,
  recurrence_type TEXT CHECK (recurrence_type IN ('monthly','annual')),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at      TIMESTAMPTZ
);

ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users_own_expenses" ON expenses USING (auth.uid() = user_id);
CREATE INDEX idx_expenses_user_id ON expenses(user_id);
CREATE INDEX idx_expenses_expense_date ON expenses(expense_date DESC);
CREATE INDEX idx_expenses_category ON expenses(category);

CREATE TRIGGER set_expenses_updated_at
  BEFORE UPDATE ON expenses
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
