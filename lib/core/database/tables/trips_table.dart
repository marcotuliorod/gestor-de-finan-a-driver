import 'package:drift/drift.dart';
import 'package:driver_finance/core/database/tables/platforms_table.dart';

class Trips extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get platformId => text().references(Platforms, #id)();
  IntColumn get grossAmountCents => integer()();
  IntColumn get bonusAmountCents => integer().withDefault(const Constant(0))();
  IntColumn get tipAmountCents => integer().withDefault(const Constant(0))();
  IntColumn get promotionCents => integer().withDefault(const Constant(0))();
  IntColumn get cancellationCents => integer().withDefault(const Constant(0))();
  IntColumn get durationMinutes => integer().nullable()();
  DateTimeColumn get tripDate => dateTime()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
