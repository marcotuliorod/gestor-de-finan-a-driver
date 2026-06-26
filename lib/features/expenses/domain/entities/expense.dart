enum ExpenseCategory {
  fuel,
  carWash,
  toll,
  insurance,
  vehicleTax,
  licensing,
  financing,
  parking,
  internet,
  maintenance,
  tireChange,
  oilChange,
  other;

  String get label => switch (this) {
        ExpenseCategory.fuel => 'Combustível',
        ExpenseCategory.carWash => 'Lavagem',
        ExpenseCategory.toll => 'Pedágio',
        ExpenseCategory.insurance => 'Seguro',
        ExpenseCategory.vehicleTax => 'IPVA',
        ExpenseCategory.licensing => 'Licenciamento',
        ExpenseCategory.financing => 'Financiamento',
        ExpenseCategory.parking => 'Estacionamento',
        ExpenseCategory.internet => 'Internet',
        ExpenseCategory.maintenance => 'Manutenção',
        ExpenseCategory.tireChange => 'Troca de pneu',
        ExpenseCategory.oilChange => 'Troca de óleo',
        ExpenseCategory.other => 'Outros',
      };

  String get dbValue => switch (this) {
        ExpenseCategory.fuel => 'fuel',
        ExpenseCategory.carWash => 'car_wash',
        ExpenseCategory.toll => 'toll',
        ExpenseCategory.insurance => 'insurance',
        ExpenseCategory.vehicleTax => 'vehicle_tax',
        ExpenseCategory.licensing => 'licensing',
        ExpenseCategory.financing => 'financing',
        ExpenseCategory.parking => 'parking',
        ExpenseCategory.internet => 'internet',
        ExpenseCategory.maintenance => 'maintenance',
        ExpenseCategory.tireChange => 'tire_change',
        ExpenseCategory.oilChange => 'oil_change',
        ExpenseCategory.other => 'other',
      };

  static ExpenseCategory fromDb(String value) => switch (value) {
        'fuel' => ExpenseCategory.fuel,
        'car_wash' => ExpenseCategory.carWash,
        'toll' => ExpenseCategory.toll,
        'insurance' => ExpenseCategory.insurance,
        'vehicle_tax' => ExpenseCategory.vehicleTax,
        'licensing' => ExpenseCategory.licensing,
        'financing' => ExpenseCategory.financing,
        'parking' => ExpenseCategory.parking,
        'internet' => ExpenseCategory.internet,
        'maintenance' => ExpenseCategory.maintenance,
        'tire_change' => ExpenseCategory.tireChange,
        'oil_change' => ExpenseCategory.oilChange,
        _ => ExpenseCategory.other,
      };
}

class Expense {
  const Expense({
    required this.id,
    required this.userId,
    this.vehicleId,
    required this.category,
    required this.amountCents,
    this.description,
    required this.expenseDate,
    this.isRecurring = false,
    this.recurrenceType,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String? vehicleId;
  final ExpenseCategory category;
  final int amountCents;
  final String? description;
  final DateTime expenseDate;
  final bool isRecurring;
  final String? recurrenceType;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Expense && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
