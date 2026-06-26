CREATE TABLE platforms (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  type        TEXT NOT NULL CHECK (type IN ('uber','app99','indrive','taxi','delivery','custom')),
  custom_name TEXT,
  is_active   BOOLEAN NOT NULL DEFAULT true,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at  TIMESTAMPTZ,
  CONSTRAINT chk_custom_name CHECK (type != 'custom' OR custom_name IS NOT NULL)
);

ALTER TABLE platforms ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users_own_platforms" ON platforms USING (auth.uid() = user_id);
CREATE INDEX idx_platforms_user_id ON platforms(user_id);

CREATE TRIGGER set_platforms_updated_at
  BEFORE UPDATE ON platforms
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
