# Modelo de Dados — Driver Finance AI

_Gerado pelo Database Agent | 2026-06-26_
_PostgreSQL (Supabase) + SQLite local (Drift)_

---

## Convenções Globais

- Todas as tabelas: `id UUID PK`, `user_id UUID FK`, `created_at TIMESTAMPTZ`, `updated_at TIMESTAMPTZ`, `deleted_at TIMESTAMPTZ` (soft delete)
- Valores monetários: `INTEGER` em centavos (evita floating point)
- Timestamps: sempre `TIMESTAMPTZ` (com fuso horário)
- RLS: habilitada em todas as tabelas com policy `auth.uid() = user_id`
- Trigger: `update updated_at` automático em toda UPDATE

---

## Schema PostgreSQL (Supabase)

### Tabela: `vehicles`

```sql
CREATE TABLE vehicles (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    make            TEXT NOT NULL,
    model           TEXT NOT NULL,
    year            INTEGER NOT NULL CHECK (year >= 1980 AND year <= 2030),
    license_plate   TEXT NOT NULL,
    fuel_type       TEXT NOT NULL CHECK (fuel_type IN ('gasoline','ethanol','diesel','flex')),
    tank_capacity_l NUMERIC(5,2) NOT NULL CHECK (tank_capacity_l > 0),
    purchase_price_cents INTEGER NOT NULL CHECK (purchase_price_cents > 0),
    useful_life_months   INTEGER NOT NULL DEFAULT 60,
    residual_value_pct   NUMERIC(4,3) NOT NULL DEFAULT 0.200,
    current_odometer     INTEGER NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);

ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users_own_vehicles" ON vehicles USING (auth.uid() = user_id);
CREATE INDEX idx_vehicles_user_id ON vehicles(user_id);
```

### Tabela: `platforms`

```sql
CREATE TABLE platforms (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    type        TEXT NOT NULL CHECK (type IN ('uber','app99','indrive','taxi','delivery','custom')),
    custom_name TEXT,  -- obrigatório quando type = 'custom'
    is_active   BOOLEAN NOT NULL DEFAULT true,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ,
    CONSTRAINT chk_custom_name CHECK (type != 'custom' OR custom_name IS NOT NULL)
);

ALTER TABLE platforms ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users_own_platforms" ON platforms USING (auth.uid() = user_id);
CREATE INDEX idx_platforms_user_id ON platforms(user_id);
```

### Tabela: `trips`

```sql
CREATE TABLE trips (
    id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id               UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    platform_id           UUID NOT NULL REFERENCES platforms(id),
    gross_amount_cents    INTEGER NOT NULL CHECK (gross_amount_cents >= 0),
    bonus_amount_cents    INTEGER NOT NULL DEFAULT 0 CHECK (bonus_amount_cents >= 0),
    tip_amount_cents      INTEGER NOT NULL DEFAULT 0 CHECK (tip_amount_cents >= 0),
    promotion_cents       INTEGER NOT NULL DEFAULT 0 CHECK (promotion_cents >= 0),
    cancellation_cents    INTEGER NOT NULL DEFAULT 0 CHECK (cancellation_cents >= 0),
    trip_date             DATE NOT NULL,
    notes                 TEXT,
    created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at            TIMESTAMPTZ
);

ALTER TABLE trips ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users_own_trips" ON trips USING (auth.uid() = user_id);
CREATE INDEX idx_trips_user_id ON trips(user_id);
CREATE INDEX idx_trips_trip_date ON trips(trip_date DESC);
CREATE INDEX idx_trips_platform_id ON trips(platform_id);
```

### Tabela: `expenses`

```sql
CREATE TABLE expenses (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id          UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    vehicle_id       UUID REFERENCES vehicles(id),
    category         TEXT NOT NULL CHECK (category IN (
                       'fuel','car_wash','toll','insurance','vehicle_tax','licensing',
                       'financing','parking','internet','maintenance','tire_change',
                       'oil_change','other'
                     )),
    amount_cents     INTEGER NOT NULL CHECK (amount_cents > 0),
    description      TEXT,
    expense_date     DATE NOT NULL,
    is_recurring     BOOLEAN NOT NULL DEFAULT false,
    recurrence_type  TEXT CHECK (recurrence_type IN ('monthly','annual')),
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at       TIMESTAMPTZ
);

ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users_own_expenses" ON expenses USING (auth.uid() = user_id);
CREATE INDEX idx_expenses_user_id ON expenses(user_id);
CREATE INDEX idx_expenses_expense_date ON expenses(expense_date DESC);
CREATE INDEX idx_expenses_category ON expenses(category);
```

### Tabela: `fuel_records`

```sql
CREATE TABLE fuel_records (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    expense_id       UUID NOT NULL REFERENCES expenses(id) ON DELETE CASCADE,
    user_id          UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    vehicle_id       UUID NOT NULL REFERENCES vehicles(id),
    liters           NUMERIC(6,3) NOT NULL CHECK (liters > 0),
    odometer         INTEGER NOT NULL CHECK (odometer >= 0),
    fuel_type        TEXT NOT NULL CHECK (fuel_type IN ('gasoline','ethanol','diesel')),
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE fuel_records ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users_own_fuel_records" ON fuel_records USING (auth.uid() = user_id);
CREATE INDEX idx_fuel_records_vehicle_id ON fuel_records(vehicle_id);
```

### Tabela: `mileage_records`

```sql
CREATE TABLE mileage_records (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id          UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    vehicle_id       UUID NOT NULL REFERENCES vehicles(id),
    start_odometer   INTEGER NOT NULL,
    end_odometer     INTEGER NOT NULL,
    work_km          INTEGER NOT NULL DEFAULT 0,
    personal_km      INTEGER NOT NULL DEFAULT 0,
    record_date      DATE NOT NULL,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at       TIMESTAMPTZ,
    CONSTRAINT chk_odometer CHECK (end_odometer >= start_odometer),
    CONSTRAINT chk_km_sum CHECK (work_km + personal_km = end_odometer - start_odometer)
);

ALTER TABLE mileage_records ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users_own_mileage" ON mileage_records USING (auth.uid() = user_id);
CREATE INDEX idx_mileage_user_date ON mileage_records(user_id, record_date DESC);
```

### Tabela: `maintenance_records`

```sql
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
```

### Tabela: `goals`

```sql
CREATE TABLE goals (
    id                        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                   UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    monthly_target_cents      INTEGER NOT NULL CHECK (monthly_target_cents > 0),
    working_days_per_month    INTEGER NOT NULL DEFAULT 26,
    period_start              DATE NOT NULL,
    period_end                DATE NOT NULL,
    created_at                TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at                TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE goals ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users_own_goals" ON goals USING (auth.uid() = user_id);
CREATE INDEX idx_goals_user_period ON goals(user_id, period_start);
```

### Tabela: `ai_conversations`

```sql
CREATE TABLE ai_conversations (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title      TEXT,  -- gerado automaticamente a partir da 1ª pergunta
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
```

---

## Views Úteis

```sql
-- Resumo mensal por usuário (não é tabela, é view para leitura)
CREATE VIEW monthly_summary AS
SELECT
    t.user_id,
    DATE_TRUNC('month', t.trip_date) AS month,
    SUM(t.gross_amount_cents + t.bonus_amount_cents + t.tip_amount_cents
        + t.promotion_cents + t.cancellation_cents) AS total_income_cents,
    COUNT(t.id) AS trip_count
FROM trips t
WHERE t.deleted_at IS NULL
GROUP BY t.user_id, DATE_TRUNC('month', t.trip_date);
```

---

## Trigger: updated_at automático

```sql
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar em todas as tabelas
CREATE TRIGGER set_updated_at BEFORE UPDATE ON vehicles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
-- (repetir para trips, expenses, mileage_records, etc.)
```

---

## Schema SQLite Local (Drift)

_Espelho do PostgreSQL com campos de sincronização adicionais._

```dart
// Exemplo: tabela de trips no Drift
class Trips extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get platformId => text()();
  IntColumn get grossAmountCents => integer()();
  IntColumn get bonusAmountCents => integer().withDefault(const Constant(0))();
  IntColumn get tipAmountCents => integer().withDefault(const Constant(0))();
  IntColumn get promotionCents => integer().withDefault(const Constant(0))();
  IntColumn get cancellationCents => integer().withDefault(const Constant(0))();
  DateTimeColumn get tripDate => dateTime()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  // Campos de sync
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
```

### Tabela Extra Local: `sync_queue`

```dart
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get recordId => text()();
  TextColumn get tableName => text()();
  TextColumn get operation => text()();  // 'upsert' | 'delete'
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
}
```
