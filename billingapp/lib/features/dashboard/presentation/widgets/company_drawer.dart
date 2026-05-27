import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';

class CompanyDrawer extends StatelessWidget {
  const CompanyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.black,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    child: Text(
                      'D',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  SizedBox(height: 14),
                  Text(
                    AppConstants.companyName,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _DrawerTile(
              icon: Icons.dashboard_outlined,
              label: 'Dashboard',
              onTap: () => _goDashboardTab(context, 0),
            ),
            _DrawerTile(
              icon: Icons.receipt_long_outlined,
              label: 'Invoices',
              onTap: () => _goDashboardTab(context, 1),
            ),
            _DrawerTile(
              icon: Icons.people_outline,
              label: 'Customers',
              onTap: () => _goDashboardTab(context, 2),
            ),
            _DrawerTile(
              icon: Icons.inventory_2_outlined,
              label: 'Inventory',
              onTap: () => _goDashboardTab(context, 3),
            ),
            const Divider(height: 20),
            _DrawerTile(
              icon: Icons.point_of_sale,
              label: 'Grocery POS Billing',
              onTap: () => context.goNamed(RouteNames.billing),
            ),
            _DrawerTile(
              icon: Icons.print_outlined,
              label: 'Printer Settings',
              onTap: () => context.goNamed(RouteNames.printerSettings),
            ),
            const Divider(height: 20),
            _DrawerTile(
              icon: Icons.business_outlined,
              label: 'Company Details',
              onTap: () => context.goNamed(RouteNames.companyDetails),
            ),
            _DrawerTile(
              icon: Icons.privacy_tip_outlined,
              label: 'Privacy Policy',
              onTap: () => context.goNamed(RouteNames.privacyPolicy),
            ),
            _DrawerTile(
              icon: Icons.settings_outlined,
              label: 'App Settings',
              onTap: () => context.goNamed(RouteNames.appSettings),
            ),
          ],
        ),
      ),
    );
  }

  void _goDashboardTab(BuildContext context, int tab) {
    context.goNamed(
      RouteNames.dashboard,
      queryParameters: {'tab': tab.toString()},
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(leading: Icon(icon), title: Text(label), onTap: onTap);
  }
}
