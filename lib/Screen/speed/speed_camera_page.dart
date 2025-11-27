import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'car3d/car_3d_view.dart';
import 'car3d/bloc/car_3d_bloc.dart';
import 'bloc/speed_bloc.dart';
import 'bloc/speed_state.dart';

class SpeedCameraPage extends StatefulWidget {
  const SpeedCameraPage({super.key});

  @override
  State<SpeedCameraPage> createState() => _SpeedCameraPageState();
}

class _SpeedCameraPageState extends State<SpeedCameraPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _roadAnimationController;

  @override
  void initState() {
    super.initState();
    // 初始化道路動畫控制器（不自動播放）
    _roadAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5300),
    );
  }

  @override
  void dispose() {
    _roadAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => Car3DBloc()),
        BlocProvider(create: (context) => SpeedBloc()),
      ],
      child: BlocListener<SpeedBloc, SpeedState>(
        listener: (context, state) {
          // 監聽速度變化，更新道路動畫
          _roadAnimationController.duration = state.animationDuration;

          // 如果速度為 0，停止動畫
          if (state.speed == 0) {
            _roadAnimationController.stop();
          } else if (_roadAnimationController.isAnimating) {
            // 如果動畫正在運行，重新啟動以應用新速度
            _roadAnimationController.reset();
            _roadAnimationController.repeat();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Background Gradient
              _backgroundGradient(),
              SafeArea(
                child: Column(
                  children: [
                    // 1. Top Section: Map
                    Expanded(flex: 2, child: _topMap()),

                    // 2. Middle Section: Speedometer & Status
                    Expanded(
                      flex: 2,
                      child: BlocBuilder<SpeedBloc, SpeedState>(
                        builder: (context, state) {
                          return Speedometer(
                            speed: state.speed.toInt().toString(),
                            unit: 'km/h',
                            lowerSpeed: '110',
                            upperSpeed: '120',
                          );
                        },
                      ),
                    ),

                    // 3. Bottom Section: 3D Road & Car
                    Expanded(flex: 3, child: _roadPath()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topMap() {
    final textTheme = Theme.of(context).textTheme;
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent, // 顶部透明
            Colors.black, // 中间完全显示
            Colors.black, // 中间完全显示
            Colors.transparent, // 底部透明
          ],
          stops: const [0.0, 0.1, 0.9, 1.0], // 控制渐变位置
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn, // 透明度遮罩
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 5,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Map Grid Placeholder, 判斷地圖的載入
            CustomPaint(size: Size.infinite, painter: MapGridPainter()),

            // Navigation Info Overlay
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.turn_right, color: Colors.white, size: 32),
                    const SizedBox(height: 4),
                    Text(
                      '200 m',
                      style: textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roadPath() {
    final screenWidth = MediaQuery.of(context).size.width;
    final carWidth = screenWidth * 0.6 - 20;
    final carHeight = carWidth * 1.5;

    return AnimatedBuilder(
      animation: _roadAnimationController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Road Visualization with animation
            CustomPaint(
              size: Size.infinite,
              painter: RoadPainter(
                activeLaneColor: Colors.grey.withValues(alpha: 0.5),
                animationValue: _roadAnimationController.value,
              ),
            ),

            // Car Model (3D)
            Positioned(
              child: SizedBox(
                width: carWidth,
                height: carHeight,
                child: const Car3DView(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _backgroundGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black, // Dark Gray
            Colors.white,
          ],
        ),
      ),
    );
  }
}

class Speedometer extends StatelessWidget {
  final String speed;
  final String? lowerSpeed;
  final String? upperSpeed;
  final String unit;

  const Speedometer({
    super.key,
    required this.speed,
    this.lowerSpeed,
    this.upperSpeed,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 速限区域：有速限显示，没有速限占位
        if (lowerSpeed != null || upperSpeed != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              if (upperSpeed != null)
                _speedLimit(
                  upperSpeed!,
                  Border.all(color: Colors.red, width: 4),
                  16,
                ),
              if (lowerSpeed != null)
                _speedLimit(
                  lowerSpeed!,
                  Border.all(color: Colors.grey, width: 2),
                  16,
                ),
            ],
          )
        else
          const SizedBox(height: 48), // 固定高度占位

        Text(
          speed,
          style: textTheme.displayLarge?.copyWith(
            fontSize: 100,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            height: 1.0,
            letterSpacing: -2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          unit,
          style: textTheme.titleMedium?.copyWith(
            color: Colors.black,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _speedLimit(String speedLimit, Border border, double fontSize) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: border,
        color: Colors.white,
      ),
      child: Text(
        speedLimit,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }
}

// painting the road path
class RoadPainter extends CustomPainter {
  final Color activeLaneColor;
  final double animationValue;

  RoadPainter({required this.activeLaneColor, this.animationValue = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = size.width / 2;
    final horizonY = 0.0; // Horizon at the top of this section
    final bottomY = size.height;

    // Perspective calculation
    final topWidth = size.width * 0.35;
    final bottomWidth = size.width * 0.7;

    // Draw Dashed Lanes
    void drawDashedLane(double offsetFactor, Color color) {
      paint.color = color;
      final startX = center + topWidth * offsetFactor;
      final endX = center + bottomWidth * offsetFactor;

      // 繪製虛線
      _drawDashedLine(
        canvas,
        Offset(startX, horizonY),
        Offset(endX, bottomY),
        paint,
        dashWidth: 60,
        dashSpace: 20,
      );
    }

    // Center Lane (Left)
    drawDashedLane(-0.5, activeLaneColor);
    // Center Lane (Right)
    drawDashedLane(0.5, activeLaneColor);
  }

  // 繪製虛線的輔助方法
  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint, {
    double dashWidth = 5,
    double dashSpace = 5,
  }) {
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);

    final pathMetrics = path.computeMetrics();
    final dashPattern = dashWidth + dashSpace;

    for (final metric in pathMetrics) {
      // 根據動畫值計算偏移（讓虛線循環移動）
      final animatedOffset =
          (animationValue * dashPattern * metric.length) % dashPattern;
      double distance = -animatedOffset;

      while (distance < metric.length) {
        if (distance >= 0) {
          final nextDistance = distance + dashWidth;
          final extractPath = metric.extractPath(
            distance,
            nextDistance > metric.length ? metric.length : nextDistance,
          );
          canvas.drawPath(extractPath, paint);
        }
        distance += dashPattern;
      }
    }
  }

  @override
  bool shouldRepaint(covariant RoadPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.activeLaneColor != activeLaneColor;
  }
}

// this is for map placeholder
class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    const gridSize = 40.0;

    for (var x = 0.0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (var y = 0.0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
