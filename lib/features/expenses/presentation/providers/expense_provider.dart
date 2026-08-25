import 'package:driver_finance/core/database/app_database.dart' as $db;
import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/core/network/api_client.dart';
import 'package:driver_finance/core/utils/uuid_generator.dart';
import 'package:driver_finance/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:driver_finance/features/expenses/domain/entities/expense.dart';
import 'package:driver_finance/features/expenses/domain/repositories/expense_repository.dart';
import 'package:driver_finance/features/expenses/domain/usecases/add_expense.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepositoryImpl(
    database: ref.watch($db.appDatabaseProvider),
    apiClient: ref.watch(apiClientProvider),
  );
});

final watchExpensesProvider =
    StreamProvider.family<List<Expense>, (DateTime, DateTime)>(
  (ref, period) {
    final repo = ref.watch(expenseRepositoryProvider);
    return repo.watchByPeriod(period.$1, period.$2);
  },
);

class ExpenseFormNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Either<Failure, Expense>> save({
    required String userId,
    String? vehicleId,
    required ExpenseCategory category,
    required int amountCents,
    String? description,
    required DateTime expenseDate,
    bool isRecurring = false,
    String? recurrenceType,
  }) async {
    state = const AsyncLoading();
    final expense = Expense(
      id: generateUuid(),
      userId: userId,
      vehicleId: vehicleId,
      category: category,
      amountCents: amountCents,
      description: description?.isEmpty == true ? null : description,
      expenseDate: expenseDate,
      isRecurring: isRecurring,
      recurrenceType: recurrenceType,
      createdAt: DateTime.now(),
    );
    final result = await AddExpenseUseCase(
      ref.read(expenseRepositoryProvider),
    )(expense);
    state = const AsyncData(null);
    return result;
  }
}

final expenseFormNotifierProvider =
    AsyncNotifierProvider<ExpenseFormNotifier, void>(
  ExpenseFormNotifier.new,
);
