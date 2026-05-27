
import 'package:barcode/barcode.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../features/billing/data/models/bill_model.dart';
import 'printer_service.dart';

class PdfPrintService implements PrinterService {
  static const storeName = 'DHINADTS Grocery Store';
  static const storeAddress = 'Billing counter, Main Road';
  static const storePhone = '+91 98765 43210';
  static const gstin = 'GSTIN: 27AAAAA0000A1Z5';

  @override
  Future<XFile?> generatePdfInvoice(BillModel bill) async {
    final bytes = await buildInvoiceBytes(bill);
    if (kIsWeb) {
      return XFile.fromData(
        bytes,
        name: '${bill.billNumber}.pdf',
        mimeType: 'application/pdf',
      );
    }
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/${bill.billNumber}.pdf';
    final file = XFile.fromData(
      bytes,
      name: '${bill.billNumber}.pdf',
      mimeType: 'application/pdf',
    );
    await file.saveTo(path);
    return XFile(
      path,
      mimeType: 'application/pdf',
      name: '${bill.billNumber}.pdf',
    );
  }

  @override
  Future<void> printPdfInvoice(BillModel bill) async {
    final bytes = await buildInvoiceBytes(bill);
    await Printing.layoutPdf(
      name: bill.billNumber,
      onLayout: (_) async => bytes,
    );
  }

  @override
  Future<void> printThermalReceipt(BillModel bill) => printPdfInvoice(bill);

  Future<void> sharePdf(BillModel bill) async {
    final file = await generatePdfInvoice(bill);
    if (file == null) return;
    await SharePlus.instance.share(
      ShareParams(files: [file], text: 'Invoice ${bill.billNumber}'),
    );
  }

  Future<void> openPdf(BillModel bill) async {
    final file = await generatePdfInvoice(bill);
    if (file == null || kIsWeb) return;
    await OpenFilex.open(file.path);
  }

  Future<Uint8List> buildInvoiceBytes(BillModel bill) async {
    final doc = pw.Document();
    final money = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 54,
                height: 54,
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(
                  color: PdfColors.blueGrey900,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text(
                  'GST',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      storeName,
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(storeAddress),
                    pw.Text('Phone: $storePhone'),
                    pw.Text(gstin),
                  ],
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'TAX INVOICE',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text('Bill No: ${bill.billNumber}'),
                  pw.Text(
                    DateFormat('dd MMM yyyy, hh:mm a').format(bill.billDate),
                  ),
                  pw.Text('Cashier: ${bill.cashierName}'),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          if ((bill.customerName ?? '').isNotEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
              ),
              child: pw.Text(
                'Customer: ${bill.customerName} ${bill.customerPhone ?? ''}',
              ),
            ),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
            headers: ['Item', 'Qty', 'Rate', 'Disc', 'GST', 'Amount'],
            data: bill.items
                .map(
                  (item) => [
                    item.itemName,
                    item.quantity.toStringAsFixed(2),
                    money.format(item.rate),
                    money.format(item.discount),
                    '${item.taxPercent.toStringAsFixed(1)}%',
                    money.format(item.total),
                  ],
                )
                .toList(),
          ),
          pw.SizedBox(height: 18),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.SizedBox(
              width: 240,
              child: pw.Column(
                children: [
                  _totalRow('Subtotal', money.format(bill.subtotal)),
                  _totalRow('Discount', money.format(bill.totalDiscount)),
                  _totalRow('Tax', money.format(bill.taxAmount)),
                  pw.Divider(),
                  _totalRow(
                    'Grand Total',
                    money.format(bill.grandTotal),
                    bold: true,
                  ),
                  _totalRow('Payment', bill.paymentMode.label),
                ],
              ),
            ),
          ),
          if ((bill.upiQrData ?? '').isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.BarcodeWidget(
              barcode: Barcode.qrCode(),
              data: bill.upiQrData!,
              width: 80,
              height: 80,
            ),
          ],
          pw.Spacer(),
          pw.Text(
            'Terms: Goods once sold will not be taken back. Please verify items before leaving the counter.',
          ),
          pw.SizedBox(height: 8),
          pw.Center(child: pw.Text('Thank you for shopping with us!')),
        ],
      ),
    );
    return doc.save();
  }

  pw.Widget _totalRow(String label, String value, {bool bold = false}) {
    final style = bold
        ? pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)
        : const pw.TextStyle();
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        children: [
          pw.Text(label, style: style),
          pw.Spacer(),
          pw.Text(value, style: style),
        ],
      ),
    );
  }
}
