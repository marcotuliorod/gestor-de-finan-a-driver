import 'package:driver_finance/core/database/app_database.dart';
import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/features/goals/data/repositories/goal_repository_impl.dart';
import 'package:driver_finance/features/goals/domain/entities/financial_goal.dart';
import 'package:driver_finance/features/goals/domain/repositories/goal_repository.dart';
import 'package:driver_finance/features/goals/domain/usecases/set_monthly_goal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return GoalRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    supabase: Supabase.instance.client,
  );
});

final watchCurrentGoalProvider = StreamProvider<FinancialGoal?>((ref) {
  return ref.watch(goalRepositoryProvider).watchCurrentGoal();
});

class GoalNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Either<Failure, FinancialGoal>> setGoal({
    required String userId,
    required int monthlyTargetCents,
    int workingDaysPerMonth = 26,
  }) async {
    state = const AsyncLoading();
    final result = await SetMonthlyGoalUseCase(ref.read(goalRepositoryProvider))(
      userId: userId,
      monthlyTargetCents: monthlyTargetCents,
      workingDaysPerMonth: workingDaysPerMonth,
    );
    state = const AsyncData(null);
    return result;
  }
}

final goalNotifierProvider =
    AsyncNotifierProvider<GoalNotifier, void>(GoalNotifier.new);
