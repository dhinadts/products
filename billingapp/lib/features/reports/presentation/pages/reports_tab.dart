import 'package:flutter/material.dart';

import '../../../dashboard/presentation/widgets/billmaster_widgets.dart';

class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key});

  static const _customers = [
    (
      'AK',
      'Aryan Kapoor',
      '98765 43210 • GSTIN: 27AAAAA0000A1Z5',
      '₹ 45,200 (Dr)',
      Color(0xFFFFD7D5),
      Color(0xFFB00000),
    ),
    (
      'RS',
      'Radhika Sharma',
      '91234 56789 • GSTIN: 27BBBBB1111B1Z2',
      '₹ 12,800 (Cr)',
      Color(0xFFB9DCFF),
      Color(0xFF0B6623),
    ),
    (
      'ML',
      'Modern Logistics Inc.',
      '80055 00112 • Unregistered',
      '₹ 1,02,450 (Dr)',
      Color(0xFFE1E6EA),
      Color(0xFFD00000),
    ),
    (
      'VJ',
      'Vijay Jha',
      '77001 22334 • GSTIN: 27CCCCC2222C1Z8',
      '₹ 0.00',
      Color(0xFFFFDFAF),
      Color(0xFF20242A),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final mobile = isBillMobile(context);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            mobile ? 16 : 16,
            mobile ? 16 : 12,
            mobile ? 16 : 16,
            28,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!mobile) ...[
                const WebPageTitle(
                  title: 'Customers',
                  subtitle:
                      'Track receivables, payables, GST registration and customer balances.',
                  help:
                      'Use filters to separate overdue customers, pending payments and GST registered parties. Customer cards show current balance and whether it is debit or credit.',
                ),
                const SizedBox(height: 22),
              ],
              const BillSearchField(hint: 'Search customer name or GSTIN...'),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: const [
                    _FilterChip(label: 'All Customers', selected: true),
                    SizedBox(width: 8),
                    _FilterChip(
                      label: 'Pending Payments',
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                    SizedBox(width: 8),
                    _FilterChip(label: 'Overdue'),
                    SizedBox(width: 8),
                    _FilterChip(label: 'GST Registered'),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: const [
                  Expanded(
                    child: _LedgerMetric(
                      label: 'Total Receivables',
                      value: '₹ 4,28,400',
                      valueColor: Color(0xFFD00000),
                      help:
                          'Total amount customers owe your business. Prioritize follow-ups from this number.',
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _LedgerMetric(
                      label: 'Total Payables',
                      value: '₹ 1,12,000',
                      valueColor: Color(0xFF0B6623),
                      help:
                          'Total amount your business currently owes vendors or customers as credit.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Text(
                    'Customer Directory',
                    style: TextStyle(
                      fontSize: mobile ? 18 : 16,
                      color: billPrimaryText(context),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '128 Total',
                    style: TextStyle(
                      fontSize: mobile ? 14 : 16,
                      color: billSecondaryText(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._customers.map(
                (customer) => _CustomerTile(customer: customer),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.icon, this.selected = false});

  final String label;
  final IconData? icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isBillMobile(context) ? 14 : 16,
        vertical: isBillMobile(context) ? 10 : 11,
      ),
      decoration: BoxDecoration(
        color: selected ? billNavy : billSurfaceAlt(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : Colors.black54,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : billBodyText(context),
              fontSize: isBillMobile(context) ? 14 : 16,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _LedgerMetric extends StatelessWidget {
  const _LedgerMetric({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.help,
  });

  final String label;
  final String value;
  final Color valueColor;
  final String help;

  @override
  Widget build(BuildContext context) {
    return BillCard(
      padding: EdgeInsets.all(isBillMobile(context) ? 16 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: isBillMobile(context) ? 13 : 16,
                    color: billSecondaryText(context),
                  ),
                ),
              ),
              if (!isBillMobile(context)) HelpTooltip(message: help),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isBillMobile(context) ? 18 : 16,
              color: valueColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerTile extends StatelessWidget {
  const _CustomerTile({required this.customer});

  final (String, String, String, String, Color, Color) customer;

  @override
  Widget build(BuildContext context) {
    final mobile = isBillMobile(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: BillCard(
        padding: EdgeInsets.all(mobile ? 14 : 16),
        child: mobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _CustomerAvatar(customer: customer, mobile: mobile),
                      const SizedBox(width: 12),
                      Expanded(child: _CustomerDetails(customer: customer)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'BALANCE',
                        style: TextStyle(
                          color: billSecondaryText(context),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        customer.$4,
                        style: TextStyle(
                          color: customer.$6,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  _CustomerAvatar(customer: customer, mobile: mobile),
                  const SizedBox(width: 16),
                  Expanded(child: _CustomerDetails(customer: customer)),
                  SizedBox(
                    width: 150,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'BALANCE',
                          style: TextStyle(
                            color: billSecondaryText(context),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          customer.$4,
                          textAlign: TextAlign.end,
                          style: TextStyle(color: customer.$6, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _CustomerAvatar extends StatelessWidget {
  const _CustomerAvatar({required this.customer, required this.mobile});

  final (String, String, String, String, Color, Color) customer;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: mobile ? 44 : 48,
      height: mobile ? 44 : 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: customer.$5,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        customer.$1,
        style: TextStyle(
          color: customer.$6 == const Color(0xFF0B6623)
              ? const Color(0xFF466A88)
              : Colors.black,
          fontSize: mobile ? 16 : 20,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CustomerDetails extends StatelessWidget {
  const _CustomerDetails({required this.customer});

  final (String, String, String, String, Color, Color) customer;

  @override
  Widget build(BuildContext context) {
    final mobile = isBillMobile(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          customer.$2,
          style: TextStyle(
            color: billPrimaryText(context),
            fontSize: mobile ? 15 : 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          customer.$3,
          style: TextStyle(
            fontSize: mobile ? 12 : 16,
            color: billSecondaryText(context),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
