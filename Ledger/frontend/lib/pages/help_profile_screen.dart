// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations

part of 'screens.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AppShell(
      activeRoute: '/help',
      searchHint: 'Search help...',
      floatingIcon: Icons.support_agent_outlined,
      child: _HelpContent(),
    );
  }
}

class _HelpContent extends StatelessWidget {
  const _HelpContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PageTitle(
          title: 'Help Center',
          subtitle:
              'Guides for ledger entry, balance sheet review, reports, and GST workflows.',
        ),
        SizedBox(height: 24),
        _ResponsiveGrid(
          minTileWidth: 300,
          children: [
            _HelpCard(
              icon: Icons.menu_book_outlined,
              title: 'Ledger Entries',
              description:
                  'Create vouchers, apply filters, export ledger details, and reconcile balances.',
            ),
            _HelpCard(
              icon: Icons.account_balance_outlined,
              title: 'Balance Sheet',
              description:
                  'Review liabilities, assets, compliance notes, and auditor sign-off.',
            ),
            _HelpCard(
              icon: Icons.assessment_outlined,
              title: 'Reports',
              description:
                  'Read performance charts, GST compliance cards, and revenue breakdowns.',
            ),
            _HelpCard(
              icon: Icons.settings_outlined,
              title: 'Administration',
              description:
                  'Configure company details, roles, alerts, and fiscal-year defaults.',
            ),
          ],
        ),
        SizedBox(height: 24),
        _SupportPanel(),
      ],
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AppShell(
      activeRoute: '/profile',
      searchHint: 'Search profile...',
      floatingIcon: Icons.edit_outlined,
      child: _ProfileContent(),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state.user;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PageTitle(
              title: 'Profile',
              subtitle: 'Signed-in user and company account details.',
            ),
            SizedBox(height: 24),
            _Panel(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 620;
                  final profileDetails = Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: Color(0xFFE4E1EA),
                        child: Icon(Icons.person, color: _primary, size: 34),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name.isNotEmpty == true
                                  ? user!.name
                                  : 'User not available',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w800),
                            ),
                            SizedBox(height: 6),
                            Text(
                              state.isAuthenticated
                                  ? 'ACTIVE SESSION'
                                  : 'NO ACTIVE SESSION',
                              style: TextStyle(color: _appMuted(context)),
                            ),
                            SizedBox(height: 18),
                            _ProfileFact(
                                label: 'Role',
                                value: user?.role ?? 'Not configured'),
                            _ProfileFact(
                                label: 'Email',
                                value: user?.email ?? 'Not configured'),
                            _ProfileFact(
                                label: 'GSTIN', value: 'Not configured'),
                            _ProfileFact(
                                label: 'Fiscal Year', value: 'Not configured'),
                          ],
                        ),
                      ),
                    ],
                  );

                  final logoutButton = FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: _red),
                    onPressed: () {
                      context.read<AuthCubit>().logout();
                      context.go('/login');
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                  );

                  if (compact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        profileDetails,
                        const SizedBox(height: 20),
                        logoutButton,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: profileDetails),
                      const SizedBox(width: 20),
                      logoutButton,
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 24),
            _ResponsiveGrid(
              minTileWidth: 260,
              children: [
                _MetricCard(
                  label: 'OPEN APPROVALS',
                  value: '0',
                  color: _primary,
                  note: 'No approvals yet',
                ),
                _MetricCard(
                  label: 'LAST LOGIN',
                  value: state.isAuthenticated ? 'Active' : 'None',
                  color: _green,
                  note: 'Session status',
                ),
                _MetricCard(
                  label: 'AUDIT EVENTS',
                  value: '0',
                  color: _primary,
                  note: 'No audit events yet',
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _HelpCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _HelpCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _primary, size: 30),
          const SizedBox(height: 16),
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Text(description, style: TextStyle(color: _appMuted(context))),
        ],
      ),
    );
  }
}

class _SupportPanel extends StatelessWidget {
  const _SupportPanel();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;

          return Wrap(
            spacing: 24,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: compact ? constraints.maxWidth : 420,
                child: const Text(
                  'Need help with month-end close? Contact support or generate an audit preparation checklist.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(
                width: compact ? constraints.maxWidth : null,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: _primary),
                  onPressed: () {},
                  icon: const Icon(Icons.support_agent),
                  label: const Text('Contact Support'),
                ),
              ),
              SizedBox(
                width: compact ? constraints.maxWidth : null,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: _primary),
                  onPressed: () {},
                  icon: const Icon(Icons.checklist),
                  label: const Text('Audit Checklist'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileFact extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileFact({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 360;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: _appMuted(context))),
                const SizedBox(height: 3),
                Text(value,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            );
          }

          return Row(
            children: [
              SizedBox(
                width: 110,
                child: Text(label, style: TextStyle(color: _appMuted(context))),
              ),
              Expanded(
                child: Text(value,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          );
        },
      ),
    );
  }
}
