import 'package:cross_file/cross_file.dart';

import '../../features/billing/data/models/bill_model.dart';

abstract class PrinterService {
  Future<void> printThermalReceipt(BillModel bill);
  Future<void> printPdfInvoice(BillModel bill);
  Future<XFile?> generatePdfInvoice(BillModel bill);
}
