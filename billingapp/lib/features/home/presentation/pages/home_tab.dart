import 'package:flutter/material.dart';

import '../../../dashboard/presentation/widgets/billmaster_widgets.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  static const _transactions = [
    ('Aman Electronics', '27AABCM8390L1Z2', '₹12,450', 'Paid'),
    ('Sharma Provision Store', '27AADCS4430P1Z1', '₹8,900', 'Pending'),
    ('Global Tech Solutions', '07BQWOP1234M2Z3', '₹24,100', 'Paid'),
    ('Vikas Metal Corp', '24AAACV1212B1Z9', '₹45,000', 'Pending'),
    ('Elite Boutique', '27AAACI2020Q1Z5', '₹3,200', 'Paid'),
  ];

  @override
  Widget build(BuildContext context) {
    final mobile = isBillMobile(context);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: EdgeInsets.all(mobile ? 16 : 40),
          child: mobile
              ? _mobileBody(context)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const WebPageTitle(
                      title: 'Dashboard',
                      subtitle:
                          'Monitor sales, payment risks, stock alerts, and daily billing activity.',
                      help:
                          'Use this page first each day. Review sales, overdue payments and low-stock alerts, then use quick actions to create bills, customers or stock entries.',
                    ),
                    const SizedBox(height: 22),
                    _webBody(context),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _webBody(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'TOTAL SALES (TODAY)',
                value: '₹42,580',
                badge: '+12% from yesterday',
                help:
                    'Total value of invoices created today. Compare this with yesterday to understand sales momentum.',
                icon: Icons.trending_up,
                iconColor: billNavy,
                badgeColor: Color(0xFFDDF8E6),
                badgeText: Color(0xFF009B42),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _MetricCard(
                label: 'PENDING PAYMENTS',
                value: '₹1,12,040',
                badge: '8 Overdue Invoices',
                help:
                    'Invoices waiting for payment. Open this before sending reminders or follow-ups.',
                icon: Icons.assignment_late_outlined,
                iconColor: Color(0xFFD00000),
                badgeColor: Color(0xFFFFEFEF),
                badgeText: Color(0xFFD00000),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _MetricCard(
                label: 'LOW STOCK ALERTS',
                value: '14 Items',
                badge: 'Requires Restock',
                help:
                    'Products whose stock is below the reorder threshold. Restock before creating new invoices.',
                icon: Icons.inventory_outlined,
                iconColor: Color(0xFFB88745),
                badgeColor: Color(0xFFFFF0D8),
                badgeText: Color(0xFFA87533),
              ),
            ),
          ],
        ),
        const SizedBox(height: 34),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 380, child: _quickActions(context)),
            const SizedBox(width: 32),
            Expanded(child: _transactionsTable(context)),
          ],
        ),
      ],
    );
  }

  Widget _mobileBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _MetricCard(
          label: 'TOTAL SALES (TODAY)',
          value: '₹42,580',
          badge: '+12% from yesterday',
          help: 'Total value of invoices created today.',
          icon: Icons.trending_up,
          iconColor: billNavy,
          badgeColor: Color(0xFFDDF8E6),
          badgeText: Color(0xFF009B42),
        ),
        const SizedBox(height: 16),
        const _MetricCard(
          label: 'PENDING PAYMENTS',
          value: '₹1,12,040',
          badge: '8 Overdue Invoices',
          help: 'Invoices waiting for payment.',
          icon: Icons.assignment_late_outlined,
          iconColor: Color(0xFFD00000),
          badgeColor: Color(0xFFFFEFEF),
          badgeText: Color(0xFFD00000),
        ),
        const SizedBox(height: 16),
        const _MetricCard(
          label: 'LOW STOCK ALERTS',
          value: '14 Items',
          badge: 'Requires Restock',
          help: 'Products below the reorder threshold.',
          icon: Icons.inventory_outlined,
          iconColor: Color(0xFFB88745),
          badgeColor: Color(0xFFFFF0D8),
          badgeText: Color(0xFFA87533),
        ),
        const SizedBox(height: 28),
        _quickActions(context),
        const SizedBox(height: 28),
        _transactionsTable(context),
      ],
    );
  }

  Widget _quickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: billPrimaryText(context),
          ),
        ),
        const SizedBox(height: 16),
        _ActionTile(
          dark: true,
          icon: Icons.add_circle_outline,
          label: 'New Bill',
          trailing: Icons.chevron_right,
        ),
        const SizedBox(height: 10),
        const _ActionTile(icon: Icons.person_add_alt, label: 'Add Customer'),
        const SizedBox(height: 10),
        const _ActionTile(icon: Icons.library_add_outlined, label: 'Add Stock'),
        const SizedBox(height: 16),
        BillCard(
          color: isBillDark(context)
              ? const Color(0xFF1B334A)
              : const Color(0xFFE8F3FF),
          padding: const EdgeInsets.all(22),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.lightbulb_outline, color: Color(0xFF416B91)),
              SizedBox(width: 14),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Tax Filing Tip\n',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      TextSpan(
                        text:
                            'GSTR-1 filing is due in 3 days. Verify your HSN codes for precision.',
                      ),
                    ],
                  ),
                  style: TextStyle(color: Color(0xFF557396), height: 1.45),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _transactionsTable(BuildContext context) {
    final mobile = isBillMobile(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: billPrimaryText(context),
              ),
            ),
            const Spacer(),
            const Text(
              'VIEW ALL',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 16),
        BillCard(
          padding: EdgeInsets.zero,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: mobile ? 620 : null,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  billSurfaceAlt(context),
                ),
                dataRowMinHeight: 72,
                dataRowMaxHeight: 78,
                columns: const [
                  DataColumn(label: Text('CUSTOMER')),
                  DataColumn(label: Text('AMOUNT')),
                  DataColumn(label: Text('STATUS')),
                  DataColumn(label: Text('ACTION')),
                ],
                rows: _transactions.map((row) {
                  final paid = row.$4 == 'Paid';
                  return DataRow(
                    cells: [
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              row.$1,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: billPrimaryText(context),
                              ),
                            ),
                            Text(
                              'GSTIN:\n${row.$2}',
                              style: TextStyle(
                                fontSize: 11,
                                color: billSecondaryText(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Text(
                          row.$3,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      DataCell(
                        StatusPill(
                          text: row.$4,
                          foreground: paid
                              ? const Color(0xFF128447)
                              : const Color(0xFFD68000),
                          background: paid
                              ? const Color(0xFFD7F7E1)
                              : const Color(0xFFFFE9AC),
                        ),
                      ),
                      DataCell(
                        Icon(
                          Icons.more_vert,
                          color: billSecondaryText(context),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.badge,
    required this.help,
    required this.icon,
    required this.iconColor,
    required this.badgeColor,
    required this.badgeText,
  });

  final String label;
  final String value;
  final String badge;
  final String help;
  final IconData icon;
  final Color iconColor;
  final Color badgeColor;
  final Color badgeText;

  @override
  Widget build(BuildContext context) {
    return BillCard(
      padding: const EdgeInsets.all(26),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: isBillMobile(context) ? 116 : 126,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .8,
                      color: billSecondaryText(context),
                    ),
                  ),
                ),
                if (!isBillMobile(context)) ...[
                  HelpTooltip(message: help),
                  const SizedBox(width: 10),
                ],
                Icon(icon, color: iconColor),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: billPrimaryText(context),
              ),
            ),
            const SizedBox(height: 14),
            StatusPill(
              text: badge,
              foreground: badgeText,
              background: badgeColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.dark = false,
  });

  final IconData icon;
  final String label;
  final IconData? trailing;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return BillCard(
      color: dark ? billNavy : billSurface(context),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: dark
                  ? Colors.white.withValues(alpha: .1)
                  : billSurfaceAlt(context),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              icon,
              color: dark ? Colors.white : billPrimaryText(context),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              color: dark ? Colors.white : billPrimaryText(context),
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          if (trailing != null) Icon(trailing, color: Colors.white),
        ],
      ),
    );
  }
}
