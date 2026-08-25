CREATE TABLE trips (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id               UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  platform_id           UUID NOT NULL REFERENCES platforms(id),
  gross_amount_cents    INTEGER NOT NULL CHECK (gross_amount_cents >= 0),
  bonus_amount_cents    INTEGER NOT NULL DEFAULT 0 CHECK (bonus_amount_cents >= 0),
  tip_amount_cents      INTEGER NOT NULL DEFAULT 0 CHECK (tip_amount_cents >= 0),
  promotion_cents       INTEGER NOT NULL DEFAULT 0 CHECK (promotion_cents >= 0),
  cancellation_cents    INTEGER NOT NULL DEFAULT 0 CHECK (cancellation_cents >= 0),
  duration_minutes      INTEGER,
  trip_date             DATE NOT NULL,
  notes                 TEXT,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at            TIMESTAMPTZ
);

ALTER TABLE trips ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users_own_trips" ON trips
  USING (current_setting('app.current_user_id', true)::uuid = user_id);
CREATE INDEX idx_trips_user_id ON trips(user_id);
CREATE INDEX idx_trips_trip_date ON trips(trip_date DESC);
CREATE INDEX idx_trips_platform_id ON trips(platform_id);

CREATE TRIGGER set_trips_updated_at
  BEFORE UPDATE ON trips
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
