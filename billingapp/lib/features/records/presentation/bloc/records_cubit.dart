import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/record_item.dart';
import '../../data/repositories/records_repository.dart';
import 'records_state.dart';

class RecordsCubit extends Cubit<RecordsState> {
  RecordsCubit(this._repository) : super(const RecordsState());

  final RecordsRepository _repository;

  Future<void> loadRecords() async {
    emit(state.copyWith(status: RecordsStatus.loading));
    try {
      emit(
        state.copyWith(
          status: RecordsStatus.success,
          items: await _repository.getAll(),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(status: RecordsStatus.error, message: error.toString()),
      );
    }
  }

  Future<void> addRecord() async {
    final now = DateTime.now();
    final item = RecordItem(
      customerName: 'Walk-in Customer',
      invoiceNumber: 'INV-${now.millisecondsSinceEpoch}',
      amount: 0,
      status: 'Draft',
      createdAt: now,
      updatedAt: now,
    );
    await _repository.create(item);
    await loadRecords();
  }

  Future<void> deleteRecord(int id) async {
    await _repository.delete(id);
    await loadRecords();
  }
}
