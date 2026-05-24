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
  static const _primary = Color(0xFF145A32);
  static const _primaryContainer = Color(0xFF0B3D2E);
  static const _financeGold = Color(0xFFF4C430);
  static const _lightBackground = Color(0xFFF7F8F1);
  static const _lightPanel = Colors.white;
  static const _darkBackground = Color(0xFF0B100D);
  static const _darkPanel = Color(0xFF141B17);

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
      dividerColor: const Color(0xFFC9D5C7),
      fontFamily: 'Inter',
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFF0F4EC),
        hintStyle: TextStyle(color: Color(0xFF5F665D)),
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
      seedColor: _financeGold,
      brightness: Brightness.dark,
      primary: _financeGold,
      surface: _darkPanel,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _darkBackground,
      cardColor: _darkPanel,
      dividerColor: const Color(0xFF334137),
      fontFamily: 'Inter',
      textTheme: ThemeData.dark().textTheme.apply(
            bodyColor: const Color(0xFFE8F0E6),
            displayColor: const Color(0xFFFFF8DC),
          ),
      iconTheme: const IconThemeData(color: Color(0xFFE8F0E6)),
      popupMenuTheme: const PopupMenuThemeData(
        color: Color(0xFF141B17),
        textStyle: TextStyle(color: Color(0xFFE8F0E6)),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Color(0xFF141B17),
        titleTextStyle: TextStyle(
          color: Color(0xFFFFF8DC),
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
        contentTextStyle: TextStyle(color: Color(0xFFE8F0E6)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1D261F),
        labelStyle: const TextStyle(color: Color(0xFFBECAB9)),
        helperStyle: const TextStyle(color: Color(0xFFBECAB9)),
        hintStyle: const TextStyle(color: Color(0xFFBECAB9)),
        prefixIconColor: const Color(0xFFBECAB9),
        suffixIconColor: const Color(0xFFBECAB9),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF334137)),
          borderRadius: BorderRadius.circular(4),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF334137)),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      dataTableTheme: const DataTableThemeData(
        dataTextStyle: TextStyle(color: Color(0xFFE8F0E6)),
        headingTextStyle: TextStyle(
          color: Color(0xFFFFF8DC),
          fontWeight: FontWeight.w800,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _financeGold,
          foregroundColor: _darkBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }
}
