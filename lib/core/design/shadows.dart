import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static List<BoxShadow> card(bool isDark) {
    return [
      BoxShadow(
        color: isDark ? Colors.black.withOpacity(0.5) : const Color(0xFF0F172A).withOpacity(0.08),
        blurRadius: 28,
        offset: const Offset(0, 10),
      ),
      if (isDark)
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
    ];
  }

  static List<BoxShadow> elevated(bool isDark) {
    return [
      BoxShadow(
        color: isDark ? Colors.black.withOpacity(0.55) : const Color(0xFF0F172A).withOpacity(0.14),
        blurRadius: 36,
        offset: const Offset(0, 14),
      ),
    ];
  }

  static List<BoxShadow> glow(Color color, {double opacity = 0.28}) {
    return [
      BoxShadow(color: color.withOpacity(opacity), blurRadius: 14, offset: const Offset(0, 4)),
    ];
  }

  static const List<BoxShadow> none = [];
}