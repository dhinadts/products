import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/ads/banner_ad_widget.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/utils/responsive.dart';
import '../../../home/data/repositories/home_repository.dart';
import '../../../home/presentation/bloc/home_cubit.dart';
import '../../../home/presentation/pages/home_tab.dart';
import '../../../records/data/repositories/records_repository.dart';
import '../../../records/presentation/bloc/records_cubit.dart';
import '../../../records/presentation/pages/records_tab.dart';
import '../../../reports/data/repositories/reports_repository.dart';
import '../../../reports/presentation/bloc/reports_cubit.dart';
import '../../../reports/presentation/pages/reports_tab.dart';
import '../../../settings/data/repositories/settings_repository.dart';
import '../../../settings/presentation/bloc/settings_cubit.dart';
import '../../../settings/presentation/pages/settings_tab.dart';
import '../bloc/dashboard_cubit.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/billmaster_widgets.dart';
import '../widgets/company_drawer.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, this.initialIndex = 0});

  final int initialIndex;

  static const _tabs = [
    _DashboardTab('Dashboard', Icons.dashboard_outlined, Icons.dashboard),
    _DashboardTab('Invoices', Icons.receipt_long_outlined, Icons.receipt_long),
    _DashboardTab('Customers', Icons.people_outline, Icons.people),
    _DashboardTab('Inventory', Icons.inventory_2_outlined, Icons.inventory_2),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => DashboardCubit(initialIndex: initialIndex)),
        BlocProvider(create: (_) => HomeCubit(HomeRepository())..loadItems()),
        BlocProvider(
          create: (_) => RecordsCubit(RecordsRepository())..loadRecords(),
        ),
        BlocProvider(
          create: (_) => ReportsCubit(ReportsRepository())..loadReports(),
        ),
        BlocProvider(
          create: (_) => SettingsCubit(SettingsRepository())..loadSettings(),
        ),
      ],
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          final selectedIndex = state.selectedIndex;
          final showModuleTabs =
              !kIsWeb && Responsive.deviceType(context) != DeviceType.desktop;
          return Scaffold(
            backgroundColor: billPageBg(context),
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: billPageBg(context),
              foregroundColor: billPrimaryText(context),
              elevation: 0,
              leading: Builder(
                builder: (context) => IconButton(
                  tooltip: 'Menu',
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu),
                ),
              ),
              titleSpacing: 0,
              title: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: billNavy,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.store, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'BillMaster GST',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 20 : 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, themeMode) {
                    final isDark = themeMode == ThemeMode.dark;
                    return IconButton(
                      tooltip: isDark ? 'Use light theme' : 'Use dark theme',
                      onPressed: () => context.read<ThemeCubit>().toggleTheme(),
                      icon: Icon(
                        isDark
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                      ),
                    );
                  },
                ),
                IconButton(
                  tooltip: 'Settings',
                  onPressed: () => context.read<DashboardCubit>().selectTab(3),
                  icon: const Icon(Icons.settings_outlined),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    tooltip: 'Profile',
                    onPressed: () => _showProfile(context),
                    icon: const CircleAvatar(
                      radius: 15,
                      backgroundColor: billNavy,
                      child: Text(
                        'D',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            drawer: const CompanyDrawer(),
            bottomNavigationBar: showModuleTabs
                ? _DashboardBottomNav(
                    selectedIndex: selectedIndex,
                    onDestinationSelected: context
                        .read<DashboardCubit>()
                        .selectTab,
                  )
                : const SafeArea(top: false, child: BannerAdWidget()),
            body: Stack(
              children: [
                Positioned.fill(
                  child: IndexedStack(
                    index: selectedIndex,
                    children: const [
                      HomeTab(),
                      RecordsTab(),
                      ReportsTab(),
                      SettingsTab(),
                    ],
                  ),
                ),
                _MovableFab(child: _fabForIndex(context, selectedIndex)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _fabForIndex(BuildContext context, int index) {
    final mobile = Responsive.isMobile(context);
    return switch (index) {
      0 =>
        mobile
            ? FloatingActionButton(
                heroTag: 'home-fab',
                onPressed: () => context.read<HomeCubit>().addQuickItem(),
                child: const Icon(Icons.add),
              )
            : FloatingActionButton.extended(
                heroTag: 'home-fab',
                onPressed: () => context.read<HomeCubit>().addQuickItem(),
                icon: const Icon(Icons.add),
                label: const Text('New Bill'),
              ),
      1 =>
        mobile
            ? FloatingActionButton(
                heroTag: 'records-fab',
                onPressed: () => context.read<RecordsCubit>().addRecord(),
                child: const Icon(Icons.print_outlined),
              )
            : FloatingActionButton.extended(
                heroTag: 'records-fab',
                onPressed: () => context.read<RecordsCubit>().addRecord(),
                icon: const Icon(Icons.print_outlined),
                label: const Text('Save Invoice'),
              ),
      2 =>
        mobile
            ? FloatingActionButton(
                heroTag: 'reports-fab',
                onPressed: () => context.read<ReportsCubit>().exportReport(),
                child: const Icon(Icons.person_add_alt),
              )
            : FloatingActionButton.extended(
                heroTag: 'reports-fab',
                onPressed: () => context.read<ReportsCubit>().exportReport(),
                icon: const Icon(Icons.person_add_alt),
                label: const Text('Add Customer'),
              ),
      _ =>
        mobile
            ? FloatingActionButton(
                heroTag: 'settings-fab',
                onPressed: () => context.read<SettingsCubit>().editSettings(),
                child: const Icon(Icons.add),
              )
            : FloatingActionButton.extended(
                heroTag: 'settings-fab',
                onPressed: () => context.read<SettingsCubit>().editSettings(),
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
              ),
    };
  }

  void _showProfile(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: billNavy,
                      child: Text(
                        'D',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'BillMaster GST Profile',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  AppConstants.companyName,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text('Local GST billing workspace'),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
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

class _MovableFab extends StatefulWidget {
  const _MovableFab({required this.child});

  final Widget child;

  @override
  State<_MovableFab> createState() => _MovableFabState();
}

class _MovableFabState extends State<_MovableFab> {
  Offset? _position;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          const margin = 16.0;
          final width = Responsive.isMobile(context) ? 58.0 : 164.0;
          final height = 58.0;
          final fallback = Offset(
            constraints.maxWidth - width - margin,
            constraints.maxHeight - height - margin,
          );
          final position = _clamp(
            _position ?? fallback,
            constraints,
            width,
            height,
          );
          return Stack(
            children: [
              Positioned(
                left: position.dx,
                top: position.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _position = _clamp(
                        position + details.delta,
                        constraints,
                        width,
                        height,
                      );
                    });
                  },
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: widget.child,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Offset _clamp(
    Offset value,
    BoxConstraints constraints,
    double width,
    double height,
  ) {
    return Offset(
      value.dx.clamp(8.0, constraints.maxWidth - width - 8.0).toDouble(),
      value.dy.clamp(8.0, constraints.maxHeight - height - 8.0).toDouble(),
    );
  }
}

class _DashboardBottomNav extends StatelessWidget {
  const _DashboardBottomNav({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: billSurface(context),
      elevation: 12,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: billLine(context))),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  navigationBarTheme: NavigationBarThemeData(
                    labelTextStyle: WidgetStateProperty.resolveWith((states) {
                      return TextStyle(
                        color: states.contains(WidgetState.selected)
                            ? billPrimaryText(context)
                            : billSecondaryText(context),
                        fontSize: 11,
                        fontWeight: states.contains(WidgetState.selected)
                            ? FontWeight.w900
                            : FontWeight.w700,
                      );
                    }),
                  ),
                ),
                child: NavigationBar(
                  height: Responsive.isMobile(context) ? 76 : 66,
                  backgroundColor: billSurface(context),
                  indicatorColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: .18),
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onDestinationSelected,
                  destinations: DashboardPage._tabs
                      .map(
                        (tab) => NavigationDestination(
                          icon: Icon(
                            tab.icon,
                            color: billSecondaryText(context),
                          ),
                          selectedIcon: Icon(
                            tab.selectedIcon,
                            color: billPrimaryText(context),
                          ),
                          label: tab.label,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }
}

class _DashboardTab {
  const _DashboardTab(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
