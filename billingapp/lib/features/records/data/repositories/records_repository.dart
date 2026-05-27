import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../models/record_item.dart';

class RecordsRepository {
  RecordsRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<RecordItem> create(RecordItem item) async {
    final id = await _database
        .into(_database.records)
        .insert(
          RecordsCompanion.insert(
            name: item.customerName,
            title: item.invoiceNumber,
            description: item.status,
            amount: Value(item.amount),
            status: Value(item.status),
            createdAt: item.createdAt,
            updatedAt: item.updatedAt,
            isSynced: Value(item.isSynced),
          ),
        );
    return item.copyWith(id: id);
  }

  Future<void> update(RecordItem item) async {
    if (item.id == null) return;
    await (_database.update(
      _database.records,
    )..where((table) => table.id.equals(item.id!))).write(
      RecordsCompanion(
        name: Value(item.customerName),
        title: Value(item.invoiceNumber),
        description: Value(item.status),
        amount: Value(item.amount),
        status: Value(item.status),
        updatedAt: Value(DateTime.now()),
        isSynced: Value(item.isSynced),
      ),
    );
  }

  Future<void> delete(int id) async {
    await (_database.delete(
      _database.records,
    )..where((table) => table.id.equals(id))).go();
  }

  Future<List<RecordItem>> getAll() async {
    final rows = await (_database.select(
      _database.records,
    )..orderBy([(table) => OrderingTerm.desc(table.id)])).get();
    return rows.map(_fromRow).toList();
  }

  Future<RecordItem?> getById(int id) async {
    final row = await (_database.select(
      _database.records,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  Stream<List<RecordItem>> watchAll() {
    return (_database.select(_database.records)
          ..orderBy([(table) => OrderingTerm.desc(table.id)]))
        .watch()
        .map((rows) => rows.map(_fromRow).toList());
  }

  RecordItem _fromRow(RecordRow row) {
    return RecordItem(
      id: row.id,
      customerName: row.name,
      invoiceNumber: row.title,
      amount: row.amount,
      status: row.status,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isSynced: row.isSynced,
    );
  }
}
