import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const primary       = Color(0xFF2563EB); // Blue-600 — professional
  static const primaryLight  = Color(0xFF3B82F6);
  static const primaryDark   = Color(0xFF1D4ED8);
  static const secondary     = Color(0xFF7C3AED); // Violet-600

  // Semantic
  static const success       = Color(0xFF16A34A);
  static const successLight  = Color(0xFFDCFCE7);
  static const danger        = Color(0xFFDC2626);
  static const dangerLight   = Color(0xFFFEE2E2);
  static const warning       = Color(0xFFD97706);
  static const warningLight  = Color(0xFFFEF3C7);
  static const info          = Color(0xFF0891B2);
  static const infoLight     = Color(0xFFE0F2FE);

  // Dark theme
  static const darkBg        = Color(0xFF0F1117);
  static const darkSurface   = Color(0xFF161B27);
  static const darkCard      = Color(0xFF1C2333);
  static const darkBorder    = Color(0xFF2A3347);
  static const darkText      = Color(0xFFF1F5F9);
  static const darkTextMuted = Color(0xFF64748B);
  static const darkSidebar   = Color(0xFF111827);

  // Light theme
  static const lightBg        = Color(0xFFF8FAFC);
  static const lightSurface   = Color(0xFFFFFFFF);
  static const lightCard      = Color(0xFFFFFFFF);
  static const lightBorder    = Color(0xFFE2E8F0);
  static const lightText      = Color(0xFF0F172A);
  static const lightTextMuted = Color(0xFF64748B);
  static const lightSidebar   = Color(0xFF0F172A);
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
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.darkBorder, space: 1),
      textTheme: _buildTextTheme(AppColors.darkText, AppColors.darkTextMuted),
      elevatedButtonTheme: _buildButtonTheme(),
      inputDecorationTheme: _buildInputTheme(AppColors.darkCard, AppColors.darkBorder, AppColors.darkTextMuted),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(AppColors.darkSurface),
        dataRowColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.hovered) ? AppColors.darkBorder.withOpacity(0.2) : Colors.transparent),
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
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.lightBorder, space: 1),
      textTheme: _buildTextTheme(AppColors.lightText, AppColors.lightTextMuted),
      elevatedButtonTheme: _buildButtonTheme(),
      inputDecorationTheme: _buildInputTheme(AppColors.lightSurface, AppColors.lightBorder, AppColors.lightTextMuted),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(AppColors.lightBg),
        dataRowColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.hovered) ? AppColors.lightBorder.withOpacity(0.5) : Colors.transparent),
        dividerThickness: 0.5,
        headingTextStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.lightTextMuted, letterSpacing: 0.08),
        dataTextStyle: TextStyle(fontSize: 13, color: AppColors.lightText),
      ),
    );
  }

  static TextTheme _buildTextTheme(Color primary, Color muted) {
    return TextTheme(
      displayLarge:  TextStyle(fontFamily: 'Syne', fontSize: 26, fontWeight: FontWeight.w800, color: primary, letterSpacing: -0.5),
      displayMedium: TextStyle(fontFamily: 'Syne', fontSize: 20, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.3),
      titleLarge:    TextStyle(fontFamily: 'Syne', fontSize: 16, fontWeight: FontWeight.w700, color: primary),
      titleMedium:   TextStyle(fontFamily: 'Syne', fontSize: 13, fontWeight: FontWeight.w600, color: primary),
      bodyLarge:     TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: primary, height: 1.5),
      bodyMedium:    TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: muted, height: 1.5),
      labelSmall:    TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: muted, letterSpacing: 0.12),
    );
  }

  static ElevatedButtonThemeData _buildButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        textStyle: const TextStyle(fontFamily: 'Syne', fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }

  static InputDecorationTheme _buildInputTheme(Color fill, Color border, Color hint) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      hintStyle: TextStyle(color: hint, fontSize: 13),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: BorderSide(color: border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: BorderSide(color: border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: const BorderSide(color: AppColors.danger)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      isDense: true,
    );
  }
}