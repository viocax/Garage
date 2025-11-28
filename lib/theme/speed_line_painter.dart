import 'package:flutter/material.dart';
import 'app_theme.dart';

// 速度線繪製器
class SpeedLinesPainter extends CustomPainter {
  final double progress;

  SpeedLinesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // 6條速度線，不同位置和延遲
    _drawSpeedLine(canvas, 20, 20, 60, progress, 0);
    _drawSpeedLine(canvas, 40, 0, 80, progress, 0.2);
    _drawSpeedLine(canvas, 60, 30, 50, progress, 0.4);
    _drawSpeedLine(canvas, 20, size.width - 80, 60, progress, 0.1);
    _drawSpeedLine(canvas, 40, size.width - 80, 80, progress, 0.3);
    _drawSpeedLine(canvas, 60, size.width - 80, 50, progress, 0.5);
  }

  void _drawSpeedLine(
    Canvas canvas,
    double top,
    double left,
    double width,
    double progress,
    double delay,
  ) {
    final adjustedProgress = ((progress - delay) % 1.0).clamp(0.0, 1.0);
    final opacity = adjustedProgress < 0.5
        ? adjustedProgress * 2
        : (1 - adjustedProgress) * 2;
    final yOffset = adjustedProgress * 30;

    // 為每條線創建新的 Paint，使用漸變
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppTheme.accentColor.withValues(alpha: 0),
          AppTheme.accentColor.withValues(alpha: 0.3 * opacity),
          AppTheme.accentColor.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(left, top + yOffset, width, 1))
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(left, top + yOffset),
      Offset(left + width, top + yOffset),
      paint,
    );
  }

  @override
  bool shouldRepaint(SpeedLinesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
