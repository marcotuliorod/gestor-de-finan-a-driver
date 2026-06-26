import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/features/goals/domain/entities/financial_goal.dart';
import 'package:driver_finance/features/goals/domain/repositories/goal_repository.dart';
import 'package:fpdart/fpdart.dart';

class SetMonthlyGoalUseCase {
  const SetMonthlyGoalUseCase(this._repository);

  final GoalRepository _repository;

  Future<Either<Failure, FinancialGoal>> call({
    required String userId,
    required int monthlyTargetCents,
    required int workingDaysPerMonth,
  }) {
    if (monthlyTargetCents < 0) {
      return Future.value(
          left(const ValidationFailure('Meta deve ser positiva')));
    }
    if (workingDaysPerMonth < 1 || workingDaysPerMonth > 31) {
      return Future.value(
          left(const ValidationFailure('Dias úteis deve estar entre 1 e 31')));
    }
    return _repository.setMonthlyGoal(
      userId: userId,
      monthlyTargetCents: monthlyTargetCents,
      workingDaysPerMonth: workingDaysPerMonth,
    );
  }
}
