import 'dart:ui';
import 'package:flutter/material.dart';

class GlowFlowLines extends StatelessWidget {
  final Color color;
  final Color secondaryColor;
  final bool isDark;

  const GlowFlowLines({
    super.key,
    required this.color,
    required this.secondaryColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _GlowRibbonsPainter(color: color, secondaryColor: secondaryColor, isDark: isDark),
        );
      },
    );
  }
}

class _GlowRibbonsPainter extends CustomPainter {
  final Color color;
  final Color secondaryColor;
  final bool isDark;

  const _GlowRibbonsPainter({required this.color, required this.secondaryColor, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final glowBoost = isDark ? 1.0 : 1.6;

    void ribbon({
      required double startX,
      required double baseY,
      required double amp,
      required Color c,
      required double coreOpacity,
      required double glowOpacity,
      required double coreWidth,
      required double glowWidth,
      required double glowBlur,
    }) {
      final path = Path()..moveTo(startX, h * baseY);
      path.cubicTo(
        startX + w * 0.20, h * (baseY - amp),
        startX + w * 0.42, h * (baseY + amp * 0.8),
        startX + w * 0.62, h * (baseY - amp * 0.5),
      );
      path.cubicTo(
        startX + w * 0.80, h * (baseY - amp * 1.4),
        startX + w * 0.94, h * (baseY + amp * 0.5),
        startX + w * 1.05, h * (baseY - amp * 0.15),
      );

      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = glowWidth
        ..strokeCap = StrokeCap.round
        ..color = c.withOpacity((glowOpacity * glowBoost).clamp(0.0, 1.0))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowBlur);
      canvas.drawPath(path, glowPaint);

      final corePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = coreWidth
        ..strokeCap = StrokeCap.round
        ..color = c.withOpacity((coreOpacity * glowBoost).clamp(0.0, 1.0));
      canvas.drawPath(path, corePaint);
    }

    ribbon(startX: -w * 0.15, baseY: 0.14, amp: 0.10, c: color, coreOpacity: 0.30, glowOpacity: 0.10, coreWidth: 1.4, glowWidth: 10, glowBlur: 12);
    ribbon(startX: -w * 0.25, baseY: 0.30, amp: 0.13, c: color, coreOpacity: 0.24, glowOpacity: 0.09, coreWidth: 1.2, glowWidth: 12, glowBlur: 14);
    ribbon(startX: -w * 0.05, baseY: 0.50, amp: 0.11, c: secondaryColor, coreOpacity: 0.20, glowOpacity: 0.08, coreWidth: 1.2, glowWidth: 10, glowBlur: 12);
    ribbon(startX: -w * 0.30, baseY: 0.68, amp: 0.15, c: color, coreOpacity: 0.26, glowOpacity: 0.10, coreWidth: 1.3, glowWidth: 13, glowBlur: 15);
    ribbon(startX: -w * 0.10, baseY: 0.85, amp: 0.12, c: color, coreOpacity: 0.22, glowOpacity: 0.09, coreWidth: 1.2, glowWidth: 11, glowBlur: 13);
    ribbon(startX: -w * 0.20, baseY: 0.98, amp: 0.09, c: secondaryColor, coreOpacity: 0.18, glowOpacity: 0.07, coreWidth: 1.0, glowWidth: 9, glowBlur: 11);
  }

  @override
  bool shouldRepaint(covariant _GlowRibbonsPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.secondaryColor != secondaryColor || oldDelegate.isDark != isDark;
}