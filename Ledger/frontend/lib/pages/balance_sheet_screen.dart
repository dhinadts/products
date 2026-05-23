part of 'screens.dart';


class BalanceSheetScreen extends StatelessWidget {
  const BalanceSheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AppShell(
      activeRoute: '/balance-sheet',
      searchHint: 'Search balance sheet...',
      floatingIcon: Icons.account_balance,
      child: _BalanceSheetContent(),
    );
  }
}

class _BalanceSheetContent extends StatelessWidget {
  const _BalanceSheetContent();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _ledgerEntriesVersion,
      builder: (context, version, _) {
        return FutureBuilder<_LedgerData>(
          key: ValueKey(version),
          future: _fetchBalanceSheetData(),
          builder: (context, snapshot) {
            final data = snapshot.data ?? _LedgerData.empty();
            final loading = snapshot.connectionState == ConnectionState.waiting;

            final metrics = _LedgerMetrics.fromData(
              entries: data.entries,
              balances: data.balances,
            );

            final totalAssets = metrics.availableBalance + metrics.receivable;
            final totalLiabilities = metrics.payable;
            final netWorth = totalAssets - totalLiabilities;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ResponsiveGrid(
                  minTileWidth: 260,
                  children: [
                    _MetricCard(
                      label: 'TOTAL ASSETS',
                      value: _formatCurrency(totalAssets),
                      color: _green,
                      note: loading ? 'Loading...' : 'Cash/bank + receivables',
                      icon: Icons.trending_up,
                    ),
                    _MetricCard(
                      label: 'TOTAL LIABILITIES',
                      value: _formatCurrency(totalLiabilities),
                      color: _red,
                      note: loading ? 'Loading...' : 'Pending payable amount',
                      icon: Icons.trending_down,
                    ),
                    _MetricCard(
                      label: 'NET WORTH',
                      value: _formatCurrency(netWorth),
                      color: _primary,
                      note: 'Assets minus liabilities',
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _BalanceSheetSummary(
                  metrics: metrics,
                  totalAssets: totalAssets,
                  totalLiabilities: totalLiabilities,
                  netWorth: netWorth,
                ),
                const SizedBox(height: 24),
                _BalanceSheetBankTable(
                  balances: data.balances,
                  entries: data.entries,
                  loading: loading,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<_LedgerData> _fetchBalanceSheetData() async {
    final results = await Future.wait([
      _backendApi.fetchLedgerEntries(),
      _backendApi.fetchBankBalances(),
    ]);

    return _LedgerData(
      entries: results[0] as List<LedgerEntry>,
      balances: results[1] as List<BankBalance>,
    );
  }
}

class _BalanceSheetSummary extends StatelessWidget {
  final _LedgerMetrics metrics;
  final double totalAssets;
  final double totalLiabilities;
  final double netWorth;

  const _BalanceSheetSummary({
    required this.metrics,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.netWorth,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _BalanceRow(
            label: 'Available Cash / Bank',
            amount: metrics.availableBalance,
            color: _primary,
          ),
          _BalanceRow(
            label: 'Receivables - To Receive',
            amount: metrics.receivable,
            color: _green,
          ),
          _BalanceRow(
            label: 'Total Assets',
            amount: totalAssets,
            color: _green,
            strong: true,
          ),
          _BalanceRow(
            label: 'Payables - To Pay',
            amount: totalLiabilities,
            color: _red,
          ),
          _BalanceRow(
            label: 'Net Worth',
            amount: netWorth,
            color: netWorth >= 0 ? _primary : _red,
            strong: true,
          ),
        ],
      ),
    );
  }
}

class _BalanceSheetBankTable extends StatelessWidget {
  final List<BankBalance> balances;
  final List<LedgerEntry> entries;
  final bool loading;

  const _BalanceSheetBankTable({
    required this.balances,
    required this.entries,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Bank-wise Balance Sheet',
                style: TextStyle(
                  color: _primary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          if (balances.isEmpty && !loading)
            const _EmptyPanelMessage(
              icon: Icons.account_balance_outlined,
              title: 'No bank accounts',
              subtitle:
                  'Bank-wise balance will appear after accounts are configured.',
            )
          else
            ...balances.map((account) {
              final bankEntries = entries.where((entry) {
                return _sameAccount(entry.ledgerRef, account.displayName);
              }).toList();

              final metrics = _LedgerMetrics.fromData(
                entries: bankEntries,
                balances: [account],
                selectedAccount: account.displayName,
              );

              final assets = metrics.availableBalance + metrics.receivable;
              final liabilities = metrics.payable;
              final netWorth = assets - liabilities;

              return Column(
                children: [
                  _BalanceRow(
                    label: account.displayName,
                    amount: metrics.availableBalance,
                    color: _primary,
                    subtitle: 'Available balance',
                  ),
                  _BalanceRow(
                    label: 'Receivable',
                    amount: metrics.receivable,
                    color: _green,
                  ),
                  _BalanceRow(
                    label: 'Payable',
                    amount: metrics.payable,
                    color: _red,
                  ),
                  _BalanceRow(
                    label: 'Bank Net Worth',
                    amount: netWorth,
                    color: netWorth >= 0 ? _green : _red,
                    strong: true,
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }
}

class _BalanceRow extends StatelessWidget {
  final String label;
  final String? subtitle;
  final double amount;
  final Color color;
  final bool strong;

  const _BalanceRow({
    required this.label,
    required this.amount,
    required this.color,
    this.subtitle,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: strong ? _appHeaderSurface(context) : null,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: subtitle == null
                ? Text(
                    label,
                    style: TextStyle(
                      color: _appText(context),
                      fontWeight: strong ? FontWeight.w900 : FontWeight.w600,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: _appText(context),
                          fontWeight:
                              strong ? FontWeight.w900 : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: _appMuted(context),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
          ),
          Text(
            _formatCurrency(amount),
            textAlign: TextAlign.right,
            style: TextStyle(
              color: color,
              fontSize: strong ? 17 : 15,
              fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
