import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../models/app_setting.dart';

class SettingsRepository {
  SettingsRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<AppSetting> create(AppSetting item) async {
    final id = await _database
        .into(_database.appSettings)
        .insert(
          AppSettingsCompanion.insert(
            name: item.settingKey,
            title: item.settingKey,
            description: item.settingValue,
            settingKey: item.settingKey,
            settingValue: item.settingValue,
            createdAt: item.createdAt,
            updatedAt: item.updatedAt,
            isSynced: Value(item.isSynced),
          ),
        );
    return item.copyWith(id: id);
  }

  Future<void> update(AppSetting item) async {
    if (item.id == null) return;
    await (_database.update(
      _database.appSettings,
    )..where((table) => table.id.equals(item.id!))).write(
      AppSettingsCompanion(
        name: Value(item.settingKey),
        title: Value(item.settingKey),
        description: Value(item.settingValue),
        settingKey: Value(item.settingKey),
        settingValue: Value(item.settingValue),
        updatedAt: Value(DateTime.now()),
        isSynced: Value(item.isSynced),
      ),
    );
  }

  Future<void> delete(int id) async {
    await (_database.delete(
      _database.appSettings,
    )..where((table) => table.id.equals(id))).go();
  }

  Future<void> upsertValue(String key, String value) async {
    final existing = await getByKey(key);
    final now = DateTime.now();
    if (existing == null) {
      await create(
        AppSetting(
          settingKey: key,
          settingValue: value,
          createdAt: now,
          updatedAt: now,
        ),
      );
      return;
    }
    await update(existing.copyWith(settingValue: value, updatedAt: now));
  }

  Future<List<AppSetting>> getAll() async {
    final rows = await (_database.select(
      _database.appSettings,
    )..orderBy([(table) => OrderingTerm.desc(table.id)])).get();
    return rows.map(_fromRow).toList();
  }

  Future<AppSetting?> getById(int id) async {
    final row = await (_database.select(
      _database.appSettings,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  Future<AppSetting?> getByKey(String key) async {
    final row =
        await (_database.select(_database.appSettings)
              ..where((table) => table.settingKey.equals(key))
              ..orderBy([(table) => OrderingTerm.desc(table.id)])
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  Stream<List<AppSetting>> watchAll() {
    return (_database.select(_database.appSettings)
          ..orderBy([(table) => OrderingTerm.desc(table.id)]))
        .watch()
        .map((rows) => rows.map(_fromRow).toList());
  }

  AppSetting _fromRow(AppSettingRow row) {
    return AppSetting(
      id: row.id,
      settingKey: row.settingKey,
      settingValue: row.settingValue,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isSynced: row.isSynced,
    );
  }
}
