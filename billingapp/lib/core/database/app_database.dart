import 'package:drift/drift.dart';

import 'database_connection.dart';

part 'app_database.g.dart';

@DataClassName('HomeItemRow')
class HomeItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  RealColumn get amount => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

@DataClassName('RecordRow')
class Records extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  RealColumn get amount => real().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('Draft'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

@DataClassName('ReportRow')
class Reports extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get period => text()();
  RealColumn get total => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

@DataClassName('AppSettingRow')
class AppSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get settingKey => text()();
  TextColumn get settingValue => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

@DataClassName('ProductRow')
class GroceryProducts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get barcode => text().nullable()();
  TextColumn get hsnCode => text().nullable()();
  RealColumn get salePrice => real()();
  RealColumn get taxPercent => real().withDefault(const Constant(0))();
  RealColumn get stockQty => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

@DataClassName('BillRow')
class GroceryBills extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get billNumber => text().unique()();
  TextColumn get cashierName => text()();
  TextColumn get customerName => text().nullable()();
  TextColumn get customerPhone => text().nullable()();
  TextColumn get paymentMode => text()();
  RealColumn get subtotal => real()();
  RealColumn get discount => real().withDefault(const Constant(0))();
  RealColumn get taxAmount => real().withDefault(const Constant(0))();
  RealColumn get grandTotal => real()();
  DateTimeColumn get billDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

@DataClassName('BillItemRow')
class GroceryBillItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get billId => integer().references(GroceryBills, #id)();
  IntColumn get productId =>
      integer().nullable().references(GroceryProducts, #id)();
  TextColumn get itemName => text()();
  TextColumn get barcode => text().nullable()();
  RealColumn get quantity => real()();
  RealColumn get rate => real()();
  RealColumn get discount => real().withDefault(const Constant(0))();
  RealColumn get taxPercent => real().withDefault(const Constant(0))();
  RealColumn get taxAmount => real().withDefault(const Constant(0))();
  RealColumn get total => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

@DataClassName('PrinterSettingRow')
class PrinterSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get printerType => text()();
  TextColumn get printerName => text().nullable()();
  TextColumn get printerAddress => text().nullable()();
  TextColumn get ipAddress => text().nullable()();
  IntColumn get port => integer().withDefault(const Constant(9100))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(
  tables: [
    HomeItems,
    Records,
    Reports,
    AppSettings,
    GroceryProducts,
    GroceryBills,
    GroceryBillItems,
    PrinterSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? createDatabaseConnection());

  static final AppDatabase instance = AppDatabase();

  @override
  int get schemaVersion => 2;
}
