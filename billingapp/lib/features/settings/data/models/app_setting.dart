import 'package:equatable/equatable.dart';

class AppSetting extends Equatable {
  const AppSetting({
    this.id,
    required this.settingKey,
    required this.settingValue,
    required this.updatedAt,
    required this.createdAt,
    this.isSynced = false,
  });

  final int? id;
  final String settingKey;
  final String settingValue;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  factory AppSetting.fromMap(Map<String, Object?> map) {
    return AppSetting(
      id: map['id'] as int?,
      settingKey: map['setting_key'] as String,
      settingValue: map['setting_value'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      isSynced: map['is_synced'] == 1 || map['is_synced'] == true,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'setting_key': settingKey,
    'setting_value': settingValue,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'is_synced': isSynced ? 1 : 0,
  };

  AppSetting copyWith({
    int? id,
    String? settingKey,
    String? settingValue,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return AppSetting(
      id: id ?? this.id,
      settingKey: settingKey ?? this.settingKey,
      settingValue: settingValue ?? this.settingValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  List<Object?> get props => [
    id,
    settingKey,
    settingValue,
    createdAt,
    updatedAt,
    isSynced,
  ];
}
