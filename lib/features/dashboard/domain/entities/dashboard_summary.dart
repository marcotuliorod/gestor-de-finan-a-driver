class DashboardSummary {
  const DashboardSummary({
    required this.totalIncomeCents,
    required this.otherExpenseCents,
    required this.fuelExpenseCents,
    required this.tripCount,
    this.monthlyGoalCents,
    this.goalProgress,
  });

  final int totalIncomeCents;
  final int otherExpenseCents;
  final int fuelExpenseCents;
  final int tripCount;
  final int? monthlyGoalCents;
  final double? goalProgress;

  int get totalExpensesCents => otherExpenseCents + fuelExpenseCents;
  int get netProfitCents => totalIncomeCents - totalExpensesCents;
  bool get isGoalMet => goalProgress != null && goalProgress! >= 1.0;
}
