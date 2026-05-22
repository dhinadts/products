// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations

part of 'screens.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AppShell(
      activeRoute: '/settings',
      searchHint: 'Search settings...',
      floatingIcon: Icons.save_outlined,
      child: _SettingsContent(),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PageTitle(
          title: 'Settings',
          subtitle:
              'Manage company preferences, compliance defaults, and access.',
        ),
        SizedBox(height: 24),
        _ResponsiveGrid(
          minTileWidth: 320,
          children: [
            _SettingsCard(
              icon: Icons.business_outlined,
              title: 'Company Profile',
              description:
                  'Company name, GSTIN, address, and fiscal year are not configured.',
              status: 'Not configured',
              statusColor: _muted,
            ),
            _SettingsCard(
              icon: Icons.receipt_long_outlined,
              title: 'Ledger Defaults',
              description:
                  'Voucher numbering, rupee formatting, debit/credit labels, and account groups.',
              status: 'Not configured',
              statusColor: _muted,
            ),
            _SettingsCard(
              icon: Icons.security_outlined,
              title: 'Access Control',
              description:
                  'Admin session, role permissions, approval limits, and audit trail visibility.',
              status: '0 admins',
              statusColor: _muted,
            ),
            _SettingsCard(
              icon: Icons.notifications_active_outlined,
              title: 'Alerts',
              description:
                  'GST filing reminders, overdue payable alerts, and monthly close notifications.',
              status: 'Off',
              statusColor: _muted,
            ),
          ],
        ),
        SizedBox(height: 24),
        _PreferencePanel(),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String status;
  final Color statusColor;

  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(icon, color: _primary),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              _Chip(label: status, color: statusColor),
            ],
          ),
          const SizedBox(height: 16),
          Text(description, style: TextStyle(color: _appMuted(context))),
        ],
      ),
    );
  }
}

class _PreferencePanel extends StatelessWidget {
  const _PreferencePanel();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Preference Defaults',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          SizedBox(height: 18),
          _PreferenceRow(label: 'Currency', value: 'Indian Rupee (₹)'),
          _PreferenceRow(label: 'Date Format', value: 'DD MMM YYYY'),
          _PreferenceRow(label: 'Voucher Prefix', value: 'GL / PV / SI'),
          _PreferenceRow(
              label: 'Approval Mode', value: 'Admin review required'),
        ],
      ),
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  final String label;
  final String value;

  const _PreferenceRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 520;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: _appMuted(context))),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: Text(label, style: TextStyle(color: _appMuted(context))),
              ),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
