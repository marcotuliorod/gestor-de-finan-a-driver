import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:driver_finance/core/database/tables/ai_tables.dart';
import 'package:driver_finance/core/database/tables/expenses_table.dart';
import 'package:driver_finance/core/database/tables/fuel_records_table.dart';
import 'package:driver_finance/core/database/tables/goals_table.dart';
import 'package:driver_finance/core/database/tables/maintenance_table.dart';
import 'package:driver_finance/core/database/tables/mileage_table.dart';
import 'package:driver_finance/core/database/tables/platforms_table.dart';
import 'package:driver_finance/core/database/tables/sync_queue_table.dart';
import 'package:driver_finance/core/database/tables/trips_table.dart';
import 'package:driver_finance/core/database/tables/vehicles_table.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Vehicles,
    Platforms,
    Trips,
    Expenses,
    FuelRecords,
    MileageRecords,
    MaintenanceRecords,
    Goals,
    AiConversations,
    AiMessages,
    SyncQueue,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'driver_finance.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
