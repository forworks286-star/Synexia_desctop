import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primary       = Color(0xFF8BE9FD);
  static const secondary     = Color(0xFFBD93F9);
  static const success       = Color(0xFF50FA7B);
  static const danger        = Color(0xFFFF5555);
  static const warning       = Color(0xFFFFB86C);

  static const darkBg        = Color(0xFF282A36);
  static const darkSurface   = Color(0xFF44475A);
  static const darkCard      = Color(0xFF2A3144);
  static const darkBorder    = Color(0xFF6272A4);
  static const darkText      = Color(0xFFF8F8F2);
  static const darkTextMuted = Color(0xFF6272A4);
  static const darkSidebar   = Color(0xFF21222C);

  static const lightBg        = Color(0xFFF8FAFC);
  static const lightSurface   = Color(0xFFFFFFFF);
  static const lightCard      = Color(0xFFFFFFFF);
  static const lightBorder    = Color(0xFFE2E8F0);
  static const lightText      = Color(0xFF0F172A);
  static const lightTextMuted = Color(0xFF64748B);
  static const lightSidebar   = Color(0xFF282A36);
}

class AppTheme {
  AppTheme._();

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.darkSurface,
        error: AppColors.danger,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.darkBorder, space: 1),
      textTheme: _buildTextTheme(AppColors.darkText, AppColors.darkTextMuted),
      elevatedButtonTheme: _buildButtonTheme(),
      inputDecorationTheme: _buildInputTheme(AppColors.darkCard, AppColors.darkBorder, AppColors.darkTextMuted),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(AppColors.darkSurface),
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) return AppColors.darkBorder.withOpacity(0.3);
          return Colors.transparent;
        }),
        dividerThickness: 0.5,
        headingTextStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.darkTextMuted, letterSpacing: 0.08),
        dataTextStyle: const TextStyle(fontSize: 13, color: AppColors.darkText),
      ),
    );
  }

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.lightSurface,
        error: AppColors.danger,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.lightBorder, space: 1),
      textTheme: _buildTextTheme(AppColors.lightText, AppColors.lightTextMuted),
      elevatedButtonTheme: _buildButtonTheme(),
      inputDecorationTheme: _buildInputTheme(AppColors.lightSurface, AppColors.lightBorder, AppColors.lightTextMuted),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(AppColors.lightBg),
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) return AppColors.lightBorder.withOpacity(0.5);
          return Colors.transparent;
        }),
        dividerThickness: 0.5,
        headingTextStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.lightTextMuted, letterSpacing: 0.08),
        dataTextStyle: TextStyle(fontSize: 13, color: AppColors.lightText),
      ),
    );
  }

  static TextTheme _buildTextTheme(Color primary, Color muted) {
    return TextTheme(
      displayLarge: TextStyle(fontFamily: 'Syne', fontSize: 28, fontWeight: FontWeight.w800, color: primary),
      displayMedium: TextStyle(fontFamily: 'Syne', fontSize: 22, fontWeight: FontWeight.w700, color: primary),
      titleLarge: TextStyle(fontFamily: 'Syne', fontSize: 18, fontWeight: FontWeight.w700, color: primary),
      titleMedium: TextStyle(fontFamily: 'Syne', fontSize: 14, fontWeight: FontWeight.w600, color: primary),
      bodyLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: primary),
      bodyMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: muted),
      labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: muted, letterSpacing: 0.1),
    );
  }

  static ElevatedButtonThemeData _buildButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.darkBg,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontFamily: 'Syne', fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }

  static InputDecorationTheme _buildInputTheme(Color fill, Color border, Color hint) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      hintStyle: TextStyle(color: hint, fontSize: 13),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      isDense: true,
    );
  }
}
