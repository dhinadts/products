import 'package:equatable/equatable.dart';

import '../../data/models/app_setting.dart';

enum SettingsStatus { initial, loading, success, error }

class SettingsState extends Equatable {
  const SettingsState({
    this.status = SettingsStatus.initial,
    this.items = const [],
    this.message,
  });

  final SettingsStatus status;
  final List<AppSetting> items;
  final String? message;

  SettingsState copyWith({
    SettingsStatus? status,
    List<AppSetting>? items,
    String? message,
  }) {
    return SettingsState(
      status: status ?? this.status,
      items: items ?? this.items,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, items, message];
}
