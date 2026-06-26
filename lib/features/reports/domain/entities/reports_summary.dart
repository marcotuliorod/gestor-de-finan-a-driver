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
  });

  final int totalIncomeCents;
  final int fuelExpenseCents;
  final int otherExpenseCents;
  final int tripCount;
  final List<DailyIncome> dailyIncomes;

  int get totalExpensesCents => fuelExpenseCents + otherExpenseCents;
  int get netProfitCents => totalIncomeCents - totalExpensesCents;
}
