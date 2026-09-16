import 'package:flutter/material.dart';
import '../design/colors.dart';
import '../design/typography.dart';
import '../design/radii.dart';
import '../design/theme_extension.dart';

// Palette statique conservée pour compatibilité arrière avec les écrans
// non encore migrés. Pour tout nouveau code, utiliser context.colors.
class AppColors {
  AppColors._();

  static const primary       = AppPalette.primary;
  static const primaryLight  = AppPalette.primaryLight;
  static const primaryDark   = AppPalette.primaryDark;
  static const secondary     = AppPalette.secondary;

  static const success       = AppPalette.success;
  static const successLight  = AppPalette.successSoft;
  static const danger        = AppPalette.danger;
  static const dangerLight   = AppPalette.dangerSoft;
  static const warning       = AppPalette.warning;
  static const warningLight  = AppPalette.warningSoft;
  static const info          = AppPalette.info;
  static const infoLight     = AppPalette.infoSoft;

  static const darkBg        = AppPalette.darkBg;
  static const darkSurface   = AppPalette.darkSurface;
  static const darkCard      = AppPalette.darkCard;
  static const darkBorder    = AppPalette.darkBorder;
  static const darkText      = AppPalette.darkText;
  static const darkTextMuted = AppPalette.darkTextMuted;
  static const darkSidebar   = AppPalette.darkSidebar;

  static const lightBg        = AppPalette.lightBg;
  static const lightSurface   = AppPalette.lightSurface;
  static const lightCard      = AppPalette.lightCard;
  static const lightBorder    = AppPalette.lightBorder;
  static const lightText      = AppPalette.lightText;
  static const lightTextMuted = AppPalette.lightTextMuted;
  static const lightSidebar   = AppPalette.lightSidebar;
}

class AppTheme {
  AppTheme._();

  static ThemeData dark() => _build(isDark: true);
  static ThemeData light() => _build(isDark: false);

  static ThemeData _build({required bool isDark}) {
    final ext = isDark ? AppColorsExt.dark : AppColorsExt.light;

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: ext.bg,
      colorScheme: isDark
          ? ColorScheme.dark(primary: ext.primary, secondary: ext.secondary, surface: ext.surface, error: ext.danger)
          : ColorScheme.light(primary: ext.primary, secondary: ext.secondary, surface: ext.surface, error: ext.danger),
      extensions: [ext],
      cardTheme: CardThemeData(
        color: ext.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.rLg,
          side: BorderSide(color: ext.border, width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(color: ext.border, space: 1),
      textTheme: _buildTextTheme(ext.text, ext.textMuted),
      elevatedButtonTheme: _buildButtonTheme(ext),
      outlinedButtonTheme: _buildOutlinedButtonTheme(ext),
      inputDecorationTheme: _buildInputTheme(ext),
      snackBarTheme: _buildSnackBarTheme(ext),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(ext.surface),
        dataRowColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.hovered) ? ext.hover : Colors.transparent),
        dividerThickness: 0.5,
        headingTextStyle: TextStyle(fontSize: AppTypography.micro, fontWeight: FontWeight.w700, color: ext.textMuted, letterSpacing: 0.4),
        dataTextStyle: TextStyle(fontSize: AppTypography.bodySm, color: ext.text),
      ),
    );
  }

  static TextTheme _buildTextTheme(Color primary, Color muted) {
    return TextTheme(
      displayLarge:  TextStyle(fontFamily: AppTypography.fontDisplay, fontSize: AppTypography.display, fontWeight: FontWeight.w800, color: primary, letterSpacing: -0.6),
      displayMedium: TextStyle(fontFamily: AppTypography.fontDisplay, fontSize: AppTypography.h1, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.3),
      titleLarge:    TextStyle(fontFamily: AppTypography.fontDisplay, fontSize: AppTypography.h3, fontWeight: FontWeight.w700, color: primary),
      titleMedium:   TextStyle(fontFamily: AppTypography.fontDisplay, fontSize: AppTypography.bodySm, fontWeight: FontWeight.w600, color: primary),
      bodyLarge:     TextStyle(fontSize: AppTypography.body, fontWeight: FontWeight.w400, color: primary, height: 1.5),
      bodyMedium:    TextStyle(fontSize: AppTypography.caption, fontWeight: FontWeight.w400, color: muted, height: 1.5),
      labelSmall:    TextStyle(fontSize: AppTypography.micro, fontWeight: FontWeight.w600, color: muted, letterSpacing: 0.4),
    );
  }

  static ElevatedButtonThemeData _buildButtonTheme(AppColorsExt ext) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ext.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.rMd),
        textStyle: const TextStyle(fontFamily: AppTypography.fontDisplay, fontSize: AppTypography.bodySm, fontWeight: FontWeight.w600),
      ).copyWith(
        overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.08)),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme(AppColorsExt ext) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ext.text,
        side: BorderSide(color: ext.border),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.rMd),
        textStyle: const TextStyle(fontFamily: AppTypography.fontDisplay, fontSize: AppTypography.bodySm, fontWeight: FontWeight.w700),
      ),
    );
  }

  static InputDecorationTheme _buildInputTheme(AppColorsExt ext) {
    return InputDecorationTheme(
      filled: true,
      fillColor: ext.surface,
      hintStyle: TextStyle(color: ext.textMuted, fontSize: AppTypography.bodySm),
      border: OutlineInputBorder(borderRadius: AppRadii.rMd, borderSide: BorderSide(color: ext.border)),
      enabledBorder: OutlineInputBorder(borderRadius: AppRadii.rMd, borderSide: BorderSide(color: ext.border)),
      focusedBorder: OutlineInputBorder(borderRadius: AppRadii.rMd, borderSide: BorderSide(color: ext.primary, width: 1.6)),
      errorBorder: OutlineInputBorder(borderRadius: AppRadii.rMd, borderSide: BorderSide(color: ext.danger)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      isDense: true,
    );
  }

  static SnackBarThemeData _buildSnackBarTheme(AppColorsExt ext) {
    return SnackBarThemeData(
      backgroundColor: ext.cardAlt,
      contentTextStyle: TextStyle(color: ext.text, fontSize: AppTypography.bodySm, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: AppRadii.rMd, side: BorderSide(color: ext.border)),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    );
  }
}