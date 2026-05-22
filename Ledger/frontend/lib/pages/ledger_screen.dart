// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations

part of 'screens.dart';

class LedgerScreen extends StatelessWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AppShell(
      activeRoute: '/ledger',
      searchHint: 'Search entries, vouchers...',
      floatingIcon: Icons.task_alt,
      child: _LedgerContent(),
    );
  }
}

class _LedgerContent extends StatelessWidget {
  const _LedgerContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ResponsiveGrid(
          minTileWidth: 260,
          children: [
            _MetricCard(
              label: 'CASH BALANCE',
              value: '₹ 0.00',
              color: _primary,
              note: 'No entries yet',
            ),
            _MetricCard(
              label: 'TOTAL RECEIVABLES',
              value: '₹ 0.00',
              color: _green,
              note: '0 pending vouchers',
            ),
            _MetricCard(
              label: 'TOTAL PAYABLES',
              value: '₹ 0.00',
              color: _red,
              note: '₹ 0.00 due',
            ),
          ],
        ),
        SizedBox(height: 24),
        _LedgerFilters(),
        SizedBox(height: 20),
        _LedgerTable(),
      ],
    );
  }
}

class _LedgerFilters extends StatelessWidget {
  const _LedgerFilters();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;

          return Wrap(
            spacing: 20,
            runSpacing: 18,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              SizedBox(
                width: compact ? constraints.maxWidth : 560,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('DATE RANGE'),
                    if (compact)
                      const Column(
                        children: [
                          _FakeInput('mm/dd/yyyy', Icons.calendar_today),
                          SizedBox(height: 10),
                          _FakeInput('mm/dd/yyyy', Icons.calendar_today),
                        ],
                      )
                    else
                      Row(
                        children: const [
                          Expanded(
                            child:
                                _FakeInput('mm/dd/yyyy', Icons.calendar_today),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text('to'),
                          ),
                          Expanded(
                            child:
                                _FakeInput('mm/dd/yyyy', Icons.calendar_today),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: compact ? constraints.maxWidth : 260,
                child: const _FakeInput('All Accounts', Icons.expand_more),
              ),
              SizedBox(
                width: compact ? constraints.maxWidth : null,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _primary,
                    minimumSize: const Size(180, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Apply Filter'),
                ),
              ),
              SizedBox(
                width: compact ? constraints.maxWidth : null,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(140, 52),
                    side: const BorderSide(color: _primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.download, color: _primary),
                  label:
                      const Text('Export', style: TextStyle(color: _primary)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LedgerTable extends StatelessWidget {
  const _LedgerTable();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LedgerEntry>>(
      future: _backendApi.fetchLedgerEntries(),
      builder: (context, snapshot) {
        final entries = snapshot.data;
        return _LedgerTableView(
          entries: entries ?? const <LedgerEntry>[],
          loading: snapshot.connectionState == ConnectionState.waiting,
        );
      },
    );
  }
}

class _LedgerTableView extends StatelessWidget {
  final List<LedgerEntry> entries;
  final bool loading;

  const _LedgerTableView({
    required this.entries,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final totalDebit =
        entries.fold<double>(0, (sum, entry) => sum + entry.debit);
    final totalCredit =
        entries.fold<double>(0, (sum, entry) => sum + entry.credit);
    final balance = totalDebit - totalCredit;

    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = constraints.maxWidth < 700;

        return _DataPanel(
          minTableWidth: 1000,
          columns: const [
            'DATE',
            'PARTICULARS',
            'LF',
            'DEBIT (₹)',
            'CREDIT (₹)',
            'ACTION',
          ],
          rows: entries.map((entry) {
            return [
              Text(
                _formatDate(entry.date),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              _TwoLineText(entry.particulars),
              Text(entry.ledgerRef),
              _amountText(
                _formatIndianAmount(entry.debit),
                isCredit: false,
              ),
              _amountText(
                _formatIndianAmount(entry.credit),
                isCredit: true,
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert),
              ),
            ];
          }).toList(),
          footer: Container(
            color: _appHeaderSurface(context),
            padding: const EdgeInsets.all(18),
            child: Wrap(
              spacing: 24,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  loading ? 'LOADING LIVE LEDGER...' : 'RUNNING BALANCE TOTAL',
                  style: TextStyle(
                    color: _primary,
                    fontSize: mobile ? 14 : 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                _footerAmount(
                  _formatCurrency(totalDebit),
                  _green,
                  mobile,
                ),
                _footerAmount(
                  _formatCurrency(totalCredit),
                  _red,
                  mobile,
                ),
                _footerAmount(
                  _formatCurrency(balance),
                  _primary,
                  mobile,
                  bold: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _amountText(
    String value, {
    required bool isCredit,
  }) {
    final isZero = value == '0.00';

    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        value,
        style: TextStyle(
          color: isZero ? _text : (isCredit ? _red : _green),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _footerAmount(
    String value,
    Color color,
    bool mobile, {
    bool bold = false,
  }) {
    return Text(
      value,
      style: TextStyle(
        color: color,
        fontSize: mobile ? 14 : 18,
        fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
      ),
    );
  }
}
