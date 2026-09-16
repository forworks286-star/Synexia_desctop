import 'package:flutter/material.dart';

class CornerFlowLines extends StatelessWidget {
  final Color color;
  final bool flipped;
  final double width;
  final double height;

  const CornerFlowLines({
    super.key,
    required this.color,
    this.flipped = false,
    this.width = 260,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    final child = CustomPaint(
      size: Size(width, height),
      painter: _FlowLinesPainter(color: color),
    );

    if (!flipped) return child;

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(3.1416),
      child: child,
    );
  }
}

class _FlowLinesPainter extends CustomPainter {
  final Color color;
  const _FlowLinesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    void drawCurve(double offsetY, double opacity) {
      paint.color = color.withOpacity(opacity);
      final path = Path()
        ..moveTo(0, h * offsetY)
        ..cubicTo(
          w * 0.25, h * (offsetY - 0.22),
          w * 0.55, h * (offsetY + 0.18),
          w, h * (offsetY - 0.10),
        );
      canvas.drawPath(path, paint);
    }

    drawCurve(0.85, 0.18);
    drawCurve(0.65, 0.12);
    drawCurve(0.45, 0.07);
  }

  @override
  bool shouldRepaint(covariant _FlowLinesPainter oldDelegate) => oldDelegate.color != color;
}