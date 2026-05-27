import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/app_setting.dart';
import '../../data/repositories/settings_repository.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository) : super(const SettingsState());

  final SettingsRepository _repository;

  Future<void> loadSettings() async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      emit(
        state.copyWith(
          status: SettingsStatus.success,
          items: await _repository.getAll(),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(status: SettingsStatus.error, message: error.toString()),
      );
    }
  }

  Future<void> editSettings() async {
    final item = AppSetting(
      settingKey: 'last_edited',
      settingValue: DateTime.now().toLocal().toString(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _repository.create(item);
    await loadSettings();
  }

  Future<void> deleteSetting(int id) async {
    await _repository.delete(id);
    await loadSettings();
  }
}
