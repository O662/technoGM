import 'dart:math';
import 'package:flutter/material.dart';

/// Small progress ring shown next to the big "today" number on the
/// steps/calories/active-minutes/water detail screens.
class MiniRing extends StatelessWidget {
  final double progress;
  final Color color;
  final double size;

  const MiniRing({
    super.key,
    required this.progress,
    required this.color,
    this.size = 72,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MiniRingPainter(
          progress: progress,
          color: color,
        ),
      ),
    );
  }
}

class _MiniRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _MiniRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 5;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9,
    );

    if (progress <= 0) return;

    final sweep = (progress * 2 * pi).clamp(0.0, 2 * pi);
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(
      rect,
      -pi / 2,
      sweep,
      false,
      Paint()
        ..color = color.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawArc(
      rect,
      -pi / 2,
      sweep,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_MiniRingPainter old) =>
      old.progress != progress || old.color != color;
}
