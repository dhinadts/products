enum PrinterConnectionType {
  pdfBrowser,
  bluetoothThermal,
  usbThermal,
  networkThermal,
}

extension PrinterConnectionTypeLabel on PrinterConnectionType {
  String get label => switch (this) {
    PrinterConnectionType.pdfBrowser => 'PDF/browser print',
    PrinterConnectionType.bluetoothThermal => 'Bluetooth thermal printer',
    PrinterConnectionType.usbThermal => 'USB thermal printer',
    PrinterConnectionType.networkThermal => 'LAN/WiFi thermal printer',
  };
}
