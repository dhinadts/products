import 'package:equatable/equatable.dart';

import 'product_model.dart';

class BillItemModel extends Equatable {
  const BillItemModel({
    this.id,
    this.productId,
    required this.itemName,
    this.barcode,
    required this.quantity,
    required this.rate,
    this.discount = 0,
    this.taxPercent = 0,
  });

  factory BillItemModel.fromProduct(ProductModel product) {
    return BillItemModel(
      productId: product.id,
      itemName: product.name,
      barcode: product.barcode,
      quantity: 1,
      rate: product.salePrice,
      taxPercent: product.taxPercent,
    );
  }

  final int? id;
  final int? productId;
  final String itemName;
  final String? barcode;
  final double quantity;
  final double rate;
  final double discount;
  final double taxPercent;

  double get gross => quantity * rate;
  double get taxable => (gross - discount).clamp(0, double.infinity);
  double get taxAmount => taxable * taxPercent / 100;
  double get total => taxable + taxAmount;

  BillItemModel copyWith({
    int? id,
    int? productId,
    String? itemName,
    String? barcode,
    double? quantity,
    double? rate,
    double? discount,
    double? taxPercent,
  }) {
    return BillItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      itemName: itemName ?? this.itemName,
      barcode: barcode ?? this.barcode,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      discount: discount ?? this.discount,
      taxPercent: taxPercent ?? this.taxPercent,
    );
  }

  @override
  List<Object?> get props => [
    id,
    productId,
    itemName,
    barcode,
    quantity,
    rate,
    discount,
    taxPercent,
  ];
}
