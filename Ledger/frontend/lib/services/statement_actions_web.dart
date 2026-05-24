// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;

import '../models/backend_models.dart';

Future<String> exportLedgerStatement(
  List<LedgerEntry> entries,
  List<BankBalance> balances,
) async {
  final htmlDocument = _statementHtml(entries, balances);
  final bytes = utf8.encode(htmlDocument);
  final blob = html.Blob([bytes], 'text/html');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final fileName =
      'ledger-statement-${DateTime.now().millisecondsSinceEpoch}.html';

  html.AnchorElement(href: url)
    ..download = fileName
    ..click();
  html.window.open(url, '_blank');

  return 'Statement opened. Choose Save as PDF in the print dialog.';
}

Future<String> emailLedgerStatement(
  List<LedgerEntry> entries,
  List<BankBalance> balances,
) async {
  final subject = Uri.encodeComponent('Ledger statement');
  final body = Uri.encodeComponent(_statementText(entries, balances));
  html.window.open('mailto:?subject=$subject&body=$body', '_self');
  return 'Email draft opened with statement summary.';
}

Future<String> whatsappLedgerStatement(
  List<LedgerEntry> entries,
  List<BankBalance> balances,
) async {
  final text = Uri.encodeComponent(_statementText(entries, balances));
  html.window.open('https://wa.me/?text=$text', '_blank');
  return 'WhatsApp share opened with statement summary.';
}

String _statementHtml(List<LedgerEntry> entries, List<BankBalance> balances) {
  final totals = _totals(entries, balances);
  final accountRows = balances.map((account) {
    return '''
      <tr>
        <td>${_escape(account.accountName)}</td>
        <td>${_escape(account.bankName)}</td>
        <td>${_escape(account.accountType)}</td>
        <td class="num">${_formatAmount(account.balance)}</td>
      </tr>
    ''';
  }).join();
  final rows = entries.map((entry) {
    return '''
      <tr>
        <td>${_escape(_formatDate(entry.date))}</td>
        <td>${_escape(entry.particulars)}</td>
        <td>${_escape(entry.ledgerRef)}</td>
        <td class="num">${_formatAmount(entry.debit)}</td>
        <td class="num">${_formatAmount(entry.credit)}</td>
      </tr>
    ''';
  }).join();

  return '''
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>Ledger Statement</title>
  <style>
    body { font-family: Arial, sans-serif; color: #1b1b21; margin: 32px; }
    h1 { color: #145A32; margin: 0 0 4px; }
    .meta { color: #4C5A4D; margin-bottom: 24px; }
    .cards { display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; margin-bottom: 24px; }
    .card { border: 1px solid #C9D5C7; padding: 14px; }
    .label { font-size: 11px; font-weight: 700; color: #4C5A4D; text-transform: uppercase; }
    .value { font-size: 22px; font-weight: 800; margin-top: 8px; }
    table { border-collapse: collapse; width: 100%; }
    th, td { border: 1px solid #C9D5C7; padding: 10px; text-align: left; }
    th { background: #EAF2E4; }
    .num { text-align: right; }
    @media print { body { margin: 16px; } }
  </style>
</head>
<body>
  <h1>Dhinadts IT Solutions & Services (OPC) Pvt. Ltd.</h1>
  <div class="meta">Ledger statement generated ${_formatDate(DateTime.now())}</div>
  <div class="cards">
    <div class="card"><div class="label">Cash Balance</div><div class="value">Rs. ${_formatAmount(totals.cashBalance)}</div></div>
    <div class="card"><div class="label">Total Receivables</div><div class="value">Rs. ${_formatAmount(totals.totalDebit)}</div></div>
    <div class="card"><div class="label">Total Payables</div><div class="value">Rs. ${_formatAmount(totals.totalCredit)}</div></div>
  </div>
  <h2>Linked Bank Balances</h2>
  <table>
    <thead>
      <tr>
        <th>Account</th>
        <th>Bank</th>
        <th>Type</th>
        <th class="num">Opening Balance</th>
      </tr>
    </thead>
    <tbody>$accountRows</tbody>
  </table>
  <h2>Ledger Entries</h2>
  <table>
    <thead>
      <tr>
        <th>Date</th>
        <th>Particulars</th>
        <th>LF</th>
        <th class="num">Debit</th>
        <th class="num">Credit</th>
      </tr>
    </thead>
    <tbody>$rows</tbody>
  </table>
</body>
</html>
''';
}

String _statementText(List<LedgerEntry> entries, List<BankBalance> balances) {
  final totals = _totals(entries, balances);
  final accountLines = balances
      .map((account) =>
          '${account.displayName}: Rs. ${_formatAmount(account.balance)}')
      .join('\n');
  return '''
Dhinadts IT Solutions & Services (OPC) Pvt. Ltd.
Ledger statement

Cash Balance: Rs. ${_formatAmount(totals.cashBalance)}
Total Receivables: Rs. ${_formatAmount(totals.totalDebit)}
Total Payables: Rs. ${_formatAmount(totals.totalCredit)}

Linked Bank Balances:
$accountLines

Entries: ${entries.length}
''';
}

_StatementTotals _totals(
    List<LedgerEntry> entries, List<BankBalance> balances) {
  final totalDebit = entries.fold<double>(0, (sum, entry) => sum + entry.debit);
  final totalCredit =
      entries.fold<double>(0, (sum, entry) => sum + entry.credit);
  final openingBalance =
      balances.fold<double>(0, (sum, account) => sum + account.balance);
  return _StatementTotals(
    totalDebit: totalDebit,
    totalCredit: totalCredit,
    cashBalance: openingBalance + totalDebit - totalCredit,
  );
}

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
}

String _formatAmount(double value) {
  final sign = value < 0 ? '-' : '';
  final fixed = value.abs().toStringAsFixed(2);
  final parts = fixed.split('.');
  final whole = parts.first;
  final decimal = parts.last;

  if (whole.length <= 3) {
    return '$sign$whole.$decimal';
  }

  final lastThree = whole.substring(whole.length - 3);
  var prefix = whole.substring(0, whole.length - 3);
  final groups = <String>[];
  while (prefix.length > 2) {
    groups.insert(0, prefix.substring(prefix.length - 2));
    prefix = prefix.substring(0, prefix.length - 2);
  }
  if (prefix.isNotEmpty) {
    groups.insert(0, prefix);
  }

  return '$sign${groups.join(',')},$lastThree.$decimal';
}

String _escape(String value) {
  return const HtmlEscape().convert(value);
}

class _StatementTotals {
  final double totalDebit;
  final double totalCredit;
  final double cashBalance;

  const _StatementTotals({
    required this.totalDebit,
    required this.totalCredit,
    required this.cashBalance,
  });
}
