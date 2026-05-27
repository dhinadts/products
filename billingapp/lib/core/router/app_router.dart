import 'package:go_router/go_router.dart';

import '../../features/company/presentation/pages/company_details_page.dart';
import '../../features/billing/presentation/pages/billing_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/dashboard/presentation/pages/splash_page.dart';
import '../../features/privacy/presentation/pages/privacy_policy_page.dart';
import '../../features/settings/presentation/pages/app_settings_page.dart';
import '../../features/settings/presentation/pages/printer_settings_page.dart';
import 'route_names.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/dashboard',
        name: RouteNames.dashboard,
        builder: (context, state) {
          final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
          return DashboardPage(initialIndex: tab.clamp(0, 3));
        },
      ),
      GoRoute(
        path: '/privacy-policy',
        name: RouteNames.privacyPolicy,
        builder: (context, state) => const PrivacyPolicyPage(),
      ),
      GoRoute(
        path: '/app-settings',
        name: RouteNames.appSettings,
        builder: (context, state) => const AppSettingsPage(),
      ),
      GoRoute(
        path: '/company-details',
        name: RouteNames.companyDetails,
        builder: (context, state) => const CompanyDetailsPage(),
      ),
      GoRoute(
        path: '/billing',
        name: RouteNames.billing,
        builder: (context, state) => const BillingPage(),
      ),
      GoRoute(
        path: '/printer-settings',
        name: RouteNames.printerSettings,
        builder: (context, state) => const PrinterSettingsPage(),
      ),
    ],
  );
}
