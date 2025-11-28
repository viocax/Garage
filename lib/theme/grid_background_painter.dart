import 'package:flutter/material.dart';
import 'app_theme.dart';

// 網格背景繪製器（通用版本）
class GridBackgroundPainter extends CustomPainter {
  final double gridSize;
  final Color color;
  final double strokeWidth;

  GridBackgroundPainter({
    this.gridSize = 40.0,
    Color? color,
    this.strokeWidth = 1.0,
  }) : color = color ?? AppTheme.greyTransparent10;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;

    // 繪製垂直線
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // 繪製水平線
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(GridBackgroundPainter oldDelegate) => false;
}
