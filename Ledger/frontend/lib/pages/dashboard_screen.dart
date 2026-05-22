// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations

part of 'screens.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AppShell(
      activeRoute: '/dashboard',
      searchHint: 'Search accounts, invoices...',
      floatingIcon: Icons.add,
      child: _DashboardContent(),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _ResponsiveGrid(
              minTileWidth: 260,
              children: [
                _MetricCard(
                  label: 'CURRENT CASH / BANK',
                  value: '₹ 0.00',
                  color: _primary,
                  note: 'No ledger entries yet',
                  icon: Icons.account_balance_wallet_outlined,
                ),
                _MetricCard(
                  label: 'TOTAL RECEIVABLES (DEBTORS)',
                  value: '₹ 0.00',
                  color: _green,
                  note: '0 pending invoices',
                  icon: Icons.trending_up,
                ),
                _MetricCard(
                  label: 'TOTAL PAYABLES (CREDITORS)',
                  value: '₹ 0.00',
                  color: _red,
                  note: '₹ 0.00 due',
                  icon: Icons.trending_down,
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (compact)
              const Column(
                children: [
                  _PerformanceCard(),
                  SizedBox(height: 20),
                  _NetMarginCard(),
                  SizedBox(height: 20),
                  _QuickActionsCard(),
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(flex: 2, child: _PerformanceCard()),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: const [
                        _NetMarginCard(),
                        SizedBox(height: 20),
                        _QuickActionsCard(),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            const _RecentTransactionsTable(),
          ],
        );
      },
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 560;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Wrap(
                spacing: 16,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Monthly Performance: Sales vs Expenses',
                    style: TextStyle(
                        color: _primary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800),
                  ),
                  _Legend(color: _primary, label: 'Sales'),
                  _Legend(color: _red, label: 'Expenses'),
                ],
              ),
              const SizedBox(height: 42),
              const Wrap(
                spacing: 16,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  Text('Current Performance'),
                  Text('0% Target Achieved',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  children: const [
                    Expanded(
                      flex: 100,
                      child: ColoredBox(
                        color: Color(0xFFEAE7EF),
                        child: SizedBox(height: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: narrow ? 28 : 80,
                runSpacing: 24,
                children: const [
                  _KpiBlock(
                      label: 'TOTAL SALES', value: '₹ 0.00', color: _primary),
                  _KpiBlock(
                      label: 'TOTAL EXPENSES', value: '₹ 0.00', color: _red),
                ],
              ),
              SizedBox(height: narrow ? 32 : 72),
            ],
          );
        },
      ),
    );
  }
}

class _NetMarginCard extends StatelessWidget {
  const _NetMarginCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: _primary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Net Margin',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800)),
          SizedBox(height: 24),
          Text('₹ 0.00',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900)),
          SizedBox(height: 10),
          Text(
            'Net profit after all operating expenses this month.',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 280;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Label('QUICK ACTIONS'),
              const SizedBox(height: 12),
              if (stacked)
                const Column(
                  children: [
                    _ActionTile(
                        icon: Icons.receipt_long,
                        label: 'New Invoice',
                        color: _primary),
                    SizedBox(height: 12),
                    _ActionTile(
                        icon: Icons.payments_outlined,
                        label: 'Payment In',
                        color: _green),
                  ],
                )
              else
                const Row(
                  children: [
                    Expanded(
                        child: _ActionTile(
                            icon: Icons.receipt_long,
                            label: 'New Invoice',
                            color: _primary)),
                    SizedBox(width: 12),
                    Expanded(
                        child: _ActionTile(
                            icon: Icons.payments_outlined,
                            label: 'Payment In',
                            color: _green)),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class _RecentTransactionsTable extends StatelessWidget {
  const _RecentTransactionsTable();

  @override
  Widget build(BuildContext context) {
    return _DataPanel(
      title: 'Recent Transactions',
      action: 'View Ledger',
      columns: const [
        'DATE',
        'PARTICULARS / ACCOUNT',
        'TYPE',
        'STATUS',
        'AMOUNT'
      ],
      rows: const [],
      footer: const _EmptyPanelMessage(
        icon: Icons.receipt_long_outlined,
        title: 'No transactions yet',
        subtitle: 'Recent entries will appear after ledger activity is saved.',
      ),
    );
  }
}
