import 'package:equatable/equatable.dart';

class RecordItem extends Equatable {
  const RecordItem({
    this.id,
    required this.customerName,
    required this.invoiceNumber,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  final int? id;
  final String customerName;
  final String invoiceNumber;
  final double amount;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  factory RecordItem.fromMap(Map<String, Object?> map) {
    return RecordItem(
      id: map['id'] as int?,
      customerName: map['customer_name'] as String,
      invoiceNumber: map['invoice_number'] as String,
      amount: (map['amount'] as num).toDouble(),
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      isSynced: map['is_synced'] == 1 || map['is_synced'] == true,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'customer_name': customerName,
    'invoice_number': invoiceNumber,
    'amount': amount,
    'status': status,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'is_synced': isSynced ? 1 : 0,
  };

  RecordItem copyWith({
    int? id,
    String? customerName,
    String? invoiceNumber,
    double? amount,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return RecordItem(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  List<Object?> get props => [
    id,
    customerName,
    invoiceNumber,
    amount,
    status,
    createdAt,
    updatedAt,
    isSynced,
  ];
}
