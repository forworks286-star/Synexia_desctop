import 'package:flutter/material.dart';
import 'colors.dart';

class AppColorsExt extends ThemeExtension<AppColorsExt> {
  final Color bg;
  final Color surface;
  final Color card;
  final Color cardAlt;
  final Color border;
  final Color sidebar;
  final Color text;
  final Color textMuted;
  final Color hover;
  final Color primary;
  final Color primaryLight;
  final Color secondary;
  final Color accent;
  final Color success;
  final Color successSoft;
  final Color danger;
  final Color dangerSoft;
  final Color warning;
  final Color warningSoft;
  final Color info;
  final Color infoSoft;
  final Color gradientTop;
  final Color gradientBottom;

  const AppColorsExt({
    required this.bg,
    required this.surface,
    required this.card,
    required this.cardAlt,
    required this.border,
    required this.sidebar,
    required this.text,
    required this.textMuted,
    required this.hover,
    required this.primary,
    required this.primaryLight,
    required this.secondary,
    required this.accent,
    required this.success,
    required this.successSoft,
    required this.danger,
    required this.dangerSoft,
    required this.warning,
    required this.warningSoft,
    required this.info,
    required this.infoSoft,
    required this.gradientTop,
    required this.gradientBottom,
  });

  static const dark = AppColorsExt(
    bg: AppPalette.darkBg,
    surface: AppPalette.darkSurface,
    card: AppPalette.darkCard,
    cardAlt: AppPalette.darkCardAlt,
    border: AppPalette.darkBorder,
    sidebar: AppPalette.darkSidebar,
    text: AppPalette.darkText,
    textMuted: AppPalette.darkTextMuted,
    hover: AppPalette.darkHover,
    primary: AppPalette.primary,
    primaryLight: AppPalette.primaryLight,
    secondary: AppPalette.secondary,
    accent: AppPalette.accent,
    success: AppPalette.success,
    successSoft: AppPalette.successSoft,
    danger: AppPalette.danger,
    dangerSoft: AppPalette.dangerSoft,
    warning: AppPalette.warning,
    warningSoft: AppPalette.warningSoft,
    info: AppPalette.info,
    infoSoft: AppPalette.infoSoft,
    gradientTop: AppPalette.darkGradientTop,
    gradientBottom: AppPalette.darkGradientBottom,
  );

  static const light = AppColorsExt(
    bg: AppPalette.lightBg,
    surface: AppPalette.lightSurface,
    card: AppPalette.lightCard,
    cardAlt: AppPalette.lightSurface,
    border: AppPalette.lightBorder,
    sidebar: AppPalette.lightSidebar,
    text: AppPalette.lightText,
    textMuted: AppPalette.lightTextMuted,
    hover: AppPalette.lightHover,
    primary: AppPalette.primary,
    primaryLight: AppPalette.primaryLight,
    secondary: AppPalette.secondary,
    accent: AppPalette.accent,
    success: AppPalette.success,
    successSoft: Color(0xFFDCFCE7),
    danger: AppPalette.danger,
    dangerSoft: Color(0xFFFEE2E2),
    warning: AppPalette.warning,
    warningSoft: Color(0xFFFEF3C7),
    info: AppPalette.info,
    infoSoft: Color(0xFFE0F2FE),
    gradientTop: AppPalette.lightGradientTop,
    gradientBottom: AppPalette.lightGradientBottom,
  );

  @override
  AppColorsExt copyWith({
    Color? bg, Color? surface, Color? card, Color? cardAlt, Color? border, Color? sidebar,
    Color? text, Color? textMuted, Color? hover, Color? primary, Color? primaryLight,
    Color? secondary, Color? accent, Color? success, Color? successSoft, Color? danger,
    Color? dangerSoft, Color? warning, Color? warningSoft, Color? info, Color? infoSoft,
    Color? gradientTop, Color? gradientBottom,
  }) {
    return AppColorsExt(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      card: card ?? this.card,
      cardAlt: cardAlt ?? this.cardAlt,
      border: border ?? this.border,
      sidebar: sidebar ?? this.sidebar,
      text: text ?? this.text,
      textMuted: textMuted ?? this.textMuted,
      hover: hover ?? this.hover,
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      success: success ?? this.success,
      successSoft: successSoft ?? this.successSoft,
      danger: danger ?? this.danger,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      warning: warning ?? this.warning,
      warningSoft: warningSoft ?? this.warningSoft,
      info: info ?? this.info,
      infoSoft: infoSoft ?? this.infoSoft,
      gradientTop: gradientTop ?? this.gradientTop,
      gradientBottom: gradientBottom ?? this.gradientBottom,
    );
  }

  @override
  AppColorsExt lerp(ThemeExtension<AppColorsExt>? other, double t) {
    if (other is! AppColorsExt) return this;
    return AppColorsExt(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardAlt: Color.lerp(cardAlt, other.cardAlt, t)!,
      border: Color.lerp(border, other.border, t)!,
      sidebar: Color.lerp(sidebar, other.sidebar, t)!,
      text: Color.lerp(text, other.text, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      hover: Color.lerp(hover, other.hover, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      success: Color.lerp(success, other.success, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoSoft: Color.lerp(infoSoft, other.infoSoft, t)!,
      gradientTop: Color.lerp(gradientTop, other.gradientTop, t)!,
      gradientBottom: Color.lerp(gradientBottom, other.gradientBottom, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColorsExt get colors => Theme.of(this).extension<AppColorsExt>()!;
}