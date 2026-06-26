class Vehicle {
  const Vehicle({
    required this.id,
    required this.userId,
    required this.make,
    required this.model,
    required this.year,
    required this.licensePlate,
    required this.fuelType,
    required this.tankCapacityL,
    required this.purchasePriceCents,
    this.usefulLifeMonths = 60,
    this.residualValuePct = 0.20,
    this.currentOdometer = 0,
  });

  final String id;
  final String userId;
  final String make;
  final String model;
  final int year;
  final String licensePlate;
  final String fuelType;
  final double tankCapacityL;
  final int purchasePriceCents;
  final int usefulLifeMonths;
  final double residualValuePct;
  final int currentOdometer;

  int get monthlyDepreciationCents {
    final depreciableValue = purchasePriceCents * (1 - residualValuePct);
    return (depreciableValue / usefulLifeMonths).round();
  }

  Vehicle copyWith({
    String? make,
    String? model,
    int? year,
    String? licensePlate,
    String? fuelType,
    double? tankCapacityL,
    int? purchasePriceCents,
    int? usefulLifeMonths,
    double? residualValuePct,
    int? currentOdometer,
  }) {
    return Vehicle(
      id: id,
      userId: userId,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      licensePlate: licensePlate ?? this.licensePlate,
      fuelType: fuelType ?? this.fuelType,
      tankCapacityL: tankCapacityL ?? this.tankCapacityL,
      purchasePriceCents: purchasePriceCents ?? this.purchasePriceCents,
      usefulLifeMonths: usefulLifeMonths ?? this.usefulLifeMonths,
      residualValuePct: residualValuePct ?? this.residualValuePct,
      currentOdometer: currentOdometer ?? this.currentOdometer,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Vehicle && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
