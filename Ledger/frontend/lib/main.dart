import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_theme.dart';
import 'routes.dart';
import 'state/auth_cubit.dart';
import 'services/auth_session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await AuthSession.restore();
  } catch (e) {
    debugPrint('Auth restore failed: $e');
  }

  runApp(const BalanceSheetLedgerApp());
}

class BalanceSheetLedgerApp extends StatelessWidget {
  const BalanceSheetLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(),
      child: ValueListenableBuilder<ThemeMode>(
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
      ),
    );
  }
}
