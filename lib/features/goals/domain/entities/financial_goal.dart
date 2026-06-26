class FinancialGoal {
  const FinancialGoal({
    required this.id,
    required this.userId,
    required this.monthlyTargetCents,
    required this.workingDaysPerMonth,
    required this.periodStart,
    required this.periodEnd,
  });

  final String id;
  final String userId;
  final int monthlyTargetCents;
  final int workingDaysPerMonth;
  final DateTime periodStart;
  final DateTime periodEnd;

  int get dailyTargetCents => monthlyTargetCents ~/ workingDaysPerMonth;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FinancialGoal && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
