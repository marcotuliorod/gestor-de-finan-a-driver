import 'package:drift/drift.dart';
import 'package:driver_finance/core/database/tables/vehicles_table.dart';

class MaintenanceRecords extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get vehicleId => text().references(Vehicles, #id)();
  TextColumn get type => text()();
  TextColumn get description => text().nullable()();
  IntColumn get costCents => integer()();
  IntColumn get odometer => integer()();
  DateTimeColumn get maintenanceDate => dateTime()();
  IntColumn get nextMaintenanceKm => integer().nullable()();
  DateTimeColumn get nextMaintenanceDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
