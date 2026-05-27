import 'package:equatable/equatable.dart';

class ReportItem extends Equatable {
  const ReportItem({
    this.id,
    required this.title,
    required this.period,
    required this.total,
    required this.generatedAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  final int? id;
  final String title;
  final String period;
  final double total;
  final DateTime generatedAt;
  final DateTime updatedAt;
  final bool isSynced;

  factory ReportItem.fromMap(Map<String, Object?> map) {
    return ReportItem(
      id: map['id'] as int?,
      title: map['title'] as String,
      period: map['period'] as String,
      total: (map['total'] as num).toDouble(),
      generatedAt: DateTime.parse(map['generated_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      isSynced: map['is_synced'] == 1 || map['is_synced'] == true,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'period': period,
    'total': total,
    'generated_at': generatedAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'is_synced': isSynced ? 1 : 0,
  };

  ReportItem copyWith({
    int? id,
    String? title,
    String? period,
    double? total,
    DateTime? generatedAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return ReportItem(
      id: id ?? this.id,
      title: title ?? this.title,
      period: period ?? this.period,
      total: total ?? this.total,
      generatedAt: generatedAt ?? this.generatedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    period,
    total,
    generatedAt,
    updatedAt,
    isSynced,
  ];
}
