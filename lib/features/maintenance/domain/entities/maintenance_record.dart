class MaintenanceRecord {
  const MaintenanceRecord({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.type,
    this.description,
    required this.costCents,
    required this.odometer,
    required this.maintenanceDate,
    this.nextMaintenanceKm,
    this.nextMaintenanceDate,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String vehicleId;
  final String type;
  final String? description;
  final int costCents;
  final int odometer;
  final DateTime maintenanceDate;
  final int? nextMaintenanceKm;
  final DateTime? nextMaintenanceDate;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MaintenanceRecord && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
