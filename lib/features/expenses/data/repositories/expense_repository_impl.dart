import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:driver_finance/core/database/app_database.dart' as $db;
import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/core/network/api_client.dart';
import 'package:driver_finance/core/utils/date_only.dart';
import 'package:driver_finance/features/expenses/domain/entities/expense.dart';
import 'package:driver_finance/features/expenses/domain/repositories/expense_repository.dart';
import 'package:fpdart/fpdart.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  ExpenseRepositoryImpl({
    required $db.AppDatabase database,
    required ApiClient apiClient,
  })  : _db = database,
        _apiClient = apiClient;

  final $db.AppDatabase _db;
  final ApiClient _apiClient;

  @override
  Stream<List<Expense>> watchByPeriod(DateTime start, DateTime end) {
    return (_db.select(_db.expenses)
          ..where(
            (t) =>
                t.deletedAt.isNull() &
                t.category.isNotValue('fuel') &
                t.expenseDate.isBiggerOrEqualValue(start) &
                t.expenseDate.isSmallerOrEqualValue(end),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.expenseDate)]))
        .watch()
        .map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<Either<Failure, Expense>> addExpense(Expense expense) async {
    try {
      final now = DateTime.now();
      await _db.into(_db.expenses).insert(
            $db.ExpensesCompanion(
              id: Value(expense.id),
              userId: Value(expense.userId),
              vehicleId: Value(expense.vehicleId),
              category: Value(expense.category.dbValue),
              amountCents: Value(expense.amountCents),
              description: Value(expense.description),
              expenseDate: Value(expense.expenseDate),
              isRecurring: Value(expense.isRecurring),
              recurrenceType: Value(expense.recurrenceType),
              createdAt: Value(now),
              updatedAt: Value(now),
              syncStatus: const Value('pending'),
            ),
          );
      _syncToBackend(expense.id);
      return right(expense);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteExpense(String expenseId) async {
    try {
      await (_db.update(_db.expenses)..where((t) => t.id.equals(expenseId)))
          .write($db.ExpensesCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ));
      _syncDeleteToBackend(expenseId);
      return right(unit);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  void _syncToBackend(String expenseId) {
    _doSync(expenseId);
  }

  Future<void> _doSync(String expenseId) async {
    try {
      final row = await (_db.select(_db.expenses)
            ..where((t) => t.id.equals(expenseId)))
          .getSingleOrNull();
      if (row == null) return;

      await _apiClient.dio.put<void>('/api/v1/expenses/$expenseId', data: {
        'vehicle_id': row.vehicleId,
        'category': row.category,
        'amount_cents': row.amountCents,
        'description': row.description,
        'expense_date': dateOnly(row.expenseDate),
        'is_recurring': row.isRecurring,
        'recurrence_type': row.recurrenceType,
      });

      await (_db.update(_db.expenses)..where((t) => t.id.equals(expenseId)))
          .write($db.ExpensesCompanion(
        syncStatus: const Value('synced'),
        syncedAt: Value(DateTime.now()),
      ));
    } on DioException catch (e) {
      _apiClient.reportSyncFailure('expenses', expenseId, e);
    } catch (_) {}
  }

  void _syncDeleteToBackend(String expenseId) {
    _doSyncDelete(expenseId);
  }

  Future<void> _doSyncDelete(String expenseId) async {
    try {
      await _apiClient.dio.delete<void>('/api/v1/expenses/$expenseId');
    } on DioException catch (e) {
      _apiClient.reportSyncFailure('expenses', expenseId, e);
    } catch (_) {}
  }

  Expense _toDomain($db.Expense row) => Expense(
        id: row.id,
        userId: row.userId,
        vehicleId: row.vehicleId,
        category: ExpenseCategory.fromDb(row.category),
        amountCents: row.amountCents,
        description: row.description,
        expenseDate: row.expenseDate,
        isRecurring: row.isRecurring,
        recurrenceType: row.recurrenceType,
        createdAt: row.createdAt,
      );
}
