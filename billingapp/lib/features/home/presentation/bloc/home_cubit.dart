import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/home_item.dart';
import '../../data/repositories/home_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository) : super(const HomeState());

  final HomeRepository _repository;

  Future<void> loadItems() async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      emit(
        state.copyWith(
          status: HomeStatus.success,
          items: await _repository.getAll(),
        ),
      );
    } catch (error) {
      emit(state.copyWith(status: HomeStatus.error, message: error.toString()));
    }
  }

  Future<void> addQuickItem() async {
    final now = DateTime.now();
    final item = HomeItem(
      title: 'New billing item',
      description: 'Added from Home quick action',
      amount: 0,
      createdAt: now,
      updatedAt: now,
    );
    await _repository.create(item);
    await loadItems();
  }

  Future<void> deleteItem(int id) async {
    await _repository.delete(id);
    await loadItems();
  }
}
