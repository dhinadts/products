import 'package:equatable/equatable.dart';

import '../../data/models/bill_item_model.dart';
import '../../data/models/bill_model.dart';
import '../../data/models/product_model.dart';

enum BillingStatus { initial, loading, ready, saving, printing, success, error }

class BillingState extends Equatable {
  const BillingState({
    this.status = BillingStatus.initial,
    this.products = const [],
    this.items = const [],
    this.savedBills = const [],
    required this.billNumber,
    this.discount = 0,
    this.paymentMode = PaymentMode.cash,
    this.paymentReference,
    this.paymentCompleted = false,
    this.message,
  });

  final BillingStatus status;
  final List<ProductModel> products;
  final List<BillItemModel> items;
  final List<BillModel> savedBills;
  final String billNumber;
  final double discount;
  final PaymentMode paymentMode;
  final String? paymentReference;
  final bool paymentCompleted;
  final String? message;

  double get subtotal => items.fold(0, (sum, item) => sum + item.gross);
  double get itemDiscount => items.fold(0, (sum, item) => sum + item.discount);
  double get totalDiscount => discount + itemDiscount;
  double get taxAmount => items.fold(0, (sum, item) => sum + item.taxAmount);
  double get grandTotal =>
      (subtotal - totalDiscount + taxAmount).clamp(0, double.infinity);

  BillModel get bill => BillModel(
    billNumber: billNumber,
    billDate: DateTime.now(),
    cashierName: 'Admin',
    items: items,
    discount: discount,
    paymentMode: paymentMode,
    upiQrData: paymentMode == PaymentMode.upi
        ? 'upi://pay?pa=store@upi&pn=DHINADTS&am=${grandTotal.toStringAsFixed(2)}'
        : null,
  );

  BillingState copyWith({
    BillingStatus? status,
    List<ProductModel>? products,
    List<BillItemModel>? items,
    List<BillModel>? savedBills,
    String? billNumber,
    double? discount,
    PaymentMode? paymentMode,
    String? paymentReference,
    bool? paymentCompleted,
    String? message,
  }) {
    return BillingState(
      status: status ?? this.status,
      products: products ?? this.products,
      items: items ?? this.items,
      savedBills: savedBills ?? this.savedBills,
      billNumber: billNumber ?? this.billNumber,
      discount: discount ?? this.discount,
      paymentMode: paymentMode ?? this.paymentMode,
      paymentReference: paymentReference ?? this.paymentReference,
      paymentCompleted: paymentCompleted ?? this.paymentCompleted,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    products,
    items,
    savedBills,
    billNumber,
    discount,
    paymentMode,
    paymentReference,
    paymentCompleted,
    message,
  ];
}
