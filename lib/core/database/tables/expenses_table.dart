import 'package:drift/drift.dart';
import 'package:driver_finance/core/database/tables/vehicles_table.dart';

class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get vehicleId => text().references(Vehicles, #id).nullable()();
  TextColumn get category => text()();
  IntColumn get amountCents => integer()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get expenseDate => dateTime()();
  BoolColumn get isRecurring =>
      boolean().withDefault(const Constant(false))();
  TextColumn get recurrenceType => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
