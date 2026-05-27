import 'package:equatable/equatable.dart';

import '../../data/models/record_item.dart';

enum RecordsStatus { initial, loading, success, error }

class RecordsState extends Equatable {
  const RecordsState({
    this.status = RecordsStatus.initial,
    this.items = const [],
    this.message,
  });

  final RecordsStatus status;
  final List<RecordItem> items;
  final String? message;

  RecordsState copyWith({
    RecordsStatus? status,
    List<RecordItem>? items,
    String? message,
  }) {
    return RecordsState(
      status: status ?? this.status,
      items: items ?? this.items,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, items, message];
}
