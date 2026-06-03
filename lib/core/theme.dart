import 'package:flutter/material.dart';

class AppTheme {
  /// Builds a theme for the given [brightness] seeded by [accent].
  static ThemeData themeFor(Brightness brightness, Color accent) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorSchemeSeed: accent,
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F7),
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor:
            isDark ? const Color(0xFF1A1A2E) : accent.withValues(alpha: 0.12),
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor:
            isDark ? const Color(0xFF2A2A3E) : const Color(0xFFECECF1),
      ),
    );
  }

  /// Default dark theme (kept for backwards compatibility).
  static ThemeData get dark => themeFor(Brightness.dark, Colors.deepPurple);

  /// Default light theme.
  static ThemeData get light => themeFor(Brightness.light, Colors.deepPurple);
}
