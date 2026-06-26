import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/features/goals/domain/entities/financial_goal.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class GoalRepository {
  Stream<FinancialGoal?> watchCurrentGoal();
  Future<Either<Failure, FinancialGoal?>> getCurrentGoal();
  Future<Either<Failure, FinancialGoal>> setMonthlyGoal({
    required String userId,
    required int monthlyTargetCents,
    required int workingDaysPerMonth,
  });
}
