import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:driver_finance/core/database/app_database.dart' as $db;
import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/core/network/api_client.dart';
import 'package:driver_finance/core/utils/date_only.dart';
import 'package:driver_finance/core/utils/uuid_generator.dart';
import 'package:driver_finance/features/goals/domain/entities/financial_goal.dart';
import 'package:driver_finance/features/goals/domain/repositories/goal_repository.dart';
import 'package:fpdart/fpdart.dart';

class GoalRepositoryImpl implements GoalRepository {
  GoalRepositoryImpl({
    required $db.AppDatabase database,
    required ApiClient apiClient,
  })  : _db = database,
        _apiClient = apiClient;

  final $db.AppDatabase _db;
  final ApiClient _apiClient;

  @override
  Stream<FinancialGoal?> watchCurrentGoal() {
    final now = DateTime.now();
    return (_db.select(_db.goals)
          ..where((t) =>
              t.periodStart.isSmallerOrEqualValue(now) &
              t.periodEnd.isBiggerOrEqualValue(now))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(1))
        .watchSingleOrNull()
        .map((row) => row != null ? _toDomain(row) : null);
  }

  @override
  Future<Either<Failure, FinancialGoal?>> getCurrentGoal() async {
    try {
      final now = DateTime.now();
      final row = await (_db.select(_db.goals)
            ..where((t) =>
                t.periodStart.isSmallerOrEqualValue(now) &
                t.periodEnd.isBiggerOrEqualValue(now))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(1))
          .getSingleOrNull();
      return right(row != null ? _toDomain(row) : null);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FinancialGoal>> setMonthlyGoal({
    required String userId,
    required int monthlyTargetCents,
    required int workingDaysPerMonth,
  }) async {
    try {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month);
      final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      final id = generateUuid();

      await _db.into(_db.goals).insert(
            $db.GoalsCompanion(
              id: Value(id),
              userId: Value(userId),
              monthlyTargetCents: Value(monthlyTargetCents),
              workingDaysPerMonth: Value(workingDaysPerMonth),
              periodStart: Value(monthStart),
              periodEnd: Value(monthEnd),
              createdAt: Value(now),
              updatedAt: Value(now),
              syncStatus: const Value('pending'),
            ),
          );

      _syncToBackend(id);

      return right(FinancialGoal(
        id: id,
        userId: userId,
        monthlyTargetCents: monthlyTargetCents,
        workingDaysPerMonth: workingDaysPerMonth,
        periodStart: monthStart,
        periodEnd: monthEnd,
      ));
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  void _syncToBackend(String goalId) {
    _doSync(goalId);
  }

  Future<void> _doSync(String goalId) async {
    try {
      final row = await (_db.select(_db.goals)
            ..where((t) => t.id.equals(goalId)))
          .getSingleOrNull();
      if (row == null) return;

      await _apiClient.dio.put<void>('/api/v1/goals/$goalId', data: {
        'monthly_target_cents': row.monthlyTargetCents,
        'working_days_per_month': row.workingDaysPerMonth,
        'period_start': dateOnly(row.periodStart),
        'period_end': dateOnly(row.periodEnd),
      });

      await (_db.update(_db.goals)..where((t) => t.id.equals(goalId))).write(
        $db.GoalsCompanion(
          syncStatus: const Value('synced'),
          syncedAt: Value(DateTime.now()),
        ),
      );
    } on DioException catch (e) {
      _apiClient.reportSyncFailure('goals', goalId, e);
    } catch (_) {
      // Sync failure is silent — will retry via sync queue
    }
  }

  FinancialGoal _toDomain($db.Goal row) => FinancialGoal(
        id: row.id,
        userId: row.userId,
        monthlyTargetCents: row.monthlyTargetCents,
        workingDaysPerMonth: row.workingDaysPerMonth,
        periodStart: row.periodStart,
        periodEnd: row.periodEnd,
      );
}
