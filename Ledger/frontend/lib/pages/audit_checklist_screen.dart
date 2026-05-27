part of 'screens.dart';

class AuditChecklistScreen extends StatelessWidget {
  const AuditChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AppShell(
      activeRoute: '/audit-checklist',
      searchHint: 'Search audit checklist...',
      floatingIcon: Icons.fact_check_outlined,
      child: _AuditChecklistContent(),
    );
  }
}

class _AuditChecklistContent extends StatelessWidget {
  const _AuditChecklistContent();

  static const _sections = [
    _AuditChecklistSection(
      title: 'Ledger Readiness',
      subtitle: 'Core books and transaction status checks.',
      icon: Icons.menu_book_outlined,
      items: [
        _AuditChecklistItem('Receipt vouchers reviewed', true),
        _AuditChecklistItem('Payment vouchers reviewed', true),
        _AuditChecklistItem('Pending receivables marked', false),
        _AuditChecklistItem('Pending payables marked', false),
      ],
    ),
    _AuditChecklistSection(
      title: 'Bank Reconciliation',
      subtitle: 'Managed accounts and balance verification.',
      icon: Icons.account_balance_outlined,
      items: [
        _AuditChecklistItem('Opening balances captured', true),
        _AuditChecklistItem('Primary account selected', true),
        _AuditChecklistItem('Statement import checked', false),
        _AuditChecklistItem('Ledger balance matched', false),
      ],
    ),
    _AuditChecklistSection(
      title: 'Compliance Review',
      subtitle: 'Documents, approvals, and report handoff.',
      icon: Icons.verified_outlined,
      items: [
        _AuditChecklistItem('Company profile verified', true),
        _AuditChecklistItem('GST notes reviewed', false),
        _AuditChecklistItem('Open approvals checked', false),
        _AuditChecklistItem('Audit events exported', false),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _PageTitle(
          title: 'Audit Checklist',
          subtitle:
              'Demo-ready checklist for ledger, bank, and compliance review.',
        ),
        const SizedBox(height: 24),
        _ResponsiveGrid(
          minTileWidth: 280,
          children: _sections
              .map((section) => _AuditChecklistCard(section: section))
              .toList(),
        ),
        const SizedBox(height: 24),
        _Panel(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 620;
              final summary = _AuditSummaryCopy();
              final button = OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: _appAccent(context),
                ),
                onPressed: () => context.go('/reports'),
                icon: const Icon(Icons.assessment_outlined),
                label: const Text('Open Reports'),
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    summary,
                    const SizedBox(height: 16),
                    button,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: summary),
                  const SizedBox(width: 18),
                  button,
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AuditChecklistCard extends StatelessWidget {
  final _AuditChecklistSection section;

  const _AuditChecklistCard({required this.section});

  @override
  Widget build(BuildContext context) {
    final completed = section.items.where((item) => item.done).length;

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(section.icon, color: _appAccent(context), size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      section.subtitle,
                      style: TextStyle(color: _appMuted(context)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LinearProgressIndicator(
            value: completed / section.items.length,
            minHeight: 6,
            color: _green,
            backgroundColor: _appSoftSurface(context),
          ),
          const SizedBox(height: 14),
          Text(
            '$completed of ${section.items.length} completed',
            style: TextStyle(
              color: _appMuted(context),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          ...section.items.map((item) => _AuditChecklistTile(item: item)),
        ],
      ),
    );
  }
}

class _AuditChecklistTile extends StatelessWidget {
  final _AuditChecklistItem item;

  const _AuditChecklistTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            item.done ? Icons.check_circle : Icons.radio_button_unchecked,
            color: item.done ? _green : _appMuted(context),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.label,
              style: TextStyle(
                color: _appText(context),
                fontWeight: item.done ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditSummaryCopy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Audit Preparation',
          style: TextStyle(
            color: _appAccent(context),
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Use this demo checklist before sharing ledger reports, balance sheet figures, and managed account details with the auditor.',
          style: TextStyle(color: _appMuted(context)),
        ),
      ],
    );
  }
}

class _AuditChecklistSection {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<_AuditChecklistItem> items;

  const _AuditChecklistSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.items,
  });
}

class _AuditChecklistItem {
  final String label;
  final bool done;

  const _AuditChecklistItem(this.label, this.done);
}
