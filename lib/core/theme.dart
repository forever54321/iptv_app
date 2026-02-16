import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: Colors.deepPurple,
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardTheme: const CardThemeData(
        color: Color(0xFF1E1E2E),
        elevation: 2,
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1A2E),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: const Color(0xFF2A2A3E),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Color(0xFF1A1A2E),
      ),
    );
  }
}
