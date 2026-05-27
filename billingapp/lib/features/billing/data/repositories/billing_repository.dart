import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../models/bill_item_model.dart';
import '../models/bill_model.dart';
import '../models/product_model.dart';

class BillingRepository {
  BillingRepository({AppDatabase? database})
    : _db = database ?? AppDatabase.instance;

  final AppDatabase _db;

  Future<List<ProductModel>> getProducts() async {
    await _seedProductsIfNeeded();
    final rows = await (_db.select(
      _db.groceryProducts,
    )..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
    return rows.map(_productFromRow).toList();
  }

  Future<ProductModel?> findProduct(String query) async {
    await _seedProductsIfNeeded();
    final clean = query.trim();
    if (clean.isEmpty) return null;
    final row =
        await (_db.select(_db.groceryProducts)
              ..where((t) => t.barcode.equals(clean) | t.name.like('%$clean%'))
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : _productFromRow(row);
  }

  Future<BillModel> saveBill(BillModel bill) async {
    _validateBill(bill);
    return _db.transaction(() async {
      final now = DateTime.now();
      final billId = await _db
          .into(_db.groceryBills)
          .insert(
            GroceryBillsCompanion.insert(
              billNumber: bill.billNumber,
              cashierName: bill.cashierName,
              customerName: Value(bill.customerName),
              customerPhone: Value(bill.customerPhone),
              paymentMode: bill.paymentMode.label,
              subtotal: bill.subtotal,
              discount: Value(bill.totalDiscount),
              taxAmount: Value(bill.taxAmount),
              grandTotal: bill.grandTotal,
              billDate: bill.billDate,
              createdAt: now,
              updatedAt: now,
            ),
          );
      for (final item in bill.items) {
        await _db
            .into(_db.groceryBillItems)
            .insert(
              GroceryBillItemsCompanion.insert(
                billId: billId,
                productId: Value(item.productId),
                itemName: item.itemName,
                barcode: Value(item.barcode),
                quantity: item.quantity,
                rate: item.rate,
                discount: Value(item.discount),
                taxPercent: Value(item.taxPercent),
                taxAmount: Value(item.taxAmount),
                total: item.total,
                createdAt: now,
                updatedAt: now,
              ),
            );
      }
      return bill.copyWith(id: billId);
    });
  }

  Future<List<BillModel>> getSavedBills() async {
    final bills = await (_db.select(
      _db.groceryBills,
    )..orderBy([(t) => OrderingTerm.desc(t.id)])).get();
    final result = <BillModel>[];
    for (final bill in bills) {
      result.add(await _billFromRow(bill));
    }
    return result;
  }

  Future<BillModel?> getBillById(int id) async {
    final row = await (_db.select(
      _db.groceryBills,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _billFromRow(row);
  }

  Stream<List<BillModel>> watchSavedBills() {
    return (_db.select(_db.groceryBills)
          ..orderBy([(t) => OrderingTerm.desc(t.id)]))
        .watch()
        .asyncMap((rows) async {
          final result = <BillModel>[];
          for (final row in rows) {
            result.add(await _billFromRow(row));
          }
          return result;
        });
  }

  String nextBillNumber() => 'GST-${DateTime.now().millisecondsSinceEpoch}';

  void _validateBill(BillModel bill) {
    if (bill.billNumber.trim().isEmpty) {
      throw ArgumentError('Bill number is required.');
    }
    if (bill.items.isEmpty) throw ArgumentError('Add at least one item.');
    for (final item in bill.items) {
      if (item.quantity <= 0) {
        throw ArgumentError('Quantity must be greater than zero.');
      }
      if (item.rate < 0) throw ArgumentError('Price cannot be negative.');
      if (item.discount < 0) {
        throw ArgumentError('Discount cannot be negative.');
      }
    }
    if (bill.grandTotal < 0) {
      throw ArgumentError('Grand total cannot be negative.');
    }
  }

  Future<BillModel> _billFromRow(BillRow row) async {
    final itemRows = await (_db.select(
      _db.groceryBillItems,
    )..where((t) => t.billId.equals(row.id))).get();
    return BillModel(
      id: row.id,
      billNumber: row.billNumber,
      billDate: row.billDate,
      cashierName: row.cashierName,
      customerName: row.customerName,
      customerPhone: row.customerPhone,
      items: itemRows
          .map(
            (item) => BillItemModel(
              id: item.id,
              productId: item.productId,
              itemName: item.itemName,
              barcode: item.barcode,
              quantity: item.quantity,
              rate: item.rate,
              discount: item.discount,
              taxPercent: item.taxPercent,
            ),
          )
          .toList(),
      discount: row.discount,
      paymentMode: PaymentMode.values.firstWhere(
        (mode) => mode.label == row.paymentMode,
        orElse: () => PaymentMode.cash,
      ),
    );
  }

  ProductModel _productFromRow(ProductRow row) {
    return ProductModel(
      id: row.id,
      name: row.name,
      barcode: row.barcode,
      hsnCode: row.hsnCode,
      salePrice: row.salePrice,
      taxPercent: row.taxPercent,
      stockQty: row.stockQty,
    );
  }

  Future<void> _seedProductsIfNeeded() async {
    final count = _db.selectOnly(_db.groceryProducts)
      ..addColumns([_db.groceryProducts.id.count()]);
    final existing = await count
        .map((row) => row.read(_db.groceryProducts.id.count()) ?? 0)
        .getSingle();
    if (existing > 0) return;
    final now = DateTime.now();
    final products = [
      ('Rice 5kg Bag', '890100000001', '1006', 360.0, 5.0, 60.0),
      ('Sunflower Oil 1L', '890100000002', '1512', 145.0, 5.0, 40.0),
      ('Sugar 1kg', '890100000003', '1701', 48.0, 0.0, 80.0),
      ('Wheat Flour 10kg', '890100000004', '1101', 520.0, 5.0, 25.0),
      ('Tea Powder 500g', '890100000005', '0902', 210.0, 5.0, 30.0),
      ('Soap Pack', '890100000006', '3401', 75.0, 18.0, 100.0),
      ('Premium Soap Pack', '890100000007', '3401', 95.0, 18.0, 75.0),
      ('Masala Mix 100g', '890100000008', '0910', 38.0, 5.0, 120.0),
      ('Toor Dal 1kg', '890100000009', '0713', 155.0, 5.0, 55.0),
      ('Notebook A4 200 Pages', '890100000010', '4820', 62.0, 12.0, 90.0),
    ];
    for (final product in products) {
      await _db
          .into(_db.groceryProducts)
          .insert(
            GroceryProductsCompanion.insert(
              name: product.$1,
              barcode: Value(product.$2),
              hsnCode: Value(product.$3),
              salePrice: product.$4,
              taxPercent: Value(product.$5),
              stockQty: Value(product.$6),
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
  }
}
