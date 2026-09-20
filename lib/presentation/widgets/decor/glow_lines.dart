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

    final glowBoost = isDark ? 1.3 : 1.8;

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
        startX + w * 0.22, h * (baseY - amp),
        startX + w * 0.46, h * (baseY + amp * 0.8),
        startX + w * 0.66, h * (baseY - amp * 0.5),
      );
      path.cubicTo(
        startX + w * 0.84, h * (baseY - amp * 1.4),
        startX + w * 0.96, h * (baseY + amp * 0.5),
        w + 40, h * (baseY - amp * 0.15),
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

    ribbon(startX: -30,        baseY: 0.10, amp: 0.09, c: color,          coreOpacity: 0.34, glowOpacity: 0.14, coreWidth: 1.6, glowWidth: 11, glowBlur: 13);
    ribbon(startX: -10,        baseY: 0.24, amp: 0.11, c: color,          coreOpacity: 0.28, glowOpacity: 0.12, coreWidth: 1.4, glowWidth: 13, glowBlur: 15);
    ribbon(startX: -40,        baseY: 0.40, amp: 0.10, c: secondaryColor, coreOpacity: 0.26, glowOpacity: 0.11, coreWidth: 1.4, glowWidth: 12, glowBlur: 14);
    ribbon(startX: -15,        baseY: 0.56, amp: 0.12, c: color,          coreOpacity: 0.30, glowOpacity: 0.13, coreWidth: 1.5, glowWidth: 14, glowBlur: 16);
    ribbon(startX: -35,        baseY: 0.72, amp: 0.11, c: color,          coreOpacity: 0.26, glowOpacity: 0.11, coreWidth: 1.3, glowWidth: 12, glowBlur: 14);
    ribbon(startX: -5,         baseY: 0.88, amp: 0.09, c: secondaryColor, coreOpacity: 0.22, glowOpacity: 0.09, coreWidth: 1.2, glowWidth: 11, glowBlur: 13);
  }

  @override
  bool shouldRepaint(covariant _GlowRibbonsPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.secondaryColor != secondaryColor || oldDelegate.isDark != isDark;
}