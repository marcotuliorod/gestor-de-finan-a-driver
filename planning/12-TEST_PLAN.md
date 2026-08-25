# Plano de Testes — Driver Finance AI

_Gerado pelo QA Agent | 2026-06-26_

---

## Objetivos

- Cobertura mínima de **80%** em todo código novo
- Camada de domínio (entidades + use cases): **90%**
- Todos os use cases críticos com teste de happy path + mínimo 2 failure paths
- CI gate: build não passa se cobertura cair abaixo de 80%

---

## Pirâmide de Testes

```
                  /\
                 /  \
                / E2E \          (futuro — Maestro ou Flutter Driver)
               /────────\
              /Integration\      (testes de repositórios com banco real local)
             /──────────────\
            /   Widget Tests  \  (telas e componentes críticos)
           /────────────────────\
          /     Unit Tests       \  (domínio, use cases, utils)
         /────────────────────────\
```

---

## Camada 1: Unit Tests

### Domain — Entidades e Value Objects

| Arquivo de Teste | O que Testar |
|-----------------|-------------|
| `test/features/trips/domain/entities/trip_test.dart` | `totalIncome` com todos os campos; totalIncome quando tudo zero |
| `test/features/expenses/domain/entities/fuel_record_test.dart` | `pricePerLiter` correto; divisão por zero quando liters = 0 |
| `test/features/vehicles/domain/entities/vehicle_test.dart` | `monthlyDepreciation` com valores padrão e customizados |
| `test/features/goals/domain/entities/goal_test.dart` | `dailyTarget`, `progressPercent` 0%, 50%, 100%, acima de 100% |
| `test/core/domain/value_objects/money_test.dart` | Soma, subtração, multiplicação, divisão, clampMin, zero |
| `test/core/domain/value_objects/profit_test.dart` | `netProfit`, `margin`, `costPerKm`, `profitPerHour` |

### Domain — Use Cases

| Arquivo de Teste | Cenários |
|-----------------|---------|
| `test/features/trips/domain/use_cases/add_trip_test.dart` | ✓ Salva trip válida; ✗ amount negativo; ✗ plataforma não encontrada |
| `test/features/trips/domain/use_cases/get_trips_by_period_test.dart` | ✓ Retorna trips do período; ✓ Retorna lista vazia; ✗ repository falha |
| `test/features/expenses/domain/use_cases/add_expense_test.dart` | ✓ Salva despesa válida; ✗ amount zero; ✗ categoria inválida |
| `test/features/expenses/domain/use_cases/add_fuel_record_test.dart` | ✓ Salva com km válido; ✗ litros zero; ✗ km menor que anterior |
| `test/features/dashboard/domain/use_cases/calculate_profit_test.dart` | ✓ Com receitas e despesas; ✓ Sem despesas (lucro = receita); ✓ Prejuízo |
| `test/features/maintenance/domain/use_cases/check_alerts_test.dart` | ✓ Alerta quando próximo; ✓ Alerta quando atrasado; ✓ Nenhum alerta |
| `test/features/goals/domain/use_cases/calculate_goal_progress_test.dart` | ✓ 0%, 50%, 100%, 120% (acima da meta) |

### Utils e Formatadores

| Arquivo de Teste | O que Testar |
|-----------------|-------------|
| `test/core/utils/currency_formatter_test.dart` | Format R$0,00; R$1.000,00; negativos; compact |
| `test/core/utils/date_utils_test.dart` | DateRange.thisMonth() limites; DateRange.thisWeek() limites |

---

## Camada 2: Widget Tests

### Componentes do Design System

```dart
// test/core/ui/components/metric_card_test.dart
void main() {
  testWidgets('metric_card_renders_value_correctly', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MetricCard(title: 'Lucro', value: Money.fromReais(1500)),
    ));
    expect(find.text('R\$ 1.500,00'), findsOneWidget);
    expect(find.text('Lucro'), findsOneWidget);
  });

  testWidgets('metric_card_shows_positive_change_in_green', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MetricCard(
        title: 'Receita',
        value: Money.fromReais(2000),
        change: MetricChange(value: 12.5, direction: ChangeDirection.up),
      ),
    ));
    final textWidget = tester.widget<Text>(find.text('↑ 12,5%'));
    expect((textWidget.style?.color), AppColors.profit);
  });
}
```

### Telas Críticas

| Arquivo | Cenários |
|---------|---------|
| `test/features/dashboard/presentation/pages/dashboard_page_test.dart` | Loading state; dados exibidos; estado vazio com CTA |
| `test/features/trips/presentation/pages/add_trip_page_test.dart` | Campos obrigatórios validados; submit com dados válidos; feedback de sucesso |
| `test/features/expenses/presentation/pages/add_expense_page_test.dart` | Seleção de categoria; valor obrigatório; submit com sucesso |
| `test/features/ai_chat/presentation/pages/ai_chat_page_test.dart` | Input enviado; loading state; resposta exibida; erro de rede |

---

## Camada 3: Integration Tests

_Testam repositórios com banco SQLite real (Drift in-memory)._

```dart
// test/features/trips/data/repositories/trip_repository_impl_test.dart
void main() {
  late AppDatabase database;
  late TripRepositoryImpl sut;

  setUp(() async {
    database = AppDatabase.forTesting(); // in-memory SQLite
    sut = TripRepositoryImpl(local: LocalTripDataSource(database));
  });

  tearDown(() => database.close());

  test('add_trip_when_valid_should_persist_and_return_entity', () async {
    final trip = TripFactory.valid();
    final result = await sut.add(trip);
    expect(result.isRight(), true);
    final saved = result.getRight().toNullable()!;
    expect(saved.id, isNotEmpty);
  });

  test('get_by_period_when_no_trips_should_return_empty_list', () async {
    final result = await sut.getByPeriod(DateRange.thisMonth());
    expect(result.getRight().toNullable(), isEmpty);
  });
}
```

---

## Golden Tests (telas críticas)

```dart
// test/features/dashboard/presentation/pages/dashboard_page_golden_test.dart
void main() {
  testGoldens('dashboard_light_mode_with_data', (tester) async {
    await tester.pumpWidgetBuilder(
      DashboardPage(),
      wrapper: (child) => ProviderScope(
        overrides: [dashboardProvider.overrideWithValue(AsyncValue.data(fakeDashboardData))],
        child: MaterialApp(theme: AppTheme.lightTheme, home: child),
      ),
    );
    await screenMatchesGolden(tester, 'dashboard_light_with_data');
  });
}
```

---

## Factories de Dados de Teste

```dart
// test/helpers/factories/trip_factory.dart
class TripFactory {
  static Trip valid({
    String? id,
    String? platformId,
    Money? grossAmount,
  }) => Trip(
    id: id ?? 'test-trip-id',
    driverId: 'test-driver-id',
    platformId: platformId ?? 'test-platform-id',
    grossAmount: grossAmount ?? Money.fromReais(45.00),
    bonusAmount: Money.zero,
    tipAmount: Money.zero,
    promotionAmount: Money.zero,
    cancellationAmount: Money.zero,
    tripDate: DateTime(2026, 6, 26),
    createdAt: DateTime.now(),
  );
}
```

---

## Mocks Compartilhados

```dart
// test/helpers/mocks/mock_trip_repository.dart
class MockTripRepository extends Mock implements TripRepository {}

// test/helpers/mocks/mock_sync_service.dart
class MockSyncService extends Mock implements SyncService {}
```

---

## CI Gate — GitHub Actions

```yaml
# .github/workflows/test.yml (trecho)
- name: Run tests with coverage
  run: flutter test --coverage

- name: Check coverage threshold
  run: |
    COVERAGE=$(lcov --summary coverage/lcov.info | grep "lines" | grep -o '[0-9.]*%' | head -1)
    echo "Coverage: $COVERAGE"
    # Falha se < 80%
    python3 -c "
    cov = float('$COVERAGE'.replace('%',''))
    assert cov >= 80, f'Coverage {cov}% is below 80% threshold'
    "
```

---

## Estratégia de Dados de Teste

| Camada | Abordagem |
|--------|-----------|
| Unit (Domain) | Dados inline no teste; sem banco |
| Unit (Use Cases) | Mocks (mocktail) para repositórios |
| Widget Tests | Providers overrideados com dados fake |
| Integration | Drift in-memory database (sem I/O) |
| Golden | Dados fake determinísticos fixos |

**Nunca:** Testes que acessam o backend real ou a Claude API — sempre mockar.

---

## Cobertura por Módulo (Meta)

| Módulo | Meta |
|--------|------|
| Domain (entidades + use cases) | 90% |
| Data (repositórios + sources) | 80% |
| Presentation (páginas + widgets críticos) | 70% |
| Core (utils, formatters) | 90% |
| **Global** | **≥ 80%** |
