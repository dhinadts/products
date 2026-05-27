import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/printer/printer_connection_type.dart';
import '../../../../core/printer/thermal_printer_service.dart';
import '../../../dashboard/presentation/widgets/company_drawer.dart';

class PrinterSettingsPage extends StatefulWidget {
  const PrinterSettingsPage({super.key});

  @override
  State<PrinterSettingsPage> createState() => _PrinterSettingsPageState();
}

class _PrinterSettingsPageState extends State<PrinterSettingsPage> {
  PrinterConnectionType _type = PrinterConnectionType.pdfBrowser;
  final _ipController = TextEditingController(text: '192.168.1.100');
  final _portController = TextEditingController(text: '9100');
  bool _scanning = false;
  PosPrinterDevice? _selectedPrinter;
  List<PosPrinterDevice> _printers = [];

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CompanyDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: 'Menu',
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu),
          ),
        ),
        title: const Text('Printer Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<PrinterConnectionType>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Printer type'),
            items: PrinterConnectionType.values
                .map(
                  (type) =>
                      DropdownMenuItem(value: type, child: Text(type.label)),
                )
                .toList(),
            onChanged: (type) => setState(() {
              _type = type ?? PrinterConnectionType.pdfBrowser;
              _selectedPrinter = null;
              _printers = [];
            }),
          ),
          const SizedBox(height: 16),
          if (_type == PrinterConnectionType.networkThermal) ...[
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: 'Printer IP address',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _portController,
              decoration: const InputDecoration(labelText: 'Port'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _scanning ? null : _scanPrinters,
              icon: const Icon(Icons.wifi_find_outlined),
              label: Text(_scanning ? 'Scanning...' : 'Scan WiFi printers'),
            ),
          ],
          if (_type == PrinterConnectionType.bluetoothThermal ||
              _type == PrinterConnectionType.usbThermal ||
              _type == PrinterConnectionType.networkThermal) ...[
            if (_type != PrinterConnectionType.networkThermal)
              FilledButton.icon(
                onPressed: _scanning ? null : _scanPrinters,
                icon: Icon(
                  _type == PrinterConnectionType.usbThermal
                      ? Icons.usb_outlined
                      : Icons.bluetooth_searching,
                ),
                label: Text(
                  _scanning
                      ? 'Scanning...'
                      : _type == PrinterConnectionType.usbThermal
                      ? 'Scan USB printers'
                      : 'Scan Bluetooth printers',
                ),
              ),
            if (_type != PrinterConnectionType.networkThermal)
              const SizedBox(height: 8),
            if (_type == PrinterConnectionType.networkThermal &&
                _printers.isNotEmpty)
              const SizedBox(height: 8),
            ..._printers.map(
              (printer) => ListTile(
                onTap: () => setState(() {
                  _selectedPrinter = printer;
                  if (_type == PrinterConnectionType.networkThermal &&
                      (printer.address ?? '').isNotEmpty) {
                    _ipController.text = printer.address!;
                  }
                }),
                leading: Icon(
                  _type == PrinterConnectionType.networkThermal
                      ? Icons.wifi_outlined
                      : Icons.print,
                ),
                title: Text(printer.name),
                subtitle: Text(printer.subtitle),
                trailing: _selectedPrinter == printer
                    ? const Icon(Icons.check_circle)
                    : null,
              ),
            ),
          ],
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            children: [
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save printer settings'),
              ),
              OutlinedButton.icon(
                onPressed: _testPrint,
                icon: const Icon(Icons.print_outlined),
                label: const Text('Test print'),
              ),
              OutlinedButton.icon(
                onPressed: _testSampleInvoice,
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('Demo invoice'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _scanPrinters() async {
    setState(() => _scanning = true);
    try {
      final service = ThermalPrinterService(
        connectionType: _type,
        ipAddress: _ipController.text.trim(),
        port: int.tryParse(_portController.text) ?? 9100,
      );
      final devices = switch (_type) {
        PrinterConnectionType.usbThermal => await service.scanUsbPrinters(),
        PrinterConnectionType.networkThermal =>
          await service.scanNetworkPrinters(),
        PrinterConnectionType.bluetoothThermal =>
          await service.scanBluetoothPrinters(),
        PrinterConnectionType.pdfBrowser => <PosPrinterDevice>[],
      };
      setState(() {
        _printers = devices;
        _selectedPrinter = devices.isEmpty ? null : devices.first;
        if (_type == PrinterConnectionType.networkThermal &&
            (_selectedPrinter?.address ?? '').isNotEmpty) {
          _ipController.text = _selectedPrinter!.address!;
        }
      });
    } catch (error) {
      _message('Printer scan failed: $error');
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  Future<void> _save() async {
    if ((_type == PrinterConnectionType.bluetoothThermal ||
            _type == PrinterConnectionType.usbThermal) &&
        _selectedPrinter == null) {
      _message('Scan and select a printer first.');
      return;
    }
    final now = DateTime.now();
    final printerAddress = _type == PrinterConnectionType.usbThermal
        ? '${_selectedPrinter?.vendorId ?? ''}:${_selectedPrinter?.productId ?? ''}'
        : _selectedPrinter?.address;
    final ipAddress = _type == PrinterConnectionType.networkThermal
        ? (_selectedPrinter?.address ?? _ipController.text.trim())
        : _ipController.text.trim();
    await AppDatabase.instance
        .into(AppDatabase.instance.printerSettings)
        .insert(
          PrinterSettingsCompanion.insert(
            printerType: _type.name,
            printerName: Value(_selectedPrinter?.name ?? _type.label),
            printerAddress: Value(printerAddress),
            ipAddress: Value(ipAddress),
            port: Value(int.tryParse(_portController.text) ?? 9100),
            createdAt: now,
            updatedAt: now,
          ),
        );
    _message('Printer settings saved.');
  }

  Future<void> _testPrint() async {
    try {
      await ThermalPrinterService(
        connectionType: _type,
        printerName: _selectedPrinter?.name,
        printerAddress: _selectedPrinter?.address,
        usbVendorId: _selectedPrinter?.vendorId,
        usbProductId: _selectedPrinter?.productId,
        ipAddress: _selectedPrinter?.address ?? _ipController.text.trim(),
        port: int.tryParse(_portController.text) ?? 9100,
      ).connectionTestPrint();
      _message('Test print sent.');
    } catch (error) {
      _message('Test print failed. $error');
    }
  }

  Future<void> _testSampleInvoice() async {
    try {
      await ThermalPrinterService(
        connectionType: _type,
        printerName: _selectedPrinter?.name,
        printerAddress: _selectedPrinter?.address,
        usbVendorId: _selectedPrinter?.vendorId,
        usbProductId: _selectedPrinter?.productId,
        ipAddress: _selectedPrinter?.address ?? _ipController.text.trim(),
        port: int.tryParse(_portController.text) ?? 9100,
      ).printSampleInvoice();
      _message('Demo invoice sent.');
    } catch (error) {
      _message('Demo invoice failed. $error');
    }
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}
