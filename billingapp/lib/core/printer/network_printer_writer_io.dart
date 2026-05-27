import 'dart:io';

Future<void> writeNetworkPrinterBytes(
  String ipAddress,
  int port,
  List<int> bytes,
) async {
  final socket = await Socket.connect(
    ipAddress,
    port,
    timeout: const Duration(seconds: 5),
  );
  socket.add(bytes);
  await socket.flush();
  await socket.close();
}
