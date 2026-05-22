// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations

part of 'screens.dart';

class BalanceSheetScreen extends StatelessWidget {
  const BalanceSheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AppShell(
      activeRoute: '/balance-sheet',
      searchHint: 'Search Ledgers...',
      fiscalBadge: 'FY not configured',
      floatingIcon: Icons.receipt_long,
      child: _BalanceSheetContent(),
    );
  }
}

class _BalanceSheetContent extends StatelessWidget {
  const _BalanceSheetContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ResponsiveGrid(
          minTileWidth: 260,
          children: [
            _MetricCard(
              label: 'NET WORTH (EQUITY)',
              value: '₹ 0.00',
              color: _primary,
              note: 'No balance sheet items',
            ),
            _MetricCard(
              label: 'TOTAL PAYABLES',
              value: '₹ 0.00',
              color: _red,
              note: '₹ 0.00 due',
            ),
            _MetricCard(
              label: 'CASH & LIQUIDITY',
              value: '₹ 0.00',
              color: _green,
              icon: Icons.account_balance_wallet_outlined,
              accent: _green,
            ),
          ],
        ),
        const SizedBox(height: 28),
        _BalanceSheetTable(),
        const SizedBox(height: 24),
        _ComplianceFooter(),
      ],
    );
  }
}

class _BalanceSheetTable extends StatelessWidget {
  const _BalanceSheetTable();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BalanceSheetSummary>(
      future: _backendApi.fetchBalanceSheet(),
      builder: (context, snapshot) {
        final summary = snapshot.data;
        return _BalanceSheetTableView(
          summary: summary ?? _emptyBalanceSheet,
        );
      },
    );
  }
}

class _BalanceSheetTableView extends StatelessWidget {
  final BalanceSheetSummary summary;

  const _BalanceSheetTableView({required this.summary});

  @override
  Widget build(BuildContext context) {
    final liabilities = [
      ..._sectionsFromItems(summary.equity),
      ..._sectionsFromItems(summary.liabilities),
    ];
    final assets = _sectionsFromItems(summary.assets);
    final liabilitiesTotal = summary.equity.fold<double>(
          0,
          (sum, item) => sum + item.value,
        ) +
        summary.liabilities.fold<double>(0, (sum, item) => sum + item.value);
    final assetsTotal =
        summary.assets.fold<double>(0, (sum, item) => sum + item.value);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 820;

        return _Panel(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                child: compact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          _BalanceSheetHeaderTitle(),
                          SizedBox(height: 14),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _OutlineAction(icon: Icons.print, label: 'Print'),
                              _OutlineAction(
                                  icon: Icons.ios_share, label: 'Export Excel'),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        children: const [
                          Expanded(child: _BalanceSheetHeaderTitle()),
                          _OutlineAction(icon: Icons.print, label: 'Print'),
                          SizedBox(width: 12),
                          _OutlineAction(
                              icon: Icons.ios_share, label: 'Export Excel'),
                        ],
                      ),
              ),
              Divider(height: 1, color: _appBorder(context)),
              if (compact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _AccountColumn(
                      title: 'LIABILITIES',
                      sections: liabilities,
                      totalLabel: 'Total Liabilities',
                      total: _formatCurrency(liabilitiesTotal),
                      fillBody: false,
                    ),
                    Divider(height: 1, color: _appBorder(context)),
                    _AccountColumn(
                      title: 'ASSETS',
                      sections: assets,
                      totalLabel: 'Total Assets',
                      total: _formatCurrency(assetsTotal),
                      fillBody: false,
                    ),
                  ],
                )
              else
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _AccountColumn(
                          title: 'LIABILITIES',
                          sections: liabilities,
                          totalLabel: 'Total Liabilities',
                          total: _formatCurrency(liabilitiesTotal),
                          fillBody: true,
                        ),
                      ),
                      VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: _appBorder(context),
                      ),
                      Expanded(
                        child: _AccountColumn(
                          title: 'ASSETS',
                          sections: assets,
                          totalLabel: 'Total Assets',
                          total: _formatCurrency(assetsTotal),
                          fillBody: true,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _BalanceSheetHeaderTitle extends StatelessWidget {
  const _BalanceSheetHeaderTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Balance Sheet',
          style: TextStyle(
            color: _primary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 4),
        Text('As of not configured'),
      ],
    );
  }
}

class _AccountColumn extends StatelessWidget {
  final String title;
  final List<_AccountSection> sections;
  final String totalLabel;
  final String total;
  final bool fillBody;

  const _AccountColumn({
    required this.title,
    required this.sections,
    required this.totalLabel,
    required this.total,
    required this.fillBody,
  });

  @override
  Widget build(BuildContext context) {
    final body = sections.isEmpty
        ? const _EmptyPanelMessage(
            icon: Icons.account_balance_outlined,
            title: 'No items yet',
            subtitle: 'Add balance sheet items to calculate this side.',
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: sections.map((section) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: const TextStyle(
                        color: _primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...section.rows.map(
                      (row) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                row[0],
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              row[1],
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      height: 20,
                      color: _appBorder(context),
                    ),
                  ],
                ),
              );
            }).toList(),
          );

    return DecoratedBox(
      decoration: BoxDecoration(color: _appSurface(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: _appHeaderSurface(context),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: _primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'AMOUNT (₹)',
                  style: TextStyle(
                    color: _primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: _appBorder(context)),
          if (fillBody) Expanded(child: body) else body,
          Container(
            color: _primaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    totalLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  total,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<_AccountSection> _sectionsFromItems(List<BalanceSheetItem> items) {
  final grouped = <String, List<List<String>>>{};

  for (final item in items) {
    grouped.putIfAbsent(item.group, () => []);
    grouped[item.group]!.add([item.name, _formatIndianAmount(item.value)]);
  }

  return grouped.entries
      .map((entry) => _AccountSection(entry.key, entry.value))
      .toList();
}

const _emptyBalanceSheet = BalanceSheetSummary(
  assets: [],
  liabilities: [],
  equity: [],
);

class _ComplianceFooter extends StatelessWidget {
  const _ComplianceFooter();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 820;

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _compliancePanel(context),
              const SizedBox(height: 16),
              _auditorPanel(context),
            ],
          );
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _compliancePanel(context)),
              const SizedBox(width: 20),
              Expanded(child: _auditorPanel(context)),
            ],
          ),
        );
      },
    );
  }

  Widget _compliancePanel(BuildContext context) {
    return _Panel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified_outlined, color: _green),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Accounting Compliance',
                  style: TextStyle(
                    color: _green,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'This balance sheet has been prepared in accordance '
                  'with the Indian Accounting Standards (Ind AS) and '
                  'Schedule III of the Companies Act, 2013.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _auditorPanel(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // ↓ stretch so the divider + signature sit at the bottom
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Auditor\'s Sign-off',
                style: TextStyle(
                  color: _primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Not verified yet'),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(color: _appMuted(context)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Icon(Icons.draw_outlined, size: 16, color: _primary),
                  const Text(
                    'Auditor not configured',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccountSection {
  final String title;
  final List<List<String>> rows;

  const _AccountSection(this.title, this.rows);
}
