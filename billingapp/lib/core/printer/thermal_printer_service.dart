import 'package:cross_file/cross_file.dart';
import 'package:drift/drift.dart' show OrderingTerm;
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_pos_platform/flutter_pos_platform.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/database/app_database.dart';
import '../../features/billing/data/models/bill_item_model.dart';
import '../../features/billing/data/models/bill_model.dart';
import 'network_printer_writer.dart';
import 'pdf_print_service.dart';
import 'printer_connection_type.dart';
import 'printer_service.dart';

class PosPrinterDevice {
  const PosPrinterDevice({
    required this.name,
    this.address,
    this.vendorId,
    this.productId,
  });

  final String name;
  final String? address;
  final String? vendorId;
  final String? productId;

  String get subtitle {
    if ((address ?? '').isNotEmpty) return address!;
    final vendor = vendorId ?? '';
    final product = productId ?? '';
    if (vendor.isNotEmpty || product.isNotEmpty) return '$vendor:$product';
    return 'Ready to connect';
  }
}

class ThermalPrinterService implements PrinterService {
  ThermalPrinterService({
    PdfPrintService? fallbackPdfService,
    this.connectionType = PrinterConnectionType.pdfBrowser,
    this.printerName,
    this.printerAddress,
    this.usbVendorId,
    this.usbProductId,
    this.ipAddress,
    this.port = 9100,
  }) : _fallbackPdfService = fallbackPdfService ?? PdfPrintService();

  final PdfPrintService _fallbackPdfService;
  final PrinterConnectionType connectionType;
  final String? printerName;
  final String? printerAddress;
  final String? usbVendorId;
  final String? usbProductId;
  final String? ipAddress;
  final int port;

  Future<List<PosPrinterDevice>> scanBluetoothPrinters() async {
    if (kIsWeb) return [];
    await _requestBluetoothPermissions();
    final devices = await PrinterManager.instance
        .discovery(type: PrinterType.bluetooth)
        .toList();
    return devices
        .map(
          (device) =>
              PosPrinterDevice(name: device.name, address: device.address),
        )
        .toList();
  }

  Future<List<PosPrinterDevice>> scanUsbPrinters() async {
    if (kIsWeb) return [];
    final devices = await PrinterManager.instance
        .discovery(type: PrinterType.usb)
        .toList();
    return devices
        .map(
          (device) => PosPrinterDevice(
            name: device.name,
            vendorId: device.vendorId,
            productId: device.productId,
          ),
        )
        .toList();
  }

  Future<List<PosPrinterDevice>> scanNetworkPrinters() async {
    if (kIsWeb) return [];
    final devices = await PrinterManager.instance
        .discovery(
          type: PrinterType.network,
          model: TcpPrinterInput(
            ipAddress: ipAddress?.trim() ?? '',
            port: port,
          ),
        )
        .toList();
    return devices
        .map(
          (device) =>
              PosPrinterDevice(name: device.name, address: device.address),
        )
        .toList();
  }

  Future<void> testPrint() async {
    await printSampleInvoice();
  }

  Future<void> printSampleInvoice() async {
    await printThermalReceipt(sampleInvoice());
  }

  BillModel sampleInvoice() {
    return BillModel(
      billNumber: 'DEMO-${DateTime.now().millisecondsSinceEpoch}',
      billDate: DateTime.now(),
      cashierName: 'Demo Cashier',
      customerName: 'Walk-in Customer',
      items: const [
        BillItemModel(
          itemName: 'Rice 5kg Bag',
          barcode: '890100000001',
          quantity: 1,
          rate: 360,
          taxPercent: 5,
        ),
        BillItemModel(
          itemName: 'Sunflower Oil 1L',
          barcode: '890100000002',
          quantity: 2,
          rate: 145,
          discount: 10,
          taxPercent: 5,
        ),
        BillItemModel(
          itemName: 'Premium Soap Pack',
          barcode: '890100000006',
          quantity: 3,
          rate: 75,
          taxPercent: 18,
        ),
      ],
      paymentMode: PaymentMode.upi,
    );
  }

  Future<void> connectionTestPrint() async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    final bytes = <int>[
      ...generator.text(
        'DHINADTS Grocery Store',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
      ...generator.text(
        'Printer test successful',
        styles: const PosStyles(align: PosAlign.center),
      ),
      ...generator.text(
        DateFormat('dd MMM yyyy hh:mm a').format(DateTime.now()),
        styles: const PosStyles(align: PosAlign.center),
      ),
      ...generator.feed(2),
      ...generator.cut(),
    ];
    await _writeBytes(bytes, await _resolveConfig());
  }

  @override
  Future<void> printThermalReceipt(BillModel bill) async {
    final config = await _resolveConfig();
    if (kIsWeb || config.connectionType == PrinterConnectionType.pdfBrowser) {
      await _fallbackPdfService.printPdfInvoice(bill);
      return;
    }
    try {
      await _writeBytes(await _receiptBytes(bill), config);
    } catch (_) {
      await _fallbackPdfService.printPdfInvoice(bill);
      rethrow;
    }
  }

  @override
  Future<void> printPdfInvoice(BillModel bill) =>
      _fallbackPdfService.printPdfInvoice(bill);

  @override
  Future<XFile?> generatePdfInvoice(BillModel bill) =>
      _fallbackPdfService.generatePdfInvoice(bill);

  Future<void> _writeBytes(List<int> bytes, _PrinterConfig config) async {
    switch (config.connectionType) {
      case PrinterConnectionType.networkThermal:
        final ip = config.ipAddress?.trim();
        if (ip == null || ip.isEmpty) {
          throw StateError('Printer IP address is required.');
        }
        await writeNetworkPrinterBytes(ip, config.port, bytes);
      case PrinterConnectionType.bluetoothThermal:
        final address = config.printerAddress?.trim();
        if (address == null || address.isEmpty) {
          throw StateError('Select and save a Bluetooth printer first.');
        }
        await _requestBluetoothPermissions();
        final connected = await PrinterManager.instance.connect(
          type: PrinterType.bluetooth,
          model: BluetoothPrinterInput(
            name: config.printerName,
            address: address,
          ),
        );
        if (!connected) {
          throw StateError('Bluetooth printer connection failed.');
        }
        final sent = await PrinterManager.instance.send(
          type: PrinterType.bluetooth,
          bytes: bytes,
        );
        await PrinterManager.instance.disconnect(type: PrinterType.bluetooth);
        if (!sent) throw StateError('Bluetooth printer did not accept data.');
      case PrinterConnectionType.usbThermal:
        final vendorId = config.usbVendorId?.trim();
        final productId = config.usbProductId?.trim();
        if (vendorId == null ||
            vendorId.isEmpty ||
            productId == null ||
            productId.isEmpty) {
          throw StateError('Select and save a USB printer first.');
        }
        final connected = await PrinterManager.instance.connect(
          type: PrinterType.usb,
          model: UsbPrinterInput(
            name: config.printerName,
            vendorId: vendorId,
            productId: productId,
          ),
        );
        if (!connected) throw StateError('USB printer connection failed.');
        final sent = await PrinterManager.instance.send(
          type: PrinterType.usb,
          bytes: bytes,
        );
        await PrinterManager.instance.disconnect(type: PrinterType.usb);
        if (!sent) throw StateError('USB printer did not accept data.');
      case PrinterConnectionType.pdfBrowser:
        throw UnsupportedError(
          'PDF/browser print does not accept ESC/POS bytes.',
        );
    }
  }

  Future<void> _requestBluetoothPermissions() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
  }

  Future<_PrinterConfig> _resolveConfig() async {
    final explicitConfig = _PrinterConfig(
      connectionType: connectionType,
      printerName: printerName,
      printerAddress: printerAddress,
      usbVendorId: usbVendorId,
      usbProductId: usbProductId,
      ipAddress: ipAddress,
      port: port,
    );
    if (explicitConfig.hasExplicitPrinter) return explicitConfig;

    final query =
        AppDatabase.instance.select(AppDatabase.instance.printerSettings)
          ..orderBy([(table) => OrderingTerm.desc(table.id)])
          ..limit(1);
    final saved = await query.getSingleOrNull();
    if (saved == null) return explicitConfig;

    final savedType = PrinterConnectionType.values.firstWhere(
      (type) => type.name == saved.printerType,
      orElse: () => connectionType,
    );
    final usbParts = (saved.printerAddress ?? '').split(':');
    return _PrinterConfig(
      connectionType: savedType,
      printerName: saved.printerName,
      printerAddress: saved.printerAddress,
      usbVendorId: usbParts.isNotEmpty ? usbParts.first : null,
      usbProductId: usbParts.length > 1 ? usbParts[1] : null,
      ipAddress: saved.ipAddress,
      port: saved.port,
    );
  }

  Future<List<int>> _receiptBytes(BillModel bill) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    final money = NumberFormat.currency(locale: 'en_IN', symbol: 'Rs ');
    final bytes = <int>[];
    bytes.addAll(
      generator.text(
        'DHINADTS GROCERY STORE',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
        ),
      ),
    );
    bytes.addAll(
      generator.text(
        'Main Road | Phone: +91 98765 43210',
        styles: const PosStyles(align: PosAlign.center),
      ),
    );
    bytes.addAll(
      generator.text(
        'GSTIN: 27AAAAA0000A1Z5',
        styles: const PosStyles(align: PosAlign.center),
      ),
    );
    bytes.addAll(generator.hr());
    bytes.addAll(generator.text('Bill: ${bill.billNumber}'));
    bytes.addAll(
      generator.text(
        'Date: ${DateFormat('dd/MM/yyyy hh:mm a').format(bill.billDate)}',
      ),
    );
    bytes.addAll(generator.text('Cashier: ${bill.cashierName}'));
    bytes.addAll(generator.hr());
    bytes.addAll(
      generator.row([
        PosColumn(text: 'Item', width: 5),
        PosColumn(
          text: 'Qty',
          width: 2,
          styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: 'Rate',
          width: 2,
          styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: 'Amt',
          width: 3,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]),
    );
    for (final item in bill.items) {
      bytes.addAll(
        generator.row([
          PosColumn(
            text: item.itemName.substring(0, item.itemName.length.clamp(0, 18)),
            width: 5,
          ),
          PosColumn(
            text: item.quantity.toStringAsFixed(0),
            width: 2,
            styles: const PosStyles(align: PosAlign.right),
          ),
          PosColumn(
            text: item.rate.toStringAsFixed(0),
            width: 2,
            styles: const PosStyles(align: PosAlign.right),
          ),
          PosColumn(
            text: item.total.toStringAsFixed(0),
            width: 3,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]),
      );
    }
    bytes.addAll(generator.hr());
    bytes.addAll(
      generator.text(
        'Subtotal: ${money.format(bill.subtotal)}',
        styles: const PosStyles(align: PosAlign.right),
      ),
    );
    bytes.addAll(
      generator.text(
        'Discount: ${money.format(bill.totalDiscount)}',
        styles: const PosStyles(align: PosAlign.right),
      ),
    );
    bytes.addAll(
      generator.text(
        'Tax: ${money.format(bill.taxAmount)}',
        styles: const PosStyles(align: PosAlign.right),
      ),
    );
    bytes.addAll(
      generator.text(
        'TOTAL: ${money.format(bill.grandTotal)}',
        styles: const PosStyles(
          align: PosAlign.right,
          bold: true,
          height: PosTextSize.size2,
        ),
      ),
    );
    bytes.addAll(
      generator.text(
        'Payment: ${bill.paymentMode.label}',
        styles: const PosStyles(align: PosAlign.center),
      ),
    );
    if ((bill.upiQrData ?? '').isNotEmpty) {
      bytes.addAll(generator.qrcode(bill.upiQrData!));
    }
    bytes.addAll(
      generator.text(
        'Thank you! Visit again.',
        styles: const PosStyles(align: PosAlign.center),
      ),
    );
    bytes.addAll(generator.feed(2));
    bytes.addAll(generator.cut());
    return bytes;
  }
}

class _PrinterConfig {
  const _PrinterConfig({
    required this.connectionType,
    this.printerName,
    this.printerAddress,
    this.usbVendorId,
    this.usbProductId,
    this.ipAddress,
    required this.port,
  });

  final PrinterConnectionType connectionType;
  final String? printerName;
  final String? printerAddress;
  final String? usbVendorId;
  final String? usbProductId;
  final String? ipAddress;
  final int port;

  bool get hasExplicitPrinter =>
      connectionType != PrinterConnectionType.pdfBrowser ||
      (printerName ?? '').isNotEmpty ||
      (printerAddress ?? '').isNotEmpty ||
      (usbVendorId ?? '').isNotEmpty ||
      (usbProductId ?? '').isNotEmpty ||
      (ipAddress ?? '').isNotEmpty;
}
