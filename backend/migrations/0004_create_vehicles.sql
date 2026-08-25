CREATE TABLE vehicles (
  id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id              UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  make                 TEXT NOT NULL,
  model                TEXT NOT NULL,
  year                 INTEGER NOT NULL CHECK (year >= 1980 AND year <= 2030),
  license_plate        TEXT NOT NULL,
  fuel_type            TEXT NOT NULL CHECK (fuel_type IN ('gasoline','ethanol','diesel','flex')),
  tank_capacity_l      NUMERIC(5,2) NOT NULL CHECK (tank_capacity_l > 0),
  purchase_price_cents INTEGER NOT NULL CHECK (purchase_price_cents > 0),
  useful_life_months   INTEGER NOT NULL DEFAULT 60,
  residual_value_pct   NUMERIC(4,3) NOT NULL DEFAULT 0.200,
  current_odometer     INTEGER NOT NULL DEFAULT 0,
  created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at           TIMESTAMPTZ
);

ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users_own_vehicles" ON vehicles
  USING (current_setting('app.current_user_id', true)::uuid = user_id);
CREATE INDEX idx_vehicles_user_id ON vehicles(user_id);

CREATE TRIGGER set_vehicles_updated_at
  BEFORE UPDATE ON vehicles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
