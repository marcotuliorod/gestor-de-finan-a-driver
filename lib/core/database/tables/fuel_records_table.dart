import 'package:drift/drift.dart';
import 'package:driver_finance/core/database/tables/expenses_table.dart';
import 'package:driver_finance/core/database/tables/vehicles_table.dart';

class FuelRecords extends Table {
  TextColumn get id => text()();
  TextColumn get expenseId => text().references(Expenses, #id)();
  TextColumn get userId => text()();
  TextColumn get vehicleId => text().references(Vehicles, #id)();
  RealColumn get liters => real()();
  IntColumn get odometer => integer()();
  TextColumn get fuelType => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
