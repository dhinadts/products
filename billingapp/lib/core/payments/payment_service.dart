import 'package:url_launcher/url_launcher.dart';

import '../../features/settings/data/repositories/settings_repository.dart';
import '../../features/billing/data/models/bill_model.dart';

class PaymentResult {
  const PaymentResult({
    required this.success,
    required this.message,
    this.reference,
  });

  final bool success;
  final String message;
  final String? reference;
}

class PaymentService {
  const PaymentService({SettingsRepository? settingsRepository})
    : _settingsRepository = settingsRepository;

  static const cardCheckoutUrlKey = 'payment.card_checkout_url';
  static const upiIdKey = 'payment.upi_id';

  final SettingsRepository? _settingsRepository;

  SettingsRepository get _settings =>
      _settingsRepository ?? SettingsRepository();

  Uri upiUriForBill(BillModel bill) {
    return Uri(
      scheme: 'upi',
      host: 'pay',
      queryParameters: {
        'pa': 'store@upi',
        'pn': 'DHINADTS',
        'tn': 'Invoice ${bill.billNumber}',
        'tr': bill.billNumber,
        'cu': 'INR',
        'am': bill.grandTotal.toStringAsFixed(2),
      },
    );
  }

  Future<PaymentResult> launchUpiPayment(BillModel bill) async {
    final upiId = await _settings.getByKey(upiIdKey);
    final uri = upiId == null || upiId.settingValue.trim().isEmpty
        ? upiUriForBill(bill)
        : Uri(
            scheme: 'upi',
            host: 'pay',
            queryParameters: {
              'pa': upiId.settingValue.trim(),
              'pn': 'DHINADTS',
              'tn': 'Invoice ${bill.billNumber}',
              'tr': bill.billNumber,
              'cu': 'INR',
              'am': bill.grandTotal.toStringAsFixed(2),
            },
          );
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      return const PaymentResult(
        success: false,
        message: 'No UPI app found. Install PhonePe, GPay, Paytm or BHIM.',
      );
    }
    return PaymentResult(
      success: true,
      message: 'UPI app opened. Confirm payment after success.',
      reference: bill.billNumber,
    );
  }

  Future<PaymentResult> launchHostedCardCheckout(BillModel bill) async {
    final setting = await _settings.getByKey(cardCheckoutUrlKey);
    final template = setting?.settingValue.trim() ?? '';
    if (template.isEmpty) {
      return const PaymentResult(
        success: false,
        message:
            'Configure secure card checkout URL in App Settings > Payment gateway.',
      );
    }
    final resolved = template
        .replaceAll('{amount}', bill.grandTotal.toStringAsFixed(2))
        .replaceAll('{billNumber}', Uri.encodeComponent(bill.billNumber))
        .replaceAll(
          '{customerName}',
          Uri.encodeComponent(bill.customerName ?? 'Walk-in Customer'),
        );
    final uri = Uri.tryParse(resolved);
    if (uri == null || !uri.hasScheme) {
      return const PaymentResult(
        success: false,
        message: 'Card checkout URL is invalid.',
      );
    }
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      return const PaymentResult(
        success: false,
        message: 'Unable to open secure card checkout.',
      );
    }
    return PaymentResult(
      success: true,
      message:
          'Secure card checkout opened. Confirm payment after gateway success.',
      reference: bill.billNumber,
    );
  }

  PaymentResult confirmCardTerminalPayment({
    required String reference,
    required double amount,
  }) {
    final cleanReference = reference.trim();
    if (cleanReference.isEmpty) {
      return const PaymentResult(
        success: false,
        message: 'Enter card terminal transaction/reference number.',
      );
    }
    return PaymentResult(
      success: true,
      message: 'Card payment recorded for Rs ${amount.toStringAsFixed(2)}.',
      reference: cleanReference,
    );
  }
}
