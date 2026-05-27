import 'package:equatable/equatable.dart';

import 'bill_item_model.dart';

enum PaymentMode { cash, upi, card }

extension PaymentModeLabel on PaymentMode {
  String get label => switch (this) {
    PaymentMode.cash => 'Cash',
    PaymentMode.upi => 'UPI',
    PaymentMode.card => 'Card',
  };
}

class BillModel extends Equatable {
  const BillModel({
    this.id,
    required this.billNumber,
    required this.billDate,
    required this.cashierName,
    this.customerName,
    this.customerPhone,
    required this.items,
    this.discount = 0,
    this.paymentMode = PaymentMode.cash,
    this.upiQrData,
  });

  final int? id;
  final String billNumber;
  final DateTime billDate;
  final String cashierName;
  final String? customerName;
  final String? customerPhone;
  final List<BillItemModel> items;
  final double discount;
  final PaymentMode paymentMode;
  final String? upiQrData;

  double get subtotal => items.fold(0, (sum, item) => sum + item.gross);
  double get itemDiscount => items.fold(0, (sum, item) => sum + item.discount);
  double get totalDiscount => discount + itemDiscount;
  double get taxAmount => items.fold(0, (sum, item) => sum + item.taxAmount);
  double get grandTotal =>
      (subtotal - totalDiscount + taxAmount).clamp(0, double.infinity);

  BillModel copyWith({
    int? id,
    String? billNumber,
    DateTime? billDate,
    String? cashierName,
    String? customerName,
    String? customerPhone,
    List<BillItemModel>? items,
    double? discount,
    PaymentMode? paymentMode,
    String? upiQrData,
  }) {
    return BillModel(
      id: id ?? this.id,
      billNumber: billNumber ?? this.billNumber,
      billDate: billDate ?? this.billDate,
      cashierName: cashierName ?? this.cashierName,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      discount: discount ?? this.discount,
      paymentMode: paymentMode ?? this.paymentMode,
      upiQrData: upiQrData ?? this.upiQrData,
    );
  }

  @override
  List<Object?> get props => [
    id,
    billNumber,
    billDate,
    cashierName,
    customerName,
    customerPhone,
    items,
    discount,
    paymentMode,
    upiQrData,
  ];
}
