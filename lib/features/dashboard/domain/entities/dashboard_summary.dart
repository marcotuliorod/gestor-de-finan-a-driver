import 'package:driver_finance/features/dashboard/domain/entities/daily_revenue.dart';

class DashboardSummary {
  const DashboardSummary({
    required this.totalIncomeCents,
    required this.otherExpenseCents,
    required this.fuelExpenseCents,
    required this.tripCount,
    this.depreciationCents = 0,
    this.monthlyGoalCents,
    this.goalProgress,
    this.dailyRevenues = const [],
  });

  final int totalIncomeCents;
  final int otherExpenseCents;
  final int fuelExpenseCents;
  final int tripCount;
  final int depreciationCents;
  final int? monthlyGoalCents;
  final double? goalProgress;
  final List<DailyRevenue> dailyRevenues;

  int get totalExpensesCents =>
      otherExpenseCents + fuelExpenseCents + depreciationCents;
  int get netProfitCents => totalIncomeCents - totalExpensesCents;
  bool get isGoalMet => goalProgress != null && goalProgress! >= 1.0;
}
