import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/features/expenses/domain/entities/expense.dart';
import 'package:driver_finance/features/expenses/domain/repositories/expense_repository.dart';
import 'package:fpdart/fpdart.dart';

class AddExpenseUseCase {
  const AddExpenseUseCase(this._repository);

  final ExpenseRepository _repository;

  Future<Either<Failure, Expense>> call(Expense expense) {
    if (expense.amountCents <= 0) {
      return Future.value(
        left(const ValidationFailure('Valor deve ser maior que zero')),
      );
    }
    return _repository.addExpense(expense);
  }
}
