import 'package:driver_finance/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:driver_finance/features/expenses/presentation/providers/expense_provider.dart';
import 'package:driver_finance/features/fuel/presentation/providers/fuel_provider.dart';
import 'package:driver_finance/features/goals/presentation/providers/goal_provider.dart';
import 'package:driver_finance/features/trips/presentation/providers/trip_provider.dart';
import 'package:driver_finance/features/vehicle/presentation/providers/vehicle_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardSummaryProvider =
    Provider.family<DashboardSummary?, (DateTime, DateTime)>((ref, period) {
  final tripsAsync = ref.watch(watchTripsProvider(period));
  final expensesAsync = ref.watch(watchExpensesProvider(period));
  final fuelsAsync = ref.watch(watchFuelRecordsProvider);
  final goalAsync = ref.watch(watchCurrentGoalProvider);
  final vehicleAsync = ref.watch(watchVehicleProvider);

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
  final goal = goalAsync.valueOrNull;
  final vehicle = vehicleAsync.valueOrNull;

  final income = trips.fold<int>(0, (s, t) => s + t.totalIncomeCents);
  final otherExp = expenses.fold<int>(0, (s, e) => s + e.amountCents);
  final fuelExp = fuels.fold<int>(0, (s, f) => s + f.amountCents);
  final goalCents = goal?.monthlyTargetCents;
  final goalProgress = (goalCents != null && goalCents > 0)
      ? income / goalCents
      : null;

  final daysInMonth = DateTime(period.$1.year, period.$1.month + 1, 0).day;
  final periodDays =
      period.$2.difference(period.$1).inDays.clamp(1, daysInMonth);
  final depreciationCents = vehicle != null
      ? (vehicle.monthlyDepreciationCents * periodDays / daysInMonth).round()
      : 0;

  return DashboardSummary(
    totalIncomeCents: income,
    otherExpenseCents: otherExp,
    fuelExpenseCents: fuelExp,
    tripCount: trips.length,
    monthlyGoalCents: goalCents,
    goalProgress: goalProgress,
    depreciationCents: depreciationCents,
  );
});
