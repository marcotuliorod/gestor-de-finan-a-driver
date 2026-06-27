import 'package:drift/drift.dart';
import 'package:driver_finance/core/database/app_database.dart' as $db;
import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/features/expenses/domain/entities/expense.dart';
import 'package:driver_finance/features/expenses/domain/repositories/expense_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  ExpenseRepositoryImpl({
    required $db.AppDatabase database,
    required SupabaseClient supabase,
  })  : _db = database,
        _supabase = supabase;

  final $db.AppDatabase _db;
  final SupabaseClient _supabase;

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
      _syncToSupabase(expense.id);
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
      return right(unit);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  void _syncToSupabase(String expenseId) {
    _doSync(expenseId);
  }

  Future<void> _doSync(String expenseId) async {
    try {
      final row = await (_db.select(_db.expenses)
            ..where((t) => t.id.equals(expenseId)))
          .getSingleOrNull();
      if (row == null) return;

      await _supabase.from('expenses').upsert({
        'id': row.id,
        'user_id': row.userId,
        'vehicle_id': row.vehicleId,
        'category': row.category,
        'amount_cents': row.amountCents,
        'description': row.description,
        'expense_date': row.expenseDate.toIso8601String(),
        'is_recurring': row.isRecurring,
        'recurrence_type': row.recurrenceType,
        'updated_at': row.updatedAt.toIso8601String(),
      });

      await (_db.update(_db.expenses)..where((t) => t.id.equals(expenseId)))
          .write($db.ExpensesCompanion(
        syncStatus: const Value('synced'),
        syncedAt: Value(DateTime.now()),
      ));
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
