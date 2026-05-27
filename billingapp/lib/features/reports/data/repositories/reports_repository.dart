import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../models/report_item.dart';

class ReportsRepository {
  ReportsRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<ReportItem> create(ReportItem item) async {
    final id = await _database
        .into(_database.reports)
        .insert(
          ReportsCompanion.insert(
            title: item.title,
            description: 'Generated report for ${item.period}',
            period: item.period,
            total: Value(item.total),
            createdAt: item.generatedAt,
            updatedAt: item.updatedAt,
            isSynced: Value(item.isSynced),
          ),
        );
    return item.copyWith(id: id);
  }

  Future<void> update(ReportItem item) async {
    if (item.id == null) return;
    await (_database.update(
      _database.reports,
    )..where((table) => table.id.equals(item.id!))).write(
      ReportsCompanion(
        title: Value(item.title),
        description: Value('Generated report for ${item.period}'),
        period: Value(item.period),
        total: Value(item.total),
        updatedAt: Value(DateTime.now()),
        isSynced: Value(item.isSynced),
      ),
    );
  }

  Future<void> delete(int id) async {
    await (_database.delete(
      _database.reports,
    )..where((table) => table.id.equals(id))).go();
  }

  Future<List<ReportItem>> getAll() async {
    final rows = await (_database.select(
      _database.reports,
    )..orderBy([(table) => OrderingTerm.desc(table.id)])).get();
    return rows.map(_fromRow).toList();
  }

  Future<ReportItem?> getById(int id) async {
    final row = await (_database.select(
      _database.reports,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  Stream<List<ReportItem>> watchAll() {
    return (_database.select(_database.reports)
          ..orderBy([(table) => OrderingTerm.desc(table.id)]))
        .watch()
        .map((rows) => rows.map(_fromRow).toList());
  }

  ReportItem _fromRow(ReportRow row) {
    return ReportItem(
      id: row.id,
      title: row.title,
      period: row.period,
      total: row.total,
      generatedAt: row.createdAt,
      updatedAt: row.updatedAt,
      isSynced: row.isSynced,
    );
  }
}
