CREATE TABLE mileage_records (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  vehicle_id      UUID NOT NULL REFERENCES vehicles(id),
  start_odometer  INTEGER NOT NULL,
  end_odometer    INTEGER NOT NULL,
  work_km         INTEGER NOT NULL DEFAULT 0,
  personal_km     INTEGER NOT NULL DEFAULT 0,
  record_date     DATE NOT NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at      TIMESTAMPTZ,
  CONSTRAINT chk_odometer CHECK (end_odometer >= start_odometer),
  CONSTRAINT chk_km_sum CHECK (work_km + personal_km = end_odometer - start_odometer)
);

ALTER TABLE mileage_records ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users_own_mileage" ON mileage_records
  USING (current_setting('app.current_user_id', true)::uuid = user_id);
CREATE INDEX idx_mileage_user_date ON mileage_records(user_id, record_date DESC);

CREATE TRIGGER set_mileage_updated_at
  BEFORE UPDATE ON mileage_records
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
