# Modelo de Domínio — Driver Finance AI

_Gerado pelo Architect Agent | 2026-06-26 | DDD: Entities, Value Objects, Aggregates, Domain Events_

---

## Bounded Contexts

```
┌──────────────────────────────────────────────────────────────┐
│                  IDENTITY CONTEXT                            │
│  Driver (motorista) — entidade raiz; autenticação           │
└──────────────────────────────────────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────────────────────────────┐
│                  FLEET CONTEXT                               │
│  Vehicle (veículo) — agregado central; depreciação           │
│  Platform (plataforma de trabalho)                           │
└──────────────────────────────────────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────────────────────────────┐
│                  OPERATIONS CONTEXT                          │
│  Trip (corrida/entrega) — receita bruta                      │
│  Expense (despesa) — todos os custos                         │
│  FuelRecord (abastecimento) — sub-tipo de Expense           │
│  MileageRecord (quilometragem) — km trabalho/pessoal         │
└──────────────────────────────────────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────────────────────────────┐
│                  MAINTENANCE CONTEXT                         │
│  MaintenanceRecord — histórico de manutenções                │
│  MaintenanceSchedule — próximas revisões + alertas           │
└──────────────────────────────────────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────────────────────────────┐
│                  ANALYTICS CONTEXT                           │
│  Goal (meta financeira)                                      │
│  Profit (lucro calculado — Value Object)                     │
│  PlatformSummary (comparativo de plataformas)                │
└──────────────────────────────────────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────────────────────────────┐
│                  AI CONTEXT                                  │
│  AIConversation — histórico de chats                         │
│  AIMessage — mensagem individual                             │
│  UserDataContext — contexto sanitizado para envio à IA       │
└──────────────────────────────────────────────────────────────┘
```

---

## Entidades

### Driver (Motorista)
```dart
class Driver {
  final String id;                     // UUID — Supabase Auth UID
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final List<Platform> activePlatforms;
  final Vehicle? primaryVehicle;       // MVP: 1 veículo
  final MonthlyGoal? currentGoal;
  final DateTime createdAt;
}
```

### Vehicle (Veículo)
```dart
class Vehicle {
  final String id;
  final String driverId;
  final String make;                   // ex: "Toyota"
  final String model;                  // ex: "Corolla"
  final int year;
  final String licensePlate;
  final FuelType fuelType;             // gasoline | ethanol | diesel | flex
  final double tankCapacityLiters;
  final Money purchasePrice;
  final int usefulLifeMonths;          // padrão: 60
  final double residualValuePercent;   // padrão: 0.20
  final int currentOdometer;           // km atual
  final DateTime createdAt;
  final DateTime? deletedAt;

  // Regra de domínio
  Money get monthlyDepreciation =>
    (purchasePrice * (1 - residualValuePercent)) / usefulLifeMonths;
}
```

### Platform (Plataforma)
```dart
class Platform {
  final String id;
  final String driverId;
  final PlatformType type;             // uber | app99 | indrive | taxi | delivery | custom
  final String? customName;            // se type == custom
  final bool isActive;
  final DateTime createdAt;
}

enum PlatformType { uber, app99, indrive, taxi, delivery, custom }
```

### Trip (Corrida/Entrega)
```dart
class Trip {
  final String id;
  final String driverId;
  final String platformId;
  final Money grossAmount;             // valor bruto pago pela plataforma
  final Money bonusAmount;             // bônus de desempenho
  final Money tipAmount;               // gorjeta
  final Money promotionAmount;         // promoções
  final Money cancellationAmount;      // compensação por cancelamento
  final DateTime tripDate;
  final DateTime createdAt;
  final DateTime? deletedAt;

  // Value Object derivado
  Money get totalIncome =>
    grossAmount + bonusAmount + tipAmount + promotionAmount + cancellationAmount;
}
```

### Expense (Despesa)
```dart
class Expense {
  final String id;
  final String driverId;
  final String vehicleId;
  final ExpenseCategory category;
  final Money amount;
  final String? description;
  final DateTime expenseDate;
  final bool isRecurring;
  final RecurrenceType? recurrenceType;  // monthly | annual
  final DateTime createdAt;
  final DateTime? deletedAt;
}

enum ExpenseCategory {
  fuel, carWash, toll, insurance, vehicleTax, licensing,
  financing, parking, internet, maintenance, tireChange,
  oilChange, other
}
```

### FuelRecord (Abastecimento)
_Subtype de Expense com campos adicionais_
```dart
class FuelRecord extends Expense {
  final double liters;
  final int odometer;                  // km no momento do abastecimento
  final FuelType fuelType;

  // Regra de domínio
  Money get pricePerLiter => amount / liters;
}
```

### MileageRecord (Quilometragem)
```dart
class MileageRecord {
  final String id;
  final String driverId;
  final String vehicleId;
  final int startOdometer;
  final int endOdometer;
  final int workKm;                    // km usado no trabalho
  final int personalKm;                // km uso pessoal
  final DateTime recordDate;
  final DateTime createdAt;

  // Regra de domínio
  int get totalKm => endOdometer - startOdometer;

  // Invariante
  bool get isValid => workKm + personalKm == totalKm;
}
```

### MaintenanceRecord (Manutenção)
```dart
class MaintenanceRecord {
  final String id;
  final String driverId;
  final String vehicleId;
  final MaintenanceType type;
  final String? description;
  final Money cost;
  final int odometer;
  final DateTime maintenanceDate;
  final int? nextMaintenanceKm;        // próxima revisão em km
  final DateTime? nextMaintenanceDate; // ou por data
  final DateTime createdAt;
}

enum MaintenanceType {
  oilChange, tireChange, generalRevision, brakes,
  coolant, battery, airFilter, other
}
```

### Goal (Meta Financeira)
```dart
class Goal {
  final String id;
  final String driverId;
  final Money monthlyTarget;
  final int workingDaysPerMonth;       // padrão: 26
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime createdAt;

  // Regras de domínio
  Money get dailyTarget => monthlyTarget / workingDaysPerMonth;

  double progressPercent(Money currentProfit) =>
    (currentProfit / monthlyTarget).clamp(0.0, 1.0);

  Money remainingToReach(Money currentProfit) =>
    (monthlyTarget - currentProfit).clampMin(Money.zero);
}
```

---

## Value Objects

### Money (Valor Monetário)
```dart
class Money {
  final int centavos;  // armazenado em centavos para evitar float issues

  static Money fromReais(double reais) => Money(centavos: (reais * 100).round());
  double get reais => centavos / 100;

  Money operator +(Money other) => Money(centavos: centavos + other.centavos);
  Money operator -(Money other) => Money(centavos: centavos - other.centavos);
  Money operator *(double factor) => Money(centavos: (centavos * factor).round());
  Money operator /(double divisor) => Money(centavos: (centavos / divisor).round());
  Money clampMin(Money min) => centavos < min.centavos ? min : this;

  static final zero = Money(centavos: 0);
}
```

### Profit (Lucro Calculado)
_Value Object derivado, não persistido diretamente_
```dart
class Profit {
  final Money grossRevenue;
  final Money totalExpenses;
  final Money depreciation;  // custo implícito do período

  Money get netProfit => grossRevenue - totalExpenses - depreciation;
  double get margin => netProfit.centavos / grossRevenue.centavos;

  // Métricas derivadas
  Money costPerKm(int workKm) => totalExpenses / workKm.toDouble();
  Money revenuePerKm(int workKm) => grossRevenue / workKm.toDouble();
  Money profitPerKm(int workKm) => netProfit / workKm.toDouble();
  Money profitPerHour(double hoursWorked) => netProfit / hoursWorked;
}
```

### DateRange (Período de Análise)
```dart
class DateRange {
  final DateTime start;
  final DateTime end;

  static DateRange today() => ...;
  static DateRange thisWeek() => ...;
  static DateRange thisMonth() => ...;
  static DateRange custom(DateTime s, DateTime e) => ...;

  bool contains(DateTime date) => date.isAfter(start) && date.isBefore(end);
}
```

---

## Domain Events

```dart
// Disparados após operações de escrita — para triggar side effects (sync, notificações)
abstract class DomainEvent { final DateTime occurredAt; }

class TripAdded extends DomainEvent { final Trip trip; }
class ExpenseAdded extends DomainEvent { final Expense expense; }
class GoalReached extends DomainEvent { final Goal goal; final Money achieved; }
class MaintenanceAlertTriggered extends DomainEvent { final MaintenanceRecord maintenance; }
class FuelConsumptionCalculated extends DomainEvent { final FuelRecord record; final double kmPerLiter; }
```

---

## Repositórios (Interfaces)

```dart
// Todas as interfaces retornam Either<Failure, T>
abstract class TripRepository {
  Future<Either<Failure, Trip>> add(Trip trip);
  Future<Either<Failure, Trip>> update(Trip trip);
  Future<Either<Failure, void>> delete(String tripId);
  Future<Either<Failure, List<Trip>>> getByPeriod(DateRange range);
  Future<Either<Failure, List<Trip>>> getByPlatform(String platformId, DateRange range);
  Stream<List<Trip>> watchByPeriod(DateRange range);  // stream para UI reativa
}

abstract class ExpenseRepository {
  Future<Either<Failure, Expense>> add(Expense expense);
  Future<Either<Failure, Expense>> update(Expense expense);
  Future<Either<Failure, void>> delete(String expenseId);
  Future<Either<Failure, List<Expense>>> getByPeriod(DateRange range);
  Future<Either<Failure, Map<ExpenseCategory, Money>>> getTotalsByCategory(DateRange range);
}

abstract class VehicleRepository {
  Future<Either<Failure, Vehicle>> save(Vehicle vehicle);
  Future<Either<Failure, Vehicle?>> getPrimary();
}

abstract class MaintenanceRepository {
  Future<Either<Failure, MaintenanceRecord>> add(MaintenanceRecord record);
  Future<Either<Failure, List<MaintenanceRecord>>> getHistory(String vehicleId);
  Future<Either<Failure, List<MaintenanceRecord>>> getPendingAlerts(String vehicleId, int currentOdometer);
}

abstract class GoalRepository {
  Future<Either<Failure, Goal>> save(Goal goal);
  Future<Either<Failure, Goal?>> getCurrent();
}

abstract class AIConversationRepository {
  Future<Either<Failure, AIMessage>> sendMessage(String question, UserDataContext context);
  Future<Either<Failure, List<AIConversation>>> getHistory();
}
```
