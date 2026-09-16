import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static List<BoxShadow> card(bool isDark) {
    return [
      BoxShadow(
        color: isDark ? Colors.black.withOpacity(0.35) : const Color(0xFF0F172A).withOpacity(0.06),
        blurRadius: 18,
        offset: const Offset(0, 6),
      ),
    ];
  }

  static List<BoxShadow> elevated(bool isDark) {
    return [
      BoxShadow(
        color: isDark ? Colors.black.withOpacity(0.45) : const Color(0xFF0F172A).withOpacity(0.10),
        blurRadius: 28,
        offset: const Offset(0, 10),
      ),
    ];
  }

  static const List<BoxShadow> none = [];
}