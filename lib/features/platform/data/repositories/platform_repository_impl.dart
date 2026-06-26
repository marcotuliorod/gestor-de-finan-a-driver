import 'package:drift/drift.dart';
import 'package:driver_finance/core/database/app_database.dart' as $db;
import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/core/utils/uuid_generator.dart';
import 'package:driver_finance/features/platform/domain/entities/app_platform.dart';
import 'package:driver_finance/features/platform/domain/repositories/platform_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlatformRepositoryImpl implements PlatformRepository {
  PlatformRepositoryImpl({
    required $db.AppDatabase database,
    required SupabaseClient supabase,
  })  : _db = database,
        _supabase = supabase;

  final $db.AppDatabase _db;
  final SupabaseClient _supabase;

  @override
  Stream<List<AppPlatform>> watchPlatforms() {
    return (_db.select(_db.platforms)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<Either<Failure, List<AppPlatform>>> getPlatforms() async {
    try {
      final rows = await (_db.select(_db.platforms)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();
      return right(rows.map(_toDomain).toList());
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> seedDefaultPlatforms(String userId) async {
    try {
      final existing = await (_db.select(_db.platforms)
            ..where((t) => t.deletedAt.isNull()))
          .get();
      if (existing.isNotEmpty) return right(unit);

      final now = DateTime.now();
      for (final type in AppPlatform.defaultTypes) {
        await _db.into(_db.platforms).insert(
              $db.PlatformsCompanion(
                id: Value(generateUuid()),
                userId: Value(userId),
                type: Value(type),
                isActive: const Value(true),
                createdAt: Value(now),
                updatedAt: Value(now),
                syncStatus: const Value('pending'),
              ),
            );
      }
      _syncAllToSupabase(userId);
      return right(unit);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> togglePlatform(
    String id, {
    required bool isActive,
  }) async {
    try {
      await (_db.update(_db.platforms)..where((t) => t.id.equals(id))).write(
        $db.PlatformsCompanion(
          isActive: Value(isActive),
          updatedAt: Value(DateTime.now()),
          syncStatus: const Value('pending'),
        ),
      );
      return right(unit);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  void _syncAllToSupabase(String userId) {
    _doSyncAll(userId);
  }

  Future<void> _doSyncAll(String userId) async {
    try {
      final rows = await (_db.select(_db.platforms)
            ..where((t) => t.deletedAt.isNull()))
          .get();

      for (final row in rows) {
        await _supabase.from('platforms').upsert({
          'id': row.id,
          'user_id': row.userId,
          'type': row.type,
          'custom_name': row.customName,
          'is_active': row.isActive,
          'updated_at': row.updatedAt.toIso8601String(),
        });

        await (_db.update(_db.platforms)..where((t) => t.id.equals(row.id)))
            .write($db.PlatformsCompanion(
          syncStatus: const Value('synced'),
          syncedAt: Value(DateTime.now()),
        ));
      }
    } catch (_) {
      // Sync failure is silent — will retry via sync queue
    }
  }

  AppPlatform _toDomain($db.Platform row) => AppPlatform(
        id: row.id,
        userId: row.userId,
        type: row.type,
        customName: row.customName,
        isActive: row.isActive,
      );
}
