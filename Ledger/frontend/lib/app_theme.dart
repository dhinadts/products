import 'package:flutter/material.dart';

class AppThemeController {
  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  static void toggleTheme() {
    themeMode.value =
        themeMode.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

class AppThemes {
  static const _primary = Color(0xFF000666);
  static const _primaryContainer = Color(0xFF1A237E);
  static const _lightBackground = Color(0xFFFBF8FF);
  static const _lightPanel = Colors.white;
  static const _darkBackground = Color(0xFF0B1020);
  static const _darkPanel = Color(0xFF121A2C);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primary,
      brightness: Brightness.light,
      primary: _primary,
      surface: _lightPanel,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _lightBackground,
      cardColor: _lightPanel,
      dividerColor: const Color(0xFFC6C5D4),
      fontFamily: 'Inter',
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primaryContainer,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFBDC2FF),
      brightness: Brightness.dark,
      primary: const Color(0xFFBDC2FF),
      surface: _darkPanel,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _darkBackground,
      cardColor: _darkPanel,
      dividerColor: const Color(0xFF334155),
      fontFamily: 'Inter',
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFBDC2FF),
          foregroundColor: _darkBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }
}
