import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  const ProductModel({
    this.id,
    required this.name,
    this.barcode,
    this.hsnCode,
    required this.salePrice,
    this.taxPercent = 0,
    this.stockQty = 0,
  });

  final int? id;
  final String name;
  final String? barcode;
  final String? hsnCode;
  final double salePrice;
  final double taxPercent;
  final double stockQty;

  @override
  List<Object?> get props => [
    id,
    name,
    barcode,
    hsnCode,
    salePrice,
    taxPercent,
    stockQty,
  ];
}
