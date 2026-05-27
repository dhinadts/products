import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../models/home_item.dart';

class HomeRepository {
  HomeRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<HomeItem> create(HomeItem item) async {
    final now = DateTime.now();
    final id = await _database
        .into(_database.homeItems)
        .insert(
          HomeItemsCompanion.insert(
            title: item.title,
            description: item.description,
            amount: Value(item.amount),
            createdAt: item.createdAt,
            updatedAt: item.updatedAt,
            isSynced: Value(item.isSynced),
          ),
        );
    return item.copyWith(id: id, updatedAt: now);
  }

  Future<void> update(HomeItem item) async {
    if (item.id == null) return;
    await (_database.update(
      _database.homeItems,
    )..where((table) => table.id.equals(item.id!))).write(
      HomeItemsCompanion(
        title: Value(item.title),
        description: Value(item.description),
        amount: Value(item.amount),
        updatedAt: Value(DateTime.now()),
        isSynced: Value(item.isSynced),
      ),
    );
  }

  Future<void> delete(int id) async {
    await (_database.delete(
      _database.homeItems,
    )..where((table) => table.id.equals(id))).go();
  }

  Future<List<HomeItem>> getAll() async {
    final rows = await (_database.select(
      _database.homeItems,
    )..orderBy([(table) => OrderingTerm.desc(table.id)])).get();
    return rows.map(_fromRow).toList();
  }

  Future<HomeItem?> getById(int id) async {
    final row = await (_database.select(
      _database.homeItems,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  Stream<List<HomeItem>> watchAll() {
    return (_database.select(_database.homeItems)
          ..orderBy([(table) => OrderingTerm.desc(table.id)]))
        .watch()
        .map((rows) => rows.map(_fromRow).toList());
  }

  HomeItem _fromRow(HomeItemRow row) {
    return HomeItem(
      id: row.id,
      title: row.title,
      description: row.description,
      amount: row.amount,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isSynced: row.isSynced,
    );
  }
}
