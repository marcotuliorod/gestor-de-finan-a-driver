import 'package:drift/drift.dart';

class Vehicles extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get make => text()();
  TextColumn get model => text()();
  IntColumn get year => integer()();
  TextColumn get licensePlate => text()();
  TextColumn get fuelType => text()();
  RealColumn get tankCapacityL => real()();
  IntColumn get purchasePriceCents => integer()();
  IntColumn get usefulLifeMonths => integer().withDefault(const Constant(60))();
  RealColumn get residualValuePct => real().withDefault(const Constant(0.20))();
  IntColumn get currentOdometer => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
