import 'package:driver_finance/features/expenses/presentation/providers/expense_provider.dart';
import 'package:driver_finance/features/fuel/presentation/providers/fuel_provider.dart';
import 'package:driver_finance/features/reports/domain/entities/reports_summary.dart';
import 'package:driver_finance/features/trips/presentation/providers/trip_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reportsSummaryProvider =
    Provider.family<ReportsSummary?, (DateTime, DateTime)>((ref, period) {
  final tripsAsync = ref.watch(watchTripsProvider(period));
  final expensesAsync = ref.watch(watchExpensesProvider(period));
  final fuelsAsync = ref.watch(watchFuelRecordsProvider);

  if (tripsAsync.isLoading || expensesAsync.isLoading) return null;

  final trips = tripsAsync.valueOrNull ?? [];
  final expenses = expensesAsync.valueOrNull ?? [];
  final fuels = (fuelsAsync.valueOrNull ?? [])
      .where(
        (f) =>
            !f.recordDate.isBefore(period.$1) &&
            !f.recordDate.isAfter(period.$2),
      )
      .toList();

  final dayMap = <DateTime, int>{};
  for (final trip in trips) {
    final day = DateTime(
      trip.tripDate.year,
      trip.tripDate.month,
      trip.tripDate.day,
    );
    dayMap[day] = (dayMap[day] ?? 0) + trip.totalIncomeCents;
  }
  final dailyIncomes = dayMap.entries
      .map((e) => DailyIncome(date: e.key, amountCents: e.value))
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  return ReportsSummary(
    totalIncomeCents: trips.fold<int>(0, (s, t) => s + t.totalIncomeCents),
    fuelExpenseCents: fuels.fold<int>(0, (s, f) => s + f.amountCents),
    otherExpenseCents: expenses.fold<int>(0, (s, e) => s + e.amountCents),
    tripCount: trips.length,
    dailyIncomes: dailyIncomes,
  );
});
