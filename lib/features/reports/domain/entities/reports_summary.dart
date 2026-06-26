class DailyIncome {
  const DailyIncome({required this.date, required this.amountCents});

  final DateTime date;
  final int amountCents;
}

class ReportsSummary {
  const ReportsSummary({
    required this.totalIncomeCents,
    required this.fuelExpenseCents,
    required this.otherExpenseCents,
    required this.tripCount,
    required this.dailyIncomes,
    required this.totalDurationMinutes,
  });

  final int totalIncomeCents;
  final int fuelExpenseCents;
  final int otherExpenseCents;
  final int tripCount;
  final List<DailyIncome> dailyIncomes;
  final int totalDurationMinutes;

  int get totalExpensesCents => fuelExpenseCents + otherExpenseCents;
  int get netProfitCents => totalIncomeCents - totalExpensesCents;

  int? get earningsPerHourCents {
    if (totalDurationMinutes == 0) return null;
    return (totalIncomeCents * 60 / totalDurationMinutes).round();
  }
}
