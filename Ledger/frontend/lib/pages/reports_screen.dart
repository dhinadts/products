// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations

part of 'screens.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AppShell(
      activeRoute: '/reports',
      searchHint: 'Search records...',
      floatingIcon: Icons.lightbulb_outline,
      child: _ReportsContent(),
    );
  }
}

class _ReportsContent extends StatelessWidget {
  const _ReportsContent();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 860;
        final mobile = constraints.maxWidth < 600;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: mobile ? constraints.maxWidth : 520,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reports & Analytics',
                        style: TextStyle(
                          fontSize: mobile ? 26 : 34,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Financial performance will appear after ledger entries are saved.',
                        style: TextStyle(
                          color: _appMuted(context),
                          fontSize: mobile ? 14 : 18,
                        ),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: const [
                    _OutlineAction(
                      icon: Icons.picture_as_pdf,
                      label: 'Export PDF',
                    ),
                    _OutlineAction(
                      icon: Icons.table_chart,
                      label: 'Export Excel',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            if (compact)
              const Column(
                children: [
                  _IncomeChart(),
                  SizedBox(height: 20),
                  _GstCompliance(),
                ],
              )
            else
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _IncomeChart(),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: _GstCompliance(),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            const _ProfitSummary(),
            const SizedBox(height: 20),
            const _RevenueBreakdown(),
          ],
        );
      },
    );
  }
}

class _IncomeChart extends StatelessWidget {
  const _IncomeChart();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: const [
              Text(
                'Income vs Expenditure',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              _Legend(color: _green, label: 'Income'),
              _Legend(color: _red, label: 'Expenditure'),
            ],
          ),
          const SizedBox(height: 24),
          const _EmptyPanelMessage(
            icon: Icons.bar_chart_outlined,
            title: 'No report data yet',
            subtitle:
                'Income and expenditure charts will render from ledger entries.',
          ),
        ],
      ),
    );
  }
}

class _GstCompliance extends StatelessWidget {
  const _GstCompliance();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('GST Compliance',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          SizedBox(height: 28),
          _ComplianceTile(
              icon: Icons.info_outline,
              title: 'GSTR-1',
              subtitle: 'No filing data yet',
              color: _muted),
          _ComplianceTile(
              icon: Icons.info_outline,
              title: 'GSTR-3B',
              subtitle: 'No filing data yet',
              color: _muted),
          _ComplianceTile(
              icon: Icons.info_outline,
              title: 'GST Reconciliation',
              subtitle: '0 entries mismatched',
              color: _muted),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: null,
              child: Text('Generate GST Summary'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfitSummary extends StatelessWidget {
  const _ProfitSummary();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: const [
                Text(
                  'Profit & Loss Summary',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                _Chip(label: 'NO DATA', color: _muted, filled: true),
              ],
            ),
          ),
          const Divider(height: 1),
          const _ResponsiveGrid(
            minTileWidth: 230,
            children: [
              _SummaryCell(
                  label: 'TOTAL REVENUE',
                  value: '₹ 0.00',
                  note: 'No revenue entries',
                  color: _green),
              _SummaryCell(
                  label: 'OPERATING EXPENSES',
                  value: '₹ 0.00',
                  note: 'No expense entries',
                  color: _red),
              _SummaryCell(
                  label: 'GROSS MARGIN',
                  value: '₹ 0.00',
                  note: '0% margin rate',
                  color: _green),
            ],
          ),
        ],
      ),
    );
  }
}

class _RevenueBreakdown extends StatelessWidget {
  const _RevenueBreakdown();

  @override
  Widget build(BuildContext context) {
    return _DataPanel(
      title: 'Detailed Revenue Breakdown',
      columns: const [
        'PARTICULARS',
        'REVENUE (₹)',
        'COST (₹)',
        'MARGIN (₹)',
        'STATUS'
      ],
      rows: const [],
      footer: const _EmptyPanelMessage(
        icon: Icons.stacked_line_chart,
        title: 'No revenue breakdown yet',
        subtitle:
            'Breakdowns will appear after ledger entries are categorized.',
      ),
    );
  }
}

class _ComplianceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _ComplianceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        border: Border.all(color: color.withAlpha(70)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16)),
                Text(subtitle, style: TextStyle(color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  final String label;
  final String value;
  final String note;
  final Color color;

  const _SummaryCell({
    required this.label,
    required this.value,
    required this.note,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(label),
          Text(value,
              style: TextStyle(
                  fontSize: 26, color: color == _red ? _text : color)),
          const SizedBox(height: 14),
          Text(note, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}
