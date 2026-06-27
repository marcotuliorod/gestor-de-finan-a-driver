class PlatformStats {
  const PlatformStats({
    required this.platformName,
    required this.incomeCents,
    required this.tripCount,
  });

  final String platformName;
  final int incomeCents;
  final int tripCount;

  int get averageCents => tripCount > 0 ? (incomeCents / tripCount).round() : 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlatformStats && other.platformName == platformName;

  @override
  int get hashCode => platformName.hashCode;
}
