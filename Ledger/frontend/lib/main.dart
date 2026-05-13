import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'routes.dart';

void main() {
  runApp(const BalanceSheetLedgerApp());
}

class BalanceSheetLedgerApp extends StatelessWidget {
  const BalanceSheetLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeController.themeMode,
      builder: (context, themeMode, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Balance Sheet Ledger',
          routerConfig: appRouter,
          themeMode: themeMode,
          theme: AppThemes.light,
          darkTheme: AppThemes.dark,
        );
      },
    );
  }
}
