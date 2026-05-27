import 'package:equatable/equatable.dart';

class HomeItem extends Equatable {
  const HomeItem({
    this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  final int? id;
  final String title;
  final String description;
  final double amount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  factory HomeItem.fromMap(Map<String, Object?> map) {
    return HomeItem(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      amount: (map['amount'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      isSynced: map['is_synced'] == 1 || map['is_synced'] == true,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'amount': amount,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'is_synced': isSynced ? 1 : 0,
  };

  HomeItem copyWith({
    int? id,
    String? title,
    String? description,
    double? amount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return HomeItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    amount,
    createdAt,
    updatedAt,
    isSynced,
  ];
}
