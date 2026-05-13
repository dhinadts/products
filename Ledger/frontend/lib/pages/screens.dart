// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_theme.dart';

const _primary = Color(0xFF000666);
const _primaryContainer = Color(0xFF1A237E);
const _green = Color(0xFF1B6D24);
const _red = Color(0xFFC31318);
const _softSurface = Color(0xFFF5F2FB);
const _border = Color(0xFFC6C5D4);
const _text = Color(0xFF1B1B21);
const _muted = Color(0xFF454652);

bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color _appBackground(BuildContext context) =>
    Theme.of(context).scaffoldBackgroundColor;

Color _appSurface(BuildContext context) => Theme.of(context).cardColor;

Color _appSoftSurface(BuildContext context) =>
    _isDark(context) ? const Color(0xFF1A2338) : _softSurface;

Color _appHeaderSurface(BuildContext context) =>
    _isDark(context) ? const Color(0xFF202A40) : const Color(0xFFEDEAF3);

Color _appBorder(BuildContext context) =>
    _isDark(context) ? const Color(0xFF334155) : _border;

Color _appText(BuildContext context) => Theme.of(context).colorScheme.onSurface;

Color _appMuted(BuildContext context) =>
    _isDark(context) ? const Color(0xFFB6C2D6) : _muted;

Color _appActiveNav(BuildContext context) =>
    _isDark(context) ? const Color(0xFF172044) : const Color(0xFFE4E1F3);

class ScreenPage extends StatelessWidget {
  final String screenKey;
  final String title;

  const ScreenPage({super.key, required this.screenKey, required this.title});

  @override
  Widget build(BuildContext context) {
    final spec = _ScreenSpec.fromKey(screenKey);

    return _AppShell(
      activeRoute: spec.route,
      searchHint: spec.searchHint,
      fiscalBadge: spec.fiscalBadge,
      floatingIcon: spec.floatingIcon,
      child: spec.builder(context),
    );
  }
}

class _ScreenSpec {
  final String route;
  final String searchHint;
  final String? fiscalBadge;
  final IconData floatingIcon;
  final WidgetBuilder builder;

  const _ScreenSpec({
    required this.route,
    required this.searchHint,
    required this.floatingIcon,
    required this.builder,
    this.fiscalBadge,
  });

  static _ScreenSpec fromKey(String key) {
    switch (key) {
      case 'screen2':
        return _ScreenSpec(
          route: '/dashboard',
          searchHint: 'Search accounts, invoices...',
          floatingIcon: Icons.add,
          builder: (_) => const _DashboardContent(),
        );
      case 'screen3':
        return _ScreenSpec(
          route: '/reports',
          searchHint: 'Search records...',
          floatingIcon: Icons.lightbulb_outline,
          builder: (_) => const _ReportsContent(),
        );
      case 'screen4':
        return _ScreenSpec(
          route: '/balance-sheet',
          searchHint: 'Search Ledgers...',
          fiscalBadge: 'FY 2023-24',
          floatingIcon: Icons.receipt_long,
          builder: (_) => const _BalanceSheetContent(),
        );
      case 'screen1':
      default:
        return _ScreenSpec(
          route: '/ledger',
          searchHint: 'Search entries, vouchers...',
          floatingIcon: Icons.task_alt,
          builder: (_) => const _LedgerContent(),
        );
    }
  }
}

class AppRouteNames {
  static const dashboard = 'Dashboard';
  static const ledger = 'Ledger';
  static const balanceSheet = 'Balance Sheet';
  static const reports = 'Reports';
  static const settings = 'Settings';
  static const notifications = 'Notifications';
  static const help = 'Help';
  static const profile = 'Profile';
}

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
    final isCompact = MediaQuery.sizeOf(context).width < 560;

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
          if (MediaQuery.sizeOf(context).width >= 760) ...[
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
                      'Munimji Pro',
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
                            'Bharat Manufactur...',
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
        _ModalField(label: 'Voucher Type', value: 'Payment Voucher'),
        _ModalField(label: 'Entry Date', value: '24 Oct 2023'),
        _ModalField(label: 'Account', value: 'Jai Hind Steel Suppliers'),
        _ModalField(label: 'Debit Amount', value: '₹ 1,25,000.00'),
        _ModalField(label: 'Credit Amount', value: '₹ 0.00'),
        _ModalField(
            label: 'Narration', value: 'Raw material purchase invoice #882'),
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
        _ModalField(label: 'Report Type', value: 'Profit & Loss Summary'),
        _ModalField(label: 'Period', value: 'FY 2023-24, Q2'),
        _ModalField(label: 'Format', value: 'PDF and Excel'),
        _ModalField(label: 'Include GST Notes', value: 'Yes'),
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
        _ModalField(label: 'Statement Date', value: '31 Mar 2024'),
        _ModalField(
            label: 'Output', value: 'Balance Sheet with compliance note'),
        _ModalField(
            label: 'Auditor Sign-off', value: 'Include verification block'),
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
          subtitle: '24 entries need attention before filing.',
        ),
        _ModalChoiceTile(
          icon: Icons.event_note_outlined,
          title: 'Annual Return',
          subtitle: 'Due date approaching for FY 2023-24.',
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
        _ModalField(label: 'Contact', value: 'dhinakaran@dhinadts.com'),
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
        _ModalField(label: 'Display Name', value: 'Bharat Manufacturing Co.'),
        _ModalField(label: 'Role', value: 'Owner / Administrator'),
        _ModalField(label: 'Email', value: 'dhinakaran@dhinadts.com'),
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
    final compact = MediaQuery.sizeOf(context).width < 760;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ResponsiveGrid(
          minTileWidth: 260,
          children: [
            _MetricCard(
              label: 'CURRENT CASH / BANK',
              value: '₹ 14,82,500.00',
              color: _primary,
              note: '+4.2% from last month',
              noteColor: _green,
              icon: Icons.account_balance_wallet_outlined,
            ),
            _MetricCard(
              label: 'TOTAL RECEIVABLES (DEBTORS)',
              value: '₹ 8,45,210.00',
              color: _green,
              note: '12 Pending Invoices',
              icon: Icons.trending_up,
            ),
            _MetricCard(
              label: 'TOTAL PAYABLES (CREDITORS)',
              value: '₹ 3,12,040.00',
              color: _red,
              note: 'Due in 7 days: ₹ 45,000',
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
  }
}

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
              value: '₹ 4,52,890.00',
              color: _primary,
              note: 'Active Ledger',
              noteColor: _green,
            ),
            _MetricCard(
              label: 'TOTAL RECEIVABLES',
              value: '₹ 12,18,400.00',
              color: _green,
              note: '12 Pending Vouchers',
            ),
            _MetricCard(
              label: 'TOTAL PAYABLES',
              value: '₹ 3,45,200.00',
              color: _red,
              note: 'Due in 15 Days',
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
    final compact = MediaQuery.sizeOf(context).width < 860;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 12,
          alignment: WrapAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 520,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reports & Analytics',
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Financial performance for Fiscal Year 2023-24',
                    style: TextStyle(color: _appMuted(context), fontSize: 18),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _OutlineAction(icon: Icons.picture_as_pdf, label: 'Export PDF'),
                const SizedBox(width: 12),
                _OutlineAction(icon: Icons.table_chart, label: 'Export Excel'),
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
              Expanded(flex: 2, child: _IncomeChart()),
              SizedBox(width: 20),
              Expanded(child: _GstCompliance()),
            ],
          ),
        const SizedBox(height: 20),
        const _ProfitSummary(),
        const SizedBox(height: 20),
        const _RevenueBreakdown(),
      ],
    );
  }
}

class BalanceSheetScreen extends StatelessWidget {
  const BalanceSheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AppShell(
      activeRoute: '/balance-sheet',
      searchHint: 'Search Ledgers...',
      fiscalBadge: 'FY 2023-24',
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
      children: [
        _ResponsiveGrid(
          minTileWidth: 260,
          children: [
            _MetricCard(
              label: 'NET WORTH (EQUITY)',
              value: '₹ 4,25,80,000',
              color: _primary,
              note: '+12%',
              noteColor: _green,
            ),
            _MetricCard(
              label: 'TOTAL PAYABLES',
              value: '₹ 85,20,000',
              color: _red,
              note: 'Due in 30 Days',
            ),
            _MetricCard(
              label: 'CASH & LIQUIDITY',
              value: '₹ 1,12,45,000',
              color: _green,
              icon: Icons.account_balance_wallet_outlined,
              accent: _green,
            ),
          ],
        ),
        SizedBox(height: 28),
        _BalanceSheetTable(),
        SizedBox(height: 24),
        _ComplianceFooter(),
      ],
    );
  }
}

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
                  'Bharat Manufacturing Co., SSI Edition, GSTIN, address, and fiscal year.',
              status: 'Verified',
              statusColor: _green,
            ),
            _SettingsCard(
              icon: Icons.receipt_long_outlined,
              title: 'Ledger Defaults',
              description:
                  'Voucher numbering, rupee formatting, debit/credit labels, and account groups.',
              status: 'Active',
              statusColor: _primary,
            ),
            _SettingsCard(
              icon: Icons.security_outlined,
              title: 'Access Control',
              description:
                  'Admin session, role permissions, approval limits, and audit trail visibility.',
              status: '2 Admins',
              statusColor: _primary,
            ),
            _SettingsCard(
              icon: Icons.notifications_active_outlined,
              title: 'Alerts',
              description:
                  'GST filing reminders, overdue payable alerts, and monthly close notifications.',
              status: 'On',
              statusColor: _green,
            ),
          ],
        ),
        SizedBox(height: 24),
        _PreferencePanel(),
      ],
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AppShell(
      activeRoute: '/notifications',
      searchHint: 'Search notifications...',
      floatingIcon: Icons.done_all,
      child: _NotificationsContent(),
    );
  }
}

class _NotificationsContent extends StatelessWidget {
  const _NotificationsContent();

  @override
  Widget build(BuildContext context) {
    const notifications = [
      _NotificationItem(
        icon: Icons.warning_amber_outlined,
        title: 'GST reconciliation requires review',
        detail: '24 entries mismatched for August 2023. Review before filing.',
        time: 'Today, 09:30 AM',
        color: _red,
      ),
      _NotificationItem(
        icon: Icons.payments_outlined,
        title: 'Payment received from Royal Automobiles Ltd.',
        detail: '₹ 4,80,000.00 has been marked reconciled.',
        time: 'Yesterday, 04:15 PM',
        color: _green,
      ),
      _NotificationItem(
        icon: Icons.event_note_outlined,
        title: 'Annual return due date approaching',
        detail:
            'Prepare supporting balance sheet schedules before 31 Dec 2023.',
        time: '23 Oct 2023',
        color: _primary,
      ),
      _NotificationItem(
        icon: Icons.inventory_2_outlined,
        title: 'Raw material purchase pending approval',
        detail: 'Jai Hind Steel Suppliers invoice #882 is waiting for posting.',
        time: '22 Oct 2023',
        color: _primary,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _PageTitle(
          title: 'Notifications',
          subtitle: 'Latest compliance alerts, ledger activity, and approvals.',
        ),
        const SizedBox(height: 24),
        _Panel(
          padding: EdgeInsets.zero,
          child: Column(
            children: notifications
                .map((item) => _NotificationTile(item: item))
                .toList(),
          ),
        ),
      ],
    );
  }
}

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PageTitle(
          title: 'Profile',
          subtitle: 'Admin session and company account details.',
        ),
        SizedBox(height: 24),
        _Panel(
          child: Row(
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
                    Text('Bharat Manufacturing Co.',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w800)),
                    SizedBox(height: 6),
                    Text('ADMIN SESSION',
                        style: TextStyle(color: _appMuted(context))),
                    SizedBox(height: 18),
                    _ProfileFact(label: 'Role', value: 'Owner / Administrator'),
                    _ProfileFact(
                        label: 'Email', value: 'dhinakaran@dhinadts.com'),
                    _ProfileFact(label: 'GSTIN', value: '29ABCDE1234F1Z5'),
                    _ProfileFact(label: 'Fiscal Year', value: '2023-24'),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24),
        _ResponsiveGrid(
          minTileWidth: 260,
          children: [
            _MetricCard(
              label: 'OPEN APPROVALS',
              value: '7',
              color: _primary,
              note: '3 high priority',
            ),
            _MetricCard(
              label: 'LAST LOGIN',
              value: '09:18 AM',
              color: _green,
              note: 'Today',
            ),
            _MetricCard(
              label: 'AUDIT EVENTS',
              value: '128',
              color: _primary,
              note: 'This month',
            ),
          ],
        ),
      ],
    );
  }
}

class _ResponsiveGrid extends StatelessWidget {
  final double minTileWidth;
  final List<Widget> children;

  const _ResponsiveGrid({required this.minTileWidth, required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / minTileWidth)
            .floor()
            .clamp(1, children.length);
        final width = (constraints.maxWidth - ((columns - 1) * 20)) / columns;

        return Wrap(
          spacing: 20,
          runSpacing: 20,
          children: children
              .map((child) => SizedBox(width: width.toDouble(), child: child))
              .toList(),
        );
      },
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Panel({
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _appSurface(context),
        border: Border.all(color: _appBorder(context)),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: padding,
      child: child,
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String? note;
  final Color? noteColor;
  final IconData? icon;
  final Color? accent;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
    this.note,
    this.noteColor,
    this.icon,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _appSurface(context),
        border: Border.all(
            color: accent ?? _appBorder(context),
            width: accent == null ? 1 : 2),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: _appText(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              if (icon != null) Icon(icon, color: color),
            ],
          ),
          const SizedBox(height: 18),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 34,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          if (note != null) ...[
            const SizedBox(height: 12),
            Text(
              note!,
              style: TextStyle(
                color: noteColor ?? _text,
                fontSize: 16,
                fontWeight:
                    noteColor == null ? FontWeight.w400 : FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LedgerFilters extends StatelessWidget {
  const _LedgerFilters();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Wrap(
        spacing: 20,
        runSpacing: 18,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          SizedBox(
            width: 560,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Label('DATE RANGE'),
                Row(
                  children: const [
                    Expanded(
                        child: _FakeInput('mm/dd/yyyy', Icons.calendar_today)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('to'),
                    ),
                    Expanded(
                        child: _FakeInput('mm/dd/yyyy', Icons.calendar_today)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
              width: 260, child: _FakeInput('All Accounts', Icons.expand_more)),
          FilledButton.icon(
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
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(140, 52),
              side: const BorderSide(color: _primary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
            onPressed: () {},
            icon: const Icon(Icons.download, color: _primary),
            label: const Text('Export', style: TextStyle(color: _primary)),
          ),
        ],
      ),
    );
  }
}

class _FakeInput extends StatelessWidget {
  final String text;
  final IconData icon;

  const _FakeInput(this.text, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: _appBorder(context)),
        borderRadius: BorderRadius.circular(4),
        color: _appSurface(context),
      ),
      child: Row(
        children: [
          Expanded(child: Text(text)),
          Icon(icon, size: 18),
        ],
      ),
    );
  }
}

class _LedgerTable extends StatelessWidget {
  const _LedgerTable();

  @override
  Widget build(BuildContext context) {
    final rows = const [
      [
        '01 Oct 2023',
        'Opening Balance\nBrought Forward from Sep',
        'GL/01',
        '3,80,000.00',
        '0.00'
      ],
      [
        '04 Oct 2023',
        'To Sharma & Sons Pvt Ltd\nVoucher #PV-9021 (Raw Material)',
        'GL/45',
        '0.00',
        '1,25,000.00'
      ],
      [
        '08 Oct 2023',
        'By HDFC Bank A/c\nTransfer for Salary Disbursal',
        'GL/12',
        '4,50,000.00',
        '0.00'
      ],
      [
        '12 Oct 2023',
        'To Electricity Board\nFactory Bill Oct #EB882',
        'GL/88',
        '0.00',
        '42,110.00'
      ],
      [
        '15 Oct 2023',
        'By Cash Sales\nRetail Counter Sale - Batch A',
        'GL/09',
        '2,10,000.00',
        '0.00'
      ],
    ];

    return _DataPanel(
      columns: const [
        'DATE',
        'PARTICULARS',
        'LF',
        'DEBIT (₹)',
        'CREDIT (₹)',
        'ACTION'
      ],
      rows: rows
          .map(
            (row) => [
              Text(row[0]),
              _TwoLineText(row[1]),
              Text(row[2]),
              Align(alignment: Alignment.centerRight, child: Text(row[3])),
              Align(
                alignment: Alignment.centerRight,
                child: Text(row[4],
                    style: TextStyle(color: row[4] == '0.00' ? _text : _red)),
              ),
              const Icon(Icons.more_vert),
            ],
          )
          .toList(),
      footer: Container(
        color: _appHeaderSurface(context),
        padding: const EdgeInsets.all(18),
        child: const Wrap(
          spacing: 32,
          runSpacing: 12,
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 260,
              child: Text(
                'RUNNING BALANCE TOTAL',
                style: TextStyle(color: _primary, fontSize: 18),
              ),
            ),
            Text('₹ 10,40,000.00',
                style: TextStyle(color: _green, fontSize: 18)),
            Text('₹ 1,67,110.00', style: TextStyle(color: _red, fontSize: 18)),
            Text(
              '₹ 8,72,890.00',
              style: TextStyle(
                  color: _primary, fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
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
                    color: _primary, fontSize: 22, fontWeight: FontWeight.w800),
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
              Text('July 2023 Performance'),
              Text('78% Target Achieved',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: const [
                Expanded(
                    flex: 65,
                    child: ColoredBox(
                        color: _primary, child: SizedBox(height: 20))),
                Expanded(
                    flex: 25,
                    child:
                        ColoredBox(color: _red, child: SizedBox(height: 20))),
                Expanded(
                    flex: 10,
                    child: ColoredBox(
                        color: Color(0xFFEAE7EF), child: SizedBox(height: 20))),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Wrap(
            spacing: 80,
            runSpacing: 24,
            children: [
              _KpiBlock(
                  label: 'TOTAL SALES', value: '₹ 24.5L', color: _primary),
              _KpiBlock(label: 'TOTAL EXPENSES', value: '₹ 12.8L', color: _red),
            ],
          ),
          const SizedBox(height: 72),
        ],
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
          Text('₹ 11.7L',
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
    const rows = [
      [
        '24 Oct 2023',
        'Jai Hind Steel Suppliers\nRaw Material Purchase - Invoice #882',
        'Expense',
        'PENDING',
        '₹ 1,25,000.00'
      ],
      [
        '23 Oct 2023',
        'Royal Automobiles Ltd.\nSales - Components Batch A-12',
        'Income',
        'RECONCILED',
        '₹ 4,80,000.00'
      ],
      [
        '22 Oct 2023',
        'Industrial Electricity Board\nUtility Bill - September',
        'Expense',
        'PAID',
        '₹ 42,350.00'
      ],
      [
        '20 Oct 2023',
        'Apex Tooling Solutions\nConsulting Fees - Line Optimization',
        'Expense',
        'OVERDUE',
        '₹ 12,000.00'
      ],
    ];

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
      rows: rows
          .map(
            (row) => [
              Text(row[0]),
              _TwoLineText(row[1], boldFirst: true),
              Row(
                children: [
                  Icon(row[2] == 'Income' ? Icons.south_west : Icons.north_east,
                      color: row[2] == 'Income' ? _green : _red),
                  const SizedBox(width: 10),
                  Text(row[2]),
                ],
              ),
              _Chip(
                  label: row[3],
                  color: row[3] == 'RECONCILED' || row[3] == 'PAID'
                      ? _green
                      : _red),
              Align(
                alignment: Alignment.centerRight,
                child: Text(row[4],
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          )
          .toList(),
    );
  }
}

class _IncomeChart extends StatelessWidget {
  const _IncomeChart();

  @override
  Widget build(BuildContext context) {
    const months = ['APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP'];
    const income = [120.0, 128.0, 144.0, 112.0, 136.0, 152.0];
    const expenses = [82.0, 66.0, 96.0, 128.0, 66.0, 88.0];

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text('Income vs Expenditure',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              ),
              _Legend(color: _green, label: 'Income'),
              SizedBox(width: 16),
              _Legend(color: _red, label: 'Expenditure'),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 320,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(months.length, (index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _Bar(height: income[index], color: _green),
                        const SizedBox(width: 12),
                        _Bar(height: expenses[index], color: _red),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(months[index],
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                  ],
                );
              }),
            ),
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
              icon: Icons.check_circle_outline,
              title: 'GSTR-1 Filed',
              subtitle: 'Period: August 2023',
              color: _green),
          _ComplianceTile(
              icon: Icons.check_circle_outline,
              title: 'GSTR-3B Filed',
              subtitle: 'Period: August 2023',
              color: _green),
          _ComplianceTile(
              icon: Icons.error_outline,
              title: 'GST Reconciliation',
              subtitle: '24 Entries Mismatched',
              color: _red),
          _ComplianceTile(
              icon: Icons.schedule,
              title: 'Upcoming: Annual Return',
              subtitle: 'Due: 31st Dec 2023',
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
            child: Row(
              children: const [
                Expanded(
                  child: Text(
                    'Profit & Loss Summary (Q2)',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                ),
                _Chip(label: 'PROFITABLE', color: _green, filled: true),
              ],
            ),
          ),
          const Divider(height: 1),
          const _ResponsiveGrid(
            minTileWidth: 230,
            children: [
              _SummaryCell(
                  label: 'TOTAL REVENUE',
                  value: '₹ 42,85,200',
                  note: '↗ 12.4% vs Last Quarter',
                  color: _green),
              _SummaryCell(
                  label: 'OPERATING EXPENSES',
                  value: '₹ 28,12,000',
                  note: '↗ 4.2% vs Last Quarter',
                  color: _red),
              _SummaryCell(
                  label: 'GROSS MARGIN',
                  value: '₹ 14,73,200',
                  note: '34.3% Margin Rate',
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
    const rows = [
      [
        'Machinery Spare Parts Division',
        '18,40,000',
        '12,10,000',
        '6,30,000',
        'STABLE'
      ],
      [
        'Annual Maintenance Contracts',
        '12,25,000',
        '4,50,000',
        '7,75,000',
        'GROWING'
      ],
      [
        'Export - Southeast Asia Unit',
        '9,50,000',
        '8,90,000',
        '60,000',
        'LOW MARGIN'
      ],
    ];

    return _DataPanel(
      title: 'Detailed Revenue Breakdown',
      columns: const [
        'PARTICULARS',
        'REVENUE (₹)',
        'COST (₹)',
        'MARGIN (₹)',
        'STATUS'
      ],
      rows: rows
          .map(
            (row) => [
              Text(row[0]),
              Align(alignment: Alignment.centerRight, child: Text(row[1])),
              Align(alignment: Alignment.centerRight, child: Text(row[2])),
              Align(
                  alignment: Alignment.centerRight,
                  child: Text(row[3], style: const TextStyle(color: _green))),
              _Chip(
                  label: row[4],
                  color: row[4] == 'LOW MARGIN' ? _red : _primary),
            ],
          )
          .toList(),
    );
  }
}

class _BalanceSheetTable extends StatelessWidget {
  const _BalanceSheetTable();

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;
    final liabilities = const [
      _AccountSection('Capital & Reserves', [
        ['Owner’s Capital Account', '3,50,00,000'],
        ['Add: Net Profit for the Year', '45,80,000'],
        ['Retained Earnings', '30,00,000'],
      ]),
      _AccountSection('Long-term Liabilities', [
        ['Secured Loans (SBI Term Loan)', '1,20,00,000'],
        ['Unsecured Loans (Promoter Loans)', '15,00,000'],
      ]),
      _AccountSection('Current Liabilities', [
        ['Sundry Creditors', '62,50,000'],
        ['Short-term Loans (Working Capital)', '18,70,000'],
        ['Outstanding Expenses (Electricity/Salaries)', '4,00,000'],
      ]),
    ];
    final assets = const [
      _AccountSection('Fixed Assets', [
        ['Land & Building (Heads)', '2,10,00,000'],
        ['Plant & Machinery', '1,45,00,000'],
        ['Less: Depreciation (15%)', '(21,75,000)'],
        ['Furniture & Fixtures', '12,50,000'],
      ]),
      _AccountSection('Current Assets', [
        ['Closing Inventory', '85,40,000'],
        ['Sundry Debtors', '92,40,000'],
        ['Cash in Hand', '2,45,000'],
        ['Bank Balance (HDFC Current A/c)', '1,10,00,000'],
        ['Prepaid Insurance', '10,00,000'],
      ]),
    ];

    return _Panel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Balance Sheet',
                          style: TextStyle(
                              color: _primary,
                              fontSize: 22,
                              fontWeight: FontWeight.w800)),
                      SizedBox(height: 4),
                      Text('As of 31st March, 2024 (Closing Figures)'),
                    ],
                  ),
                ),
                if (!compact) ...[
                  _OutlineAction(icon: Icons.print, label: 'Print'),
                  const SizedBox(width: 12),
                  _OutlineAction(icon: Icons.ios_share, label: 'Export Excel'),
                ],
              ],
            ),
          ),
          if (compact) ...[
            _AccountColumn(
              title: 'LIABILITIES',
              sections: liabilities,
              totalLabel: 'Total Liabilities',
              total: '₹ 6,46,00,000',
            ),
            _AccountColumn(
              title: 'ASSETS',
              sections: assets,
              totalLabel: 'Total Assets',
              total: '₹ 6,46,00,000',
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: _AccountColumn(
                    title: 'LIABILITIES',
                    sections: liabilities,
                    totalLabel: 'Total Liabilities',
                    total: '₹ 6,46,00,000',
                  ),
                ),
                Expanded(
                  child: _AccountColumn(
                    title: 'ASSETS',
                    sections: assets,
                    totalLabel: 'Total Assets',
                    total: '₹ 6,46,00,000',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ComplianceFooter extends StatelessWidget {
  const _ComplianceFooter();

  @override
  Widget build(BuildContext context) {
    return _ResponsiveGrid(
      minTileWidth: 360,
      children: [
        _Panel(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.verified_outlined, color: _green),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Accounting Compliance',
                        style: TextStyle(
                            color: _green,
                            fontSize: 18,
                            fontWeight: FontWeight.w800)),
                    SizedBox(height: 16),
                    Text(
                      'This balance sheet has been prepared in accordance with the Indian Accounting Standards (Ind AS) and Schedule III of the Companies Act, 2013.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Auditor’s Sign-off',
                  style: TextStyle(
                      color: _primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
              SizedBox(height: 16),
              Text('Digitally verified on 02/04/2024'),
              SizedBox(height: 40),
              Divider(color: _appMuted(context)),
              Text('Chartered Accountant (FRN: 001245N)'),
            ],
          ),
        ),
      ],
    );
  }
}

class _PageTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PageTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(subtitle,
            style: TextStyle(color: _appMuted(context), fontSize: 18)),
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
          Row(
            children: [
              Icon(icon, color: _primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800),
                ),
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
      child: Row(
        children: [
          Expanded(
              child: Text(label, style: TextStyle(color: _appMuted(context)))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _NotificationItem {
  final IconData icon;
  final String title;
  final String detail;
  final String time;
  final Color color;

  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.detail,
    required this.time,
    required this.color,
  });
}

class _NotificationTile extends StatelessWidget {
  final _NotificationItem item;

  const _NotificationTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: _appBorder(context))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, color: item.color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(item.detail, style: TextStyle(color: _appMuted(context))),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(item.time,
              style: TextStyle(color: _appMuted(context), fontSize: 12)),
        ],
      ),
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
      child: Wrap(
        spacing: 24,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const SizedBox(
            width: 420,
            child: Text(
              'Need help with month-end close? Contact support or generate an audit preparation checklist.',
              style: TextStyle(fontSize: 16),
            ),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: _primary),
            onPressed: () {},
            icon: const Icon(Icons.support_agent),
            label: const Text('Contact Support'),
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: _primary),
            onPressed: () {},
            icon: const Icon(Icons.checklist),
            label: const Text('Audit Checklist'),
          ),
        ],
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
      child: Row(
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
      ),
    );
  }
}

class _DataPanel extends StatelessWidget {
  final String? title;
  final String? action;
  final List<String> columns;
  final List<List<Widget>> rows;
  final Widget? footer;

  const _DataPanel({
    required this.columns,
    required this.rows,
    this.title,
    this.action,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      style: const TextStyle(
                          color: _primary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                  if (action != null)
                    Text(action!,
                        style: const TextStyle(
                            color: _primary, fontWeight: FontWeight.w800)),
                  if (action != null)
                    const Icon(Icons.arrow_forward, color: _primary),
                ],
              ),
            ),
          _HorizontalScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: MediaQuery.sizeOf(context).width - 48),
              child: DataTable(
                headingRowColor:
                    WidgetStateProperty.all(_appHeaderSurface(context)),
                border: TableBorder(
                    horizontalInside: BorderSide(color: _appBorder(context))),
                columnSpacing: 20,
                headingTextStyle: TextStyle(
                  color: _appText(context),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  fontSize: 14,
                ),
                dataTextStyle: TextStyle(color: _appText(context), fontSize: 15),
                columns: columns
                    .map((column) => DataColumn(label: Expanded(child: Text(column, overflow: TextOverflow.ellipsis))))
                    .toList(),
                rows: rows
                    .map((row) => DataRow(
                        cells: row.map((cell) => DataCell(cell)).toList()))
                    .toList(),
              ),
            ),
          ),
          if (footer != null) footer!,
        ],
      ),
    );
  }
}

class _HorizontalScrollView extends StatefulWidget {
  final Widget child;

  const _HorizontalScrollView({required this.child});

  @override
  State<_HorizontalScrollView> createState() => _HorizontalScrollViewState();
}

class _HorizontalScrollViewState extends State<_HorizontalScrollView> {
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
      notificationPredicate: (notification) => notification.depth == 0,
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        child: widget.child,
      ),
    );
  }
}

class _TwoLineText extends StatelessWidget {
  final String text;
  final bool boldFirst;

  const _TwoLineText(this.text, {this.boldFirst = false});

  @override
  Widget build(BuildContext context) {
    final parts = text.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          parts.first,
          style: TextStyle(
              fontWeight: boldFirst ? FontWeight.w800 : FontWeight.w500),
        ),
        if (parts.length > 1)
          Text(parts.last,
              style: TextStyle(color: _appMuted(context), fontSize: 13)),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;
  final bool large;

  const _Chip({
    required this.label,
    required this.color,
    this.filled = false,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 10,
        vertical: large ? 9 : 5,
      ),
      decoration: BoxDecoration(
        color: filled ? color.withAlpha(85) : color.withAlpha(18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: large ? 16 : 12,
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String label;

  const _Label(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.8),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 7, backgroundColor: color),
        const SizedBox(width: 7),
        Text(label),
      ],
    );
  }
}

class _KpiBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _KpiBlock(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 18),
      decoration: BoxDecoration(
          border: Border(left: BorderSide(color: color, width: 4))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(label),
          Text(value,
              style:
                  const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ActionTile(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 108,
      decoration: BoxDecoration(border: Border.all(color: _appBorder(context))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlineAction extends StatelessWidget {
  final IconData icon;
  final String label;

  const _OutlineAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: _primary,
        side: const BorderSide(color: _primary),
        minimumSize: const Size(150, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      onPressed: () {},
      icon: Icon(icon),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

class _Bar extends StatelessWidget {
  final double height;
  final Color color;

  const _Bar({required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: height,
      decoration: BoxDecoration(
        color: color.withAlpha(210),
        borderRadius: BorderRadius.circular(3),
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

class _AccountSection {
  final String title;
  final List<List<String>> rows;

  const _AccountSection(this.title, this.rows);
}

class _AccountColumn extends StatelessWidget {
  final String title;
  final List<_AccountSection> sections;
  final String totalLabel;
  final String total;

  const _AccountColumn({
    required this.title,
    required this.sections,
    required this.totalLabel,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: _appHeaderSurface(context),
              border: Border(
                top: BorderSide(color: _appBorder(context)),
                right: BorderSide(color: _appBorder(context)),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
            child: Row(
              children: [
                Expanded(
                    child: Text(title,
                        style: const TextStyle(color: _primary, fontSize: 18))),
                const Text('AMOUNT (₹)',
                    style: TextStyle(color: _primary, fontSize: 18)),
              ],
            ),
          ),
          ...sections.map(
            (section) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(section.title,
                      style: const TextStyle(
                          color: _primary, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 14),
                  ...section.rows.map(
                    (row) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        children: [
                          Expanded(child: Text(row[0])),
                          Text(row[1], textAlign: TextAlign.right),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: _primaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    totalLabel,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    total,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900),
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
