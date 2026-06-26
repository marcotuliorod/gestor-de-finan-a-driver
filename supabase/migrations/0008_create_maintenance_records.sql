CREATE TABLE maintenance_records (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id               UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  vehicle_id            UUID NOT NULL REFERENCES vehicles(id),
  type                  TEXT NOT NULL CHECK (type IN (
                          'oil_change','tire_change','general_revision','brakes',
                          'coolant','battery','air_filter','other'
                        )),
  description           TEXT,
  cost_cents            INTEGER NOT NULL CHECK (cost_cents >= 0),
  odometer              INTEGER NOT NULL,
  maintenance_date      DATE NOT NULL,
  next_maintenance_km   INTEGER,
  next_maintenance_date DATE,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at            TIMESTAMPTZ
);

ALTER TABLE maintenance_records ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users_own_maintenance" ON maintenance_records USING (auth.uid() = user_id);
CREATE INDEX idx_maintenance_vehicle_id ON maintenance_records(vehicle_id, maintenance_date DESC);

CREATE TRIGGER set_maintenance_updated_at
  BEFORE UPDATE ON maintenance_records
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
