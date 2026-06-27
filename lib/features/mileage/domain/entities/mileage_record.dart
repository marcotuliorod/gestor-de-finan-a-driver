class MileageRecord {
  const MileageRecord({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.startOdometer,
    required this.endOdometer,
    required this.workKm,
    required this.personalKm,
    required this.recordDate,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String vehicleId;
  final int startOdometer;
  final int endOdometer;
  final int workKm;
  final int personalKm;
  final DateTime recordDate;
  final DateTime createdAt;

  int get totalKm => endOdometer - startOdometer;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MileageRecord && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
