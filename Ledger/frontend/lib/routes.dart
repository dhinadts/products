import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/login_screen.dart';
import 'pages/screens.dart';
import 'services/auth_session.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  redirect: (BuildContext context, GoRouterState state) {
    final path = state.location;
    final isAuthRoute = path == '/' || path == '/login' || path == '/signup';

    final isLoggedIn = AuthSession.isAuthenticated;

    if (!isLoggedIn && !isAuthRoute) {
      return '/login';
    }

    if (isLoggedIn && isAuthRoute) {
      return '/dashboard';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/ledger',
      builder: (context, state) => const LedgerScreen(),
    ),
    GoRoute(
      path: '/balance-sheet',
      builder: (context, state) => const BalanceSheetScreen(),
    ),
    GoRoute(
      path: '/reports',
      builder: (context, state) => const ReportsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/help',
      builder: (context, state) => const HelpScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/screen1',
      builder: (context, state) =>
          const ScreenPage(screenKey: 'screen1', title: 'Screen 1'),
    ),
    GoRoute(
      path: '/screen2',
      builder: (context, state) =>
          const ScreenPage(screenKey: 'screen2', title: 'Screen 2'),
    ),
    GoRoute(
      path: '/screen3',
      builder: (context, state) =>
          const ScreenPage(screenKey: 'screen3', title: 'Screen 3'),
    ),
    GoRoute(
      path: '/screen4',
      builder: (context, state) =>
          const ScreenPage(screenKey: 'screen4', title: 'Screen 4'),
    ),
  ],
);
