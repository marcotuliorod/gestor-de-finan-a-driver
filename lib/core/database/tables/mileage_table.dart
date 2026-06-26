import 'package:drift/drift.dart';
import 'package:driver_finance/core/database/tables/vehicles_table.dart';

class MileageRecords extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get vehicleId => text().references(Vehicles, #id)();
  IntColumn get startOdometer => integer()();
  IntColumn get endOdometer => integer()();
  IntColumn get workKm => integer().withDefault(const Constant(0))();
  IntColumn get personalKm => integer().withDefault(const Constant(0))();
  DateTimeColumn get recordDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
