import 'package:equatable/equatable.dart';

import '../../data/models/report_item.dart';

enum ReportsStatus { initial, loading, success, error }

class ReportsState extends Equatable {
  const ReportsState({
    this.status = ReportsStatus.initial,
    this.items = const [],
    this.message,
  });

  final ReportsStatus status;
  final List<ReportItem> items;
  final String? message;

  ReportsState copyWith({
    ReportsStatus? status,
    List<ReportItem>? items,
    String? message,
  }) {
    return ReportsState(
      status: status ?? this.status,
      items: items ?? this.items,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, items, message];
}
