import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/payments/payment_service.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../dashboard/presentation/widgets/billmaster_widgets.dart';
import '../../data/repositories/settings_repository.dart';
import '../bloc/settings_cubit.dart';
import '../bloc/settings_state.dart';

class AppSettingsPage extends StatelessWidget {
  const AppSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsCubit(SettingsRepository())..loadSettings(),
      child: AppScaffold(
        title: 'App Settings',
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            final device = Responsive.deviceType(context);
            final maxWidth = switch (device) {
              DeviceType.mobile => double.infinity,
              DeviceType.tablet => 760.0,
              DeviceType.desktop => 980.0,
            };
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: ListView(
                  padding: Responsive.pagePadding(context),
                  children: [
                    _SettingsHeader(
                      onEdit: () =>
                          context.read<SettingsCubit>().editSettings(),
                    ),
                    const SizedBox(height: 18),
                    _SettingsSection(
                      title: 'Account',
                      children: [
                        _SettingsOption(
                          icon: Icons.storefront_outlined,
                          title: 'Company profile',
                          subtitle: 'Business name, GST and contact details',
                          onTap: () =>
                              context.goNamed(RouteNames.companyDetails),
                        ),
                        _SettingsOption(
                          icon: Icons.verified_user_outlined,
                          title: 'Privacy policy',
                          subtitle: 'Data storage and app privacy details',
                          onTap: () =>
                              context.goNamed(RouteNames.privacyPolicy),
                        ),
                      ],
                    ),
                    _SettingsSection(
                      title: 'Billing',
                      children: [
                        _SettingsOption(
                          icon: Icons.point_of_sale,
                          title: 'Grocery POS billing',
                          subtitle: 'Create bills, add products and print',
                          onTap: () => context.goNamed(RouteNames.billing),
                        ),
                        _SettingsOption(
                          icon: Icons.print_outlined,
                          title: 'Printer settings',
                          subtitle: 'Bluetooth, USB and WiFi thermal printers',
                          onTap: () =>
                              context.goNamed(RouteNames.printerSettings),
                        ),
                        _SettingsOption(
                          icon: Icons.credit_card,
                          title: 'Payment gateway',
                          subtitle:
                              'Hosted card checkout URL and UPI merchant ID',
                          onTap: () => _showPaymentGatewayDialog(context),
                        ),
                        _SettingsOption(
                          icon: Icons.receipt_long_outlined,
                          title: 'Invoice preferences',
                          subtitle: 'GST invoice format and sample print',
                          onTap: () => context.goNamed(
                            RouteNames.dashboard,
                            queryParameters: {'tab': '1'},
                          ),
                        ),
                      ],
                    ),
                    _SettingsSection(
                      title: 'Display',
                      children: [
                        BlocBuilder<ThemeCubit, ThemeMode>(
                          builder: (context, themeMode) {
                            final dark = themeMode == ThemeMode.dark;
                            return _SettingsOption(
                              icon: dark
                                  ? Icons.dark_mode_outlined
                                  : Icons.light_mode_outlined,
                              title: 'Dark mode',
                              subtitle: dark
                                  ? 'Dark colors are active'
                                  : 'Light colors are active',
                              trailing: Switch(
                                value: dark,
                                onChanged: (_) =>
                                    context.read<ThemeCubit>().toggleTheme(),
                              ),
                              onTap: () =>
                                  context.read<ThemeCubit>().toggleTheme(),
                            );
                          },
                        ),
                        _SettingsOption(
                          icon: Icons.dashboard_customize_outlined,
                          title: 'Dashboard modules',
                          subtitle: 'Open dashboard, customers and inventory',
                          onTap: () => context.goNamed(RouteNames.dashboard),
                        ),
                      ],
                    ),
                    _SettingsSection(
                      title: 'Data',
                      children: [
                        _SettingsOption(
                          icon: Icons.sync_outlined,
                          title: 'Sync status',
                          subtitle: 'Local SQLite records and pending sync',
                          badge: 'Local',
                          onTap: () {},
                        ),
                        _SettingsOption(
                          icon: Icons.backup_outlined,
                          title: 'Backup and restore',
                          subtitle: 'Export billing data for safekeeping',
                          onTap: () {},
                        ),
                      ],
                    ),
                    if (state.status == SettingsStatus.loading)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (state.items.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _SettingsSection(
                        title: 'Saved values',
                        children: state.items
                            .map(
                              (item) => _SettingsOption(
                                icon: Icons.tune_outlined,
                                title: item.settingKey,
                                subtitle: item.settingValue,
                                onTap: () {},
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showPaymentGatewayDialog(BuildContext context) async {
    final repository = SettingsRepository();
    final checkout = await repository.getByKey(
      PaymentService.cardCheckoutUrlKey,
    );
    final upi = await repository.getByKey(PaymentService.upiIdKey);
    if (!context.mounted) return;
    final checkoutController = TextEditingController(
      text: checkout?.settingValue ?? '',
    );
    final upiController = TextEditingController(text: upi?.settingValue ?? '');
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Payment gateway'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: checkoutController,
                  decoration: const InputDecoration(
                    labelText: 'Hosted card checkout URL',
                    hintText:
                        'https://gateway.example/pay?amount={amount}&order={billNumber}',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: upiController,
                  decoration: const InputDecoration(
                    labelText: 'UPI merchant ID',
                    hintText: 'merchant@upi',
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Card number, expiry and CVC must be collected by your payment gateway checkout page, not stored inside this app.',
                  style: TextStyle(fontSize: 12, height: 1.35),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                await repository.upsertValue(
                  PaymentService.cardCheckoutUrlKey,
                  checkoutController.text.trim(),
                );
                await repository.upsertValue(
                  PaymentService.upiIdKey,
                  upiController.text.trim(),
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment settings saved.')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    checkoutController.dispose();
    upiController.dispose();
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.onEdit});

  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final mobile = Responsive.isMobile(context);
    return BillCard(
      padding: EdgeInsets.all(mobile ? 16 : 20),
      child: Row(
        children: [
          CircleAvatar(
            radius: mobile ? 24 : 28,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            child: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings & privacy',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: billPrimaryText(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage app modules, billing tools and device preferences.',
                  style: TextStyle(color: billSecondaryText(context)),
                ),
              ],
            ),
          ),
          IconButton.outlined(
            tooltip: 'Edit settings',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Text(
              title,
              style: TextStyle(
                color: billSecondaryText(context),
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ),
          BillCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i != children.length - 1)
                    Divider(height: 1, color: billLine(context)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsOption extends StatelessWidget {
  const _SettingsOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final mobile = Responsive.isMobile(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: mobile ? 12 : 16,
          vertical: mobile ? 12 : 14,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: billSurfaceAlt(context),
                borderRadius: BorderRadius.circular(21),
              ),
              child: Icon(icon, color: billPrimaryText(context), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: billPrimaryText(context),
                            fontSize: mobile ? 15 : 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        StatusPill(
                          text: badge!,
                          foreground: Theme.of(context).colorScheme.primary,
                          background: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: .12),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: billSecondaryText(context),
                      fontSize: mobile ? 12 : 13,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing ??
                Icon(
                  Icons.chevron_right,
                  color: billSecondaryText(context),
                  size: 22,
                ),
          ],
        ),
      ),
    );
  }
}
