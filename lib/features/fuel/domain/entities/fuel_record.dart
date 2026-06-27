class FuelRecord {
  const FuelRecord({
    required this.id,
    required this.expenseId,
    required this.userId,
    required this.vehicleId,
    required this.amountCents,
    required this.liters,
    required this.odometer,
    required this.fuelType,
    required this.recordDate,
    required this.createdAt,
  });

  final String id;
  final String expenseId;
  final String userId;
  final String vehicleId;
  final int amountCents;
  final double liters;
  final int odometer;
  final String fuelType;
  final DateTime recordDate;
  final DateTime createdAt;

  double get pricePerLiter => liters > 0 ? amountCents / (liters * 100) : 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FuelRecord && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
