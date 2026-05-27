import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../data/models/report_item.dart';
import '../../data/repositories/reports_repository.dart';
import 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit(this._repository) : super(const ReportsState());

  final ReportsRepository _repository;

  Future<void> loadReports() async {
    emit(state.copyWith(status: ReportsStatus.loading));
    try {
      emit(
        state.copyWith(
          status: ReportsStatus.success,
          items: await _repository.getAll(),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(status: ReportsStatus.error, message: error.toString()),
      );
    }
  }

  Future<void> exportReport() async {
    final now = DateTime.now();
    final item = ReportItem(
      title: 'Billing Summary',
      period: DateFormat('MMM yyyy').format(now),
      total: 0,
      generatedAt: now,
      updatedAt: now,
    );
    await _repository.create(item);
    await loadReports();
  }

  Future<void> deleteReport(int id) async {
    await _repository.delete(id);
    await loadReports();
  }
}
