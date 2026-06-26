CREATE TABLE fuel_records (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  expense_id  UUID NOT NULL REFERENCES expenses(id) ON DELETE CASCADE,
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  vehicle_id  UUID NOT NULL REFERENCES vehicles(id),
  liters      NUMERIC(6,3) NOT NULL CHECK (liters > 0),
  odometer    INTEGER NOT NULL CHECK (odometer >= 0),
  fuel_type   TEXT NOT NULL CHECK (fuel_type IN ('gasoline','ethanol','diesel')),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE fuel_records ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users_own_fuel_records" ON fuel_records USING (auth.uid() = user_id);
CREATE INDEX idx_fuel_records_vehicle_id ON fuel_records(vehicle_id);
