import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/features/expenses/domain/entities/expense.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class ExpenseRepository {
  Stream<List<Expense>> watchByPeriod(DateTime start, DateTime end);
  Future<Either<Failure, Expense>> addExpense(Expense expense);
  Future<Either<Failure, Unit>> deleteExpense(String expenseId);
}
