import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/theme/app_theme.dart';
import 'package:garage/theme/grid_background_painter.dart';
import 'package:garage/core/di/service_locator.dart';
import '../car3d/car_3d_view.dart';
import '../car3d/bloc/car_3d_bloc.dart';
import '../car3d/bloc/car_3d_event.dart';
import 'bloc/speed_bloc.dart';
import 'bloc/speed_state.dart';
import 'bloc/speed_event.dart';

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
        BlocProvider(create: (context) => SpeedBloc()),
        BlocProvider(create: (context) => Car3DBloc()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<SpeedBloc, SpeedState>(
            listener: (context, state) {
              switch (state) {
                case SpeedData(:final speed, :final animationDuration):
                  // 更新道路動畫時長
                  _roadAnimationController.duration = animationDuration;

                  // 如果速度為 0，停止動畫
                  if (speed <= 0) {
                    _roadAnimationController.stop();
                    // 停止車輛動畫
                    context.read<Car3DBloc>().add(const StopCar3DAnimation());
                  } else {
                    // 啟動車輛動畫
                    context.read<Car3DBloc>().add(const StartCar3DAnimation());

                    // 如果速度 > 0 且未在播放，或者需要更新速率，則重新播放
                    if (!_roadAnimationController.isAnimating) {
                      _roadAnimationController.repeat();
                    } else {
                      _roadAnimationController.repeat();
                    }
                  }
              }
            },
          ),
        ],
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          child: Scaffold(
            backgroundColor: AppTheme.primaryColor,
            body: Stack(
              children: [
                // 1. Background Gradient
                _backgroundGradient(),

                // 2. Grid Background (Top part)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: CustomPaint(painter: GridBackgroundPainter()),
                ),

                // 3. Speed Limit Overlay (Top Left)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 20,
                  left: 20,
                  child: BlocBuilder<SpeedBloc, SpeedState>(
                    builder: (context, state) {
                      return switch (state) {
                        SpeedData(:final lowerSpeed, :final upperSpeed) =>
                          _buildSpeedLimitOverlay(lowerSpeed, upperSpeed),
                      };
                    },
                  ),
                ),

                // 4. Speedometer (Center)
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.25,
                  left: 0,
                  right: 0,
                  child: BlocBuilder<SpeedBloc, SpeedState>(
                    builder: (context, state) {
                      return switch (state) {
                        SpeedData(
                          :final speed,
                          :final unit,
                          :final maxSpeed,
                          :final isOverSpeed,
                          :final isDetecting,
                        ) =>
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Center(
                                child: Speedometer(
                                  speed: speed.toInt().toString(),
                                  unit: unit,
                                  isOverSpeed: isOverSpeed,
                                  maxSpeed: maxSpeed,
                                ),
                              ),
                              // Detection Button (Bottom Center)
                              Positioned(
                                bottom: 0,
                                child: SpeedDetectionButton(
                                  isDetecting: isDetecting,
                                  onTap: () {
                                    if (isDetecting) {
                                      context.read<SpeedBloc>().add(
                                        const StopDetection(),
                                      );
                                    } else {
                                      context.read<SpeedBloc>().add(
                                        const StartDetection(),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                      };
                    },
                  ),
                ),

                // 5. Road & Car (Bottom)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: _roadPath(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedLimitOverlay(String? lowerSpeed, String? upperSpeed) {
    // if (lowerSpeed == null && upperSpeed == null)
    //   return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.whiteTransparent10,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.whiteTransparent20, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              if (upperSpeed != null)
                _speedLimitCircle(upperSpeed, AppTheme.systemRed),
              if (lowerSpeed != null)
                _speedLimitCircle(lowerSpeed, AppTheme.systemGray),
            ],
          ),
        ),
      ),
    );
  }

  Widget _speedLimitCircle(String limit, Color borderColor) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.accentColor,
        border: Border.all(color: borderColor, width: 4),
        boxShadow: [
          BoxShadow(
            color: AppTheme.blackTransparent10,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        limit,
        style: const TextStyle(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 18,
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
                activeLaneColor: AppTheme.blackTransparent15,
                animationValue: _roadAnimationController.value,
              ),
            ),

            // Car Model (3D)
            Positioned(
              bottom: 20,
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
            AppTheme.darkSurface, // Dark top
            AppTheme.systemGray5, // Light bottom
          ],
          stops: [0.3, 1.0],
        ),
      ),
    );
  }
}

class Speedometer extends StatefulWidget {
  final String speed;
  final String unit;
  final bool isOverSpeed;
  final double maxSpeed; // 假設最大速度

  const Speedometer({
    super.key,
    required this.speed,
    required this.unit,
    required this.maxSpeed,
    this.isOverSpeed = false,
  });

  @override
  State<Speedometer> createState() => _SpeedometerState();
}

class _SpeedometerState extends State<Speedometer>
    with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void didUpdateWidget(Speedometer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOverSpeed && !oldWidget.isOverSpeed) {
      _blinkController.repeat(reverse: true);
    } else if (!widget.isOverSpeed && oldWidget.isOverSpeed) {
      _blinkController.stop();
      _blinkController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final double currentSpeed = double.tryParse(widget.speed) ?? 0;
    final double progress = (currentSpeed / widget.maxSpeed).clamp(0.0, 1.0);

    return Stack(
      alignment: Alignment.center,
      children: [
        // Arc Progress Bar
        SizedBox(
          width: 300,
          height: 300,
          child: CustomPaint(
            painter: SpeedometerArcPainter(
              progress: progress,
              trackColor: AppTheme.greyTransparent20,
              progressColor: _getProgressColor(currentSpeed),
            ),
          ),
        ),

        // Speed Text & Unit
        AnimatedBuilder(
          animation: _blinkController,
          builder: (context, child) {
            final speedColor = widget.isOverSpeed
                ? Color.lerp(
                    AppTheme.systemRed,
                    AppTheme.redTransparent30,
                    _blinkController.value,
                  )!
                : AppTheme.accentColor;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.speed,
                  style: textTheme.displayLarge?.copyWith(
                    fontSize: 100,
                    fontWeight: FontWeight.w400,
                    color: speedColor,
                    height: 1.0,
                    letterSpacing: -4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.unit,
                  style: textTheme.titleMedium?.copyWith(
                    color: widget.isOverSpeed
                        ? AppTheme.redTransparent90
                        : AppTheme.whiteTransparent70,
                    fontSize: 20,
                    letterSpacing: 1,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Color _getProgressColor(double speed) {
    if (speed < 60) return AppTheme.speedSlow;
    if (speed < 100) return AppTheme.speedMedium;
    return AppTheme.speedFast;
  }
}

class SpeedometerArcPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  SpeedometerArcPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const startAngle = 135 * 3.14159 / 180; // Start from bottom-left
    const sweepAngle = 270 * 3.14159 / 180; // Sweep 270 degrees

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15.0
      ..strokeCap = StrokeCap.round;

    // Draw Track
    paint.color = trackColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );

    // Draw Progress
    paint.color = progressColor;
    // Add a gradient or shadow if needed, for now simple solid color
    // To make it look cooler, we can use a gradient shader
    paint.shader = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: [
        AppTheme.gradientGreen,
        AppTheme.gradientYellow,
        AppTheme.gradientRed,
      ],
      stops: const [0.0, 0.5, 1.0],
      transform: GradientRotation(startAngle - 0.1), // Slight adjustment
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    // Override color with shader
    paint.color = AppTheme.accentColor; // Ignored when shader is set

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant SpeedometerArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
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
    final topWidth = size.width * 0.25;
    final bottomWidth = size.width * 0.75;

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

// Detection Button Widget
class DetectionButton extends StatefulWidget {
  final bool isDetecting;
  final VoidCallback onPressed;

  const DetectionButton({
    super.key,
    required this.isDetecting,
    required this.onPressed,
  });

  @override
  State<DetectionButton> createState() => _DetectionButtonState();
}

class _DetectionButtonState extends State<DetectionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(DetectionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDetecting && !oldWidget.isDetecting) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isDetecting && oldWidget.isDetecting) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: widget.isDetecting
                  ? [
                      BoxShadow(
                        color: AppTheme.accentColor.withValues(
                          alpha: 0.4 * _pulseAnimation.value,
                        ),
                        blurRadius: 20 * _pulseAnimation.value,
                        spreadRadius: 5 * _pulseAnimation.value,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: AppTheme.blackTransparent15,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: widget.isDetecting
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.accentColor,
                              AppTheme.accentColor.withValues(alpha: 0.8),
                            ],
                          )
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.whiteTransparent20,
                              AppTheme.whiteTransparent10,
                            ],
                          ),
                    border: Border.all(
                      color: widget.isDetecting
                          ? AppTheme.accentColor
                          : AppTheme.whiteTransparent30,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      widget.isDetecting
                          ? Icons.stop_rounded
                          : Icons.play_arrow_rounded,
                      size: 40,
                      color: widget.isDetecting
                          ? AppTheme.primaryColor
                          : AppTheme.accentColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class SpeedDetectionButton extends StatefulWidget {
  final bool isDetecting;
  final VoidCallback onTap;

  const SpeedDetectionButton({
    Key? key,
    required this.isDetecting,
    required this.onTap,
  }) : super(key: key);

  @override
  State<SpeedDetectionButton> createState() => _SpeedDetectionButtonState();
}

class _SpeedDetectionButtonState extends State<SpeedDetectionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true); // 讓呼吸燈效果循環
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 定義顏色
    final activeColor = const Color.fromARGB(
      255,
      223,
      162,
      162,
    ); // 偵測中 (停止按鈕顏色)
    final inactiveColor = const Color.fromARGB(
      255,
      152,
      220,
      204,
    ); // 未啟動 (啟動按鈕顏色 - 類似賽博龐克綠)

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // 計算呼吸燈陰影擴散半徑 (只在偵測中時有呼吸效果)
          double glowRadius = widget.isDetecting
              ? (5.0 * _controller.value)
              : 0.0;

          return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6), // 半透明深色背景
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.isDetecting ? activeColor : inactiveColor,
                width: 3,
              ),
              boxShadow: [
                // 外發光效果
                BoxShadow(
                  color: (widget.isDetecting ? activeColor : inactiveColor)
                      .withValues(alpha: 0.6),
                  blurRadius: widget.isDetecting ? 20 : 10,
                  spreadRadius: glowRadius,
                ),
                // 內部光暈
                BoxShadow(
                  color: (widget.isDetecting ? activeColor : inactiveColor)
                      .withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: -5,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: widget.isDetecting
                    ? Icon(
                        Icons.stop_rounded,
                        key: const ValueKey('stop'),
                        color: activeColor,
                        size: 40,
                      )
                    : Icon(
                        Icons.play_arrow_rounded,
                        key: const ValueKey('start'),
                        color: inactiveColor,
                        size: 45,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

//developer.apple.com
