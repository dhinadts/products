// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations

part of 'screens.dart';

class _AppShell extends StatelessWidget {
  final String activeRoute;
  final String searchHint;
  final String? fiscalBadge;
  final IconData floatingIcon;
  final Widget child;

  const _AppShell({
    required this.activeRoute,
    required this.searchHint,
    required this.floatingIcon,
    required this.child,
    this.fiscalBadge,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final showSidebar = constraints.maxWidth >= 1180;
        final showRail = constraints.maxWidth >= 760 && !showSidebar;
        final pagePadding = showSidebar
            ? const EdgeInsets.all(24)
            : showRail
                ? const EdgeInsets.all(20)
                : const EdgeInsets.all(16);

        return Scaffold(
          backgroundColor: _appBackground(context),
          drawer: showSidebar || showRail
              ? null
              : Drawer(child: _SideNav(activeRoute: activeRoute)),
          floatingActionButton: FloatingActionButton(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onPressed: () => _showAppFlowModal(
              context,
              _AppFlowModalType.fromRoute(activeRoute),
            ),
            child: Icon(floatingIcon),
          ),
          body: SafeArea(
            child: Row(
              children: [
                if (showSidebar) _SideNav(activeRoute: activeRoute),
                if (showRail) _TabletNavigationRail(activeRoute: activeRoute),
                Expanded(
                  child: Column(
                    children: [
                      _TopBar(
                        showMenu: !showSidebar,
                        searchHint: searchHint,
                        fiscalBadge: fiscalBadge,
                      ),
                      Expanded(
                        child: _PageScrollView(
                          padding: pagePadding,
                          child: child,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PageScrollView extends StatefulWidget {
  final EdgeInsetsGeometry padding;
  final Widget child;

  const _PageScrollView({required this.padding, required this.child});

  @override
  State<_PageScrollView> createState() => _PageScrollViewState();
}

class _PageScrollViewState extends State<_PageScrollView> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _controller,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _controller,
        padding: widget.padding,
        physics: const ScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.sizeOf(context).height - 200,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool showMenu;
  final String searchHint;
  final String? fiscalBadge;

  const _TopBar({
    required this.showMenu,
    required this.searchHint,
    this.fiscalBadge,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isCompact = constraints.maxWidth < 620;

      if (isCompact) {
        return Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _appBackground(context),
            border: Border(bottom: BorderSide(color: _appBorder(context))),
          ),
          child: Row(
            children: [
              if (showMenu) ...[
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  'Dhinadts IT Solutions & Services',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                tooltip: _isDark(context)
                    ? 'Switch to light theme'
                    : 'Switch to dark theme',
                icon: Icon(
                  _isDark(context)
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  color: _appText(context),
                ),
                onPressed: AppThemeController.toggleTheme,
              ),
              PopupMenuButton<String>(
                tooltip: 'More',
                icon: Icon(Icons.more_vert, color: _appText(context)),
                onSelected: (value) {
                  switch (value) {
                    case 'notifications':
                      context.go('/notifications');
                      break;
                    case 'help':
                      context.go('/help');
                      break;
                    case 'profile':
                      context.go('/profile');
                      break;
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'notifications',
                    child: Text('Notifications'),
                  ),
                  PopupMenuItem(
                    value: 'help',
                    child: Text('Help'),
                  ),
                  PopupMenuItem(
                    value: 'profile',
                    child: Text('Profile'),
                  ),
                ],
              ),
            ],
          ),
        );
      }

      return Container(
        constraints: const BoxConstraints(minHeight: 72),
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 12 : 24,
          vertical: isCompact ? 10 : 12,
        ),
        decoration: BoxDecoration(
          color: _appBackground(context),
          border: Border(bottom: BorderSide(color: _appBorder(context))),
        ),
        child: Row(
          children: [
            if (showMenu) ...[
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              fit: FlexFit.tight,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 6,
                children: [
                  Text(
                    'Dhinadts IT Solutions & Services (OPC) Pvt. Ltd.',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _primary,
                      fontSize: isCompact ? 19 : 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (fiscalBadge != null)
                    _Chip(
                      label: fiscalBadge!,
                      color: _green,
                      filled: true,
                      large: true,
                    ),
                ],
              ),
            ),
            if (constraints.maxWidth >= 760) ...[
              _SearchBox(hint: searchHint),
              const SizedBox(width: 20),
            ],
            IconButton(
              tooltip: _isDark(context)
                  ? 'Switch to light theme'
                  : 'Switch to dark theme',
              icon: Icon(
                _isDark(context)
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                color: _appText(context),
              ),
              onPressed: AppThemeController.toggleTheme,
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: AppRouteNames.notifications,
              icon: Icon(Icons.notifications_none, color: _appText(context)),
              onPressed: () => context.go('/notifications'),
            ),
            const SizedBox(width: 16),
            IconButton(
              tooltip: AppRouteNames.help,
              icon: Icon(Icons.help_outline, color: _appText(context)),
              onPressed: () => context.go('/help'),
            ),
            const SizedBox(width: 16),
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => context.go('/profile'),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: _primary,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _SearchBox extends StatelessWidget {
  final String hint;

  const _SearchBox({required this.hint});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 44,
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: _appSoftSurface(context),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: _appBorder(context)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: _appBorder(context)),
          ),
        ),
      ),
    );
  }
}

class _SideNav extends StatelessWidget {
  final String activeRoute;

  const _SideNav({required this.activeRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      color: _appBackground(context),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 28, 24, 34),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DHINADTS PRO',
                      style: TextStyle(
                        color: _primary,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('SSI Edition',
                        style: TextStyle(color: _appMuted(context))),
                  ],
                ),
              ),
              _NavItem(
                icon: Icons.dashboard_outlined,
                label: AppRouteNames.dashboard,
                route: '/dashboard',
                activeRoute: activeRoute,
              ),
              _NavItem(
                icon: Icons.menu_book_outlined,
                label: AppRouteNames.ledger,
                route: '/ledger',
                activeRoute: activeRoute,
              ),
              _NavItem(
                icon: Icons.account_balance_outlined,
                label: AppRouteNames.balanceSheet,
                route: '/balance-sheet',
                activeRoute: activeRoute,
              ),
              _NavItem(
                icon: Icons.assessment_outlined,
                label: AppRouteNames.reports,
                route: '/reports',
                activeRoute: activeRoute,
              ),
              _NavItem(
                icon: Icons.settings_outlined,
                label: AppRouteNames.settings,
                route: '/settings',
                activeRoute: activeRoute,
              ),
              const SizedBox(height: 220),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(58),
                    backgroundColor: _primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: () =>
                      _showAppFlowModal(context, _AppFlowModalType.ledgerEntry),
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Add Entry',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    const CircleAvatar(child: Icon(Icons.person)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Company not configured',
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'ADMIN SESSION',
                            style: TextStyle(
                                color: _appMuted(context), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabletNavigationRail extends StatelessWidget {
  final String activeRoute;

  const _TabletNavigationRail({required this.activeRoute});

  @override
  Widget build(BuildContext context) {
    const items = [
      _RailNavItem(Icons.dashboard_outlined, '/dashboard', 'Dashboard'),
      _RailNavItem(Icons.menu_book_outlined, '/ledger', 'Ledger'),
      _RailNavItem(Icons.account_balance_outlined, '/balance-sheet', 'Balance'),
      _RailNavItem(Icons.assessment_outlined, '/reports', 'Reports'),
      _RailNavItem(Icons.settings_outlined, '/settings', 'Settings'),
    ];

    return Container(
      width: 88,
      decoration: BoxDecoration(
        color: _appBackground(context),
        border: Border(right: BorderSide(color: _appBorder(context))),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 18),
            const Icon(Icons.account_balance_wallet_outlined,
                color: _primary, size: 30),
            const SizedBox(height: 26),
            ...items.map(
              (item) => Tooltip(
                message: item.label,
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: activeRoute == item.route
                        ? _appActiveNav(context)
                        : Colors.transparent,
                    foregroundColor: activeRoute == item.route
                        ? _primary
                        : _appText(context),
                    minimumSize: const Size(52, 52),
                  ),
                  onPressed: () => context.go(item.route),
                  icon: Icon(item.icon),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: IconButton.filled(
                onPressed: () =>
                    _showAppFlowModal(context, _AppFlowModalType.ledgerEntry),
                icon: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RailNavItem {
  final IconData icon;
  final String route;
  final String label;

  const _RailNavItem(this.icon, this.route, this.label);
}

enum _AppFlowModalType {
  ledgerEntry,
  dashboardAction,
  reportExport,
  balanceSheetAction,
  settingsUpdate,
  notificationsReview,
  helpRequest,
  profileEdit;

  static _AppFlowModalType fromRoute(String route) {
    switch (route) {
      case '/dashboard':
        return _AppFlowModalType.dashboardAction;
      case '/reports':
        return _AppFlowModalType.reportExport;
      case '/balance-sheet':
        return _AppFlowModalType.balanceSheetAction;
      case '/settings':
        return _AppFlowModalType.settingsUpdate;
      case '/notifications':
        return _AppFlowModalType.notificationsReview;
      case '/help':
        return _AppFlowModalType.helpRequest;
      case '/profile':
        return _AppFlowModalType.profileEdit;
      case '/ledger':
      default:
        return _AppFlowModalType.ledgerEntry;
    }
  }
}

Future<void> _showAppFlowModal(
  BuildContext context,
  _AppFlowModalType modalType,
) {
  final screenWidth = MediaQuery.sizeOf(context).width;
  final useDialog = screenWidth >= 720;

  if (useDialog) {
    return showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: _AppFlowModalContent(modalType: modalType),
        ),
      ),
    );
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: _appSurface(context),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: _AppFlowModalContent(modalType: modalType),
    ),
  );
}

class _AppFlowModalContent extends StatelessWidget {
  final _AppFlowModalType modalType;

  const _AppFlowModalContent({required this.modalType});

  @override
  Widget build(BuildContext context) {
    switch (modalType) {
      case _AppFlowModalType.dashboardAction:
        return const _DashboardActionModal();
      case _AppFlowModalType.reportExport:
        return const _ReportExportModal();
      case _AppFlowModalType.balanceSheetAction:
        return const _BalanceSheetActionModal();
      case _AppFlowModalType.settingsUpdate:
        return const _SettingsUpdateModal();
      case _AppFlowModalType.notificationsReview:
        return const _NotificationsReviewModal();
      case _AppFlowModalType.helpRequest:
        return const _HelpRequestModal();
      case _AppFlowModalType.profileEdit:
        return const _ProfileEditModal();
      case _AppFlowModalType.ledgerEntry:
        return const _LedgerEntryModal();
    }
  }
}

class _AppFlowModalShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> children;
  final String primaryActionLabel;
  final String secondaryActionLabel;

  const _AppFlowModalShell({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.children,
    required this.primaryActionLabel,
    this.secondaryActionLabel = 'Cancel',
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: _primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(subtitle,
                          style: TextStyle(color: _appMuted(context))),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...children,
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.end,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(foregroundColor: _primary),
                  onPressed: () => Navigator.pop(context),
                  child: Text(secondaryActionLabel),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: _primary),
                  onPressed: () => Navigator.pop(context),
                  child: Text(primaryActionLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LedgerEntryModal extends StatelessWidget {
  const _LedgerEntryModal();

  @override
  Widget build(BuildContext context) {
    return const _AppFlowModalShell(
      title: 'Add Ledger Entry',
      subtitle: 'Create a voucher-ready transaction for the active ledger.',
      icon: Icons.add_circle_outline,
      primaryActionLabel: 'Save Entry',
      secondaryActionLabel: 'Save Draft',
      children: [
        _ModalField(label: 'Voucher Type', value: 'Not selected'),
        _ModalField(label: 'Entry Date', value: 'Not selected'),
        _ModalField(label: 'Account', value: 'Not selected'),
        _ModalField(label: 'Debit Amount', value: '₹ 0.00'),
        _ModalField(label: 'Credit Amount', value: '₹ 0.00'),
        _ModalField(label: 'Narration', value: 'Not added'),
      ],
    );
  }
}

class _DashboardActionModal extends StatelessWidget {
  const _DashboardActionModal();

  @override
  Widget build(BuildContext context) {
    return const _AppFlowModalShell(
      title: 'Quick Dashboard Action',
      subtitle: 'Start a common cash-flow task from the dashboard.',
      icon: Icons.flash_on_outlined,
      primaryActionLabel: 'Continue',
      children: [
        _ModalChoiceTile(
          icon: Icons.receipt_long_outlined,
          title: 'New Invoice',
          subtitle: 'Create a sales invoice and add it to receivables.',
        ),
        _ModalChoiceTile(
          icon: Icons.payments_outlined,
          title: 'Payment In',
          subtitle: 'Record received cash or bank payment.',
        ),
        _ModalChoiceTile(
          icon: Icons.upload_file_outlined,
          title: 'Import Statement',
          subtitle: 'Prepare bank statement lines for reconciliation.',
        ),
      ],
    );
  }
}

class _ReportExportModal extends StatelessWidget {
  const _ReportExportModal();

  @override
  Widget build(BuildContext context) {
    return const _AppFlowModalShell(
      title: 'Generate Report',
      subtitle: 'Choose the report package for audit and management review.',
      icon: Icons.assessment_outlined,
      primaryActionLabel: 'Generate',
      children: [
        _ModalField(label: 'Report Type', value: 'Not selected'),
        _ModalField(label: 'Period', value: 'Not selected'),
        _ModalField(label: 'Format', value: 'Not selected'),
        _ModalField(label: 'Include GST Notes', value: 'No'),
      ],
    );
  }
}

class _BalanceSheetActionModal extends StatelessWidget {
  const _BalanceSheetActionModal();

  @override
  Widget build(BuildContext context) {
    return const _AppFlowModalShell(
      title: 'Balance Sheet Action',
      subtitle: 'Prepare closing figures for print, export, or auditor review.',
      icon: Icons.account_balance_outlined,
      primaryActionLabel: 'Prepare Export',
      children: [
        _ModalField(label: 'Statement Date', value: 'Not selected'),
        _ModalField(label: 'Output', value: 'Not selected'),
        _ModalField(label: 'Auditor Sign-off', value: 'Not selected'),
      ],
    );
  }
}

class _SettingsUpdateModal extends StatelessWidget {
  const _SettingsUpdateModal();

  @override
  Widget build(BuildContext context) {
    return const _AppFlowModalShell(
      title: 'Update Settings',
      subtitle: 'Review changes before applying them to company defaults.',
      icon: Icons.settings_outlined,
      primaryActionLabel: 'Apply Settings',
      children: [
        _ModalField(label: 'Currency', value: 'Indian Rupee (₹)'),
        _ModalField(label: 'Voucher Prefix', value: 'GL / PV / SI'),
        _ModalField(label: 'Approval Mode', value: 'Admin review required'),
      ],
    );
  }
}

class _NotificationsReviewModal extends StatelessWidget {
  const _NotificationsReviewModal();

  @override
  Widget build(BuildContext context) {
    return const _AppFlowModalShell(
      title: 'Review Notifications',
      subtitle: 'Mark alerts reviewed after checking the compliance queue.',
      icon: Icons.notifications_active_outlined,
      primaryActionLabel: 'Mark Reviewed',
      children: [
        _ModalChoiceTile(
          icon: Icons.warning_amber_outlined,
          title: 'GST Reconciliation',
          subtitle: '0 entries need attention before filing.',
        ),
        _ModalChoiceTile(
          icon: Icons.event_note_outlined,
          title: 'Annual Return',
          subtitle: 'No due date configured.',
        ),
      ],
    );
  }
}

class _HelpRequestModal extends StatelessWidget {
  const _HelpRequestModal();

  @override
  Widget build(BuildContext context) {
    return const _AppFlowModalShell(
      title: 'Request Support',
      subtitle: 'Send context to the support team for faster assistance.',
      icon: Icons.support_agent_outlined,
      primaryActionLabel: 'Send Request',
      children: [
        _ModalField(label: 'Topic', value: 'Month-end close assistance'),
        _ModalField(label: 'Priority', value: 'Normal'),
        _ModalField(label: 'Contact', value: 'Not configured'),
      ],
    );
  }
}

class _ProfileEditModal extends StatelessWidget {
  const _ProfileEditModal();

  @override
  Widget build(BuildContext context) {
    return const _AppFlowModalShell(
      title: 'Edit Profile',
      subtitle: 'Update admin session details and company contact metadata.',
      icon: Icons.person_outline,
      primaryActionLabel: 'Save Profile',
      children: [
        _ModalField(label: 'Display Name', value: 'Not configured'),
        _ModalField(label: 'Role', value: 'Not configured'),
        _ModalField(label: 'Email', value: 'Not configured'),
      ],
    );
  }
}

class _ModalField extends StatelessWidget {
  final String label;
  final String value;

  const _ModalField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                color: _appMuted(context),
                fontSize: 12,
                fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: _appSoftSurface(context),
              border: Border.all(color: _appBorder(context)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(value, style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }
}

class _ModalChoiceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ModalChoiceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: _appBorder(context)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(icon, color: _primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: _appMuted(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String activeRoute;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.activeRoute,
  });

  @override
  Widget build(BuildContext context) {
    final active = activeRoute == route;

    return InkWell(
      onTap: () {
        Navigator.maybePop(context);
        context.go(route);
      },
      child: Container(
        height: 56,
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          color: active ? _appActiveNav(context) : Colors.transparent,
          border: Border(
            right: BorderSide(
              color: active ? _primary : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: active ? _primary : _appText(context)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: active ? _primary : _appText(context),
                  fontSize: 18,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
