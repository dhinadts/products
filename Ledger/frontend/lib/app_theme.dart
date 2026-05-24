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
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFF5F2FB),
        hintStyle: TextStyle(color: Color(0xFF5F6070)),
      ),
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
      textTheme: ThemeData.dark().textTheme.apply(
            bodyColor: const Color(0xFFE8ECF8),
            displayColor: const Color(0xFFF7F8FF),
          ),
      iconTheme: const IconThemeData(color: Color(0xFFE8ECF8)),
      popupMenuTheme: const PopupMenuThemeData(
        color: Color(0xFF121A2C),
        textStyle: TextStyle(color: Color(0xFFE8ECF8)),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Color(0xFF121A2C),
        titleTextStyle: TextStyle(
          color: Color(0xFFF7F8FF),
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
        contentTextStyle: TextStyle(color: Color(0xFFE8ECF8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A2338),
        labelStyle: const TextStyle(color: Color(0xFFB6C2D6)),
        helperStyle: const TextStyle(color: Color(0xFFB6C2D6)),
        hintStyle: const TextStyle(color: Color(0xFFB6C2D6)),
        prefixIconColor: const Color(0xFFB6C2D6),
        suffixIconColor: const Color(0xFFB6C2D6),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF334155)),
          borderRadius: BorderRadius.circular(4),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF334155)),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      dataTableTheme: const DataTableThemeData(
        dataTextStyle: TextStyle(color: Color(0xFFE8ECF8)),
        headingTextStyle: TextStyle(
          color: Color(0xFFF7F8FF),
          fontWeight: FontWeight.w800,
        ),
      ),
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
