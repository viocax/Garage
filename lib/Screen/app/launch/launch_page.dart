import 'package:flutter/material.dart';
import 'package:garage/theme/themed_status_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:garage/router/app_router.dart';
import 'package:garage/screen/app/launch/bloc/launch_bloc.dart';
import 'package:garage/screen/app/launch/bloc/launch_state.dart';
import 'package:garage/theme/app_theme.dart';
import 'package:garage/theme/grid_background_painter.dart';
import 'package:garage/theme/speed_line_painter.dart';
import 'package:garage/core/di/service_locator.dart';
import 'dart:math' as math;

/// 啟動頁面
///
/// 在應用啟動時顯示，執行初始化任務（如載入配置、呼叫 API 等）
/// 完成後自動跳轉到主頁面
class LaunchPage extends StatefulWidget {
  const LaunchPage({super.key});

  @override
  State<LaunchPage> createState() => _LaunchPageState();
}

class _LaunchPageState extends State<LaunchPage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt.bloc.launch(this),
      child: const LaunchView(),
    );
  }
}

class LaunchView extends StatelessWidget {
  const LaunchView({super.key});

  @override
  Widget build(BuildContext context) {
    final launchBloc = context.read<LaunchBloc>();

    return BlocListener<LaunchBloc, LaunchState>(
      listener: (context, state) {
        switch (state) {
          case LaunchCompleted():
            context.go(AppRouter.speedometer);
          case LaunchError(:final message):
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          case LaunchInitializing():
            break;
        }
      },
      child: ThemedStatusBar(
        theme: StatusBarTheme.light,
        child: Scaffold(
          backgroundColor: AppTheme.primaryColor,
          body: Stack(
            children: [
              // 網格背景
              _gridBackground(launchBloc),
              // 漸層遮罩
              _overlapGridbackgroundMask(launchBloc),

              // 主要內容
              SafeArea(
                child: Column(
                  children: [
                    // 頂部指示器
                    const SizedBox(height: 80),
                    AnimatedBuilder(
                      animation: launchBloc.animationHolder.indicatorOpacity,
                      builder: (context, child) => Opacity(
                        opacity:
                            launchBloc.animationHolder.indicatorOpacity.value,
                        child: _buildTopIndicator(launchBloc),
                      ),
                    ),

                    const Spacer(),

                    // Logo 區域
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        launchBloc.animationHolder.logoOpacity,
                        launchBloc.animationHolder.logoScale,
                      ]),
                      builder: (context, child) => Opacity(
                        opacity: launchBloc.animationHolder.logoOpacity.value,
                        child: Transform.scale(
                          scale: launchBloc.animationHolder.logoScale.value,
                          child: Column(
                            children: [
                              // GARAGE 文字
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'GARAGE',
                                    style: TextStyle(
                                      fontSize: 52,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 12,
                                      color: AppTheme.accentColor,
                                      height: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // 下劃線
                                  AnimatedBuilder(
                                    animation: launchBloc
                                        .animationHolder
                                        .underlineWidth,
                                    builder: (context, child) => Container(
                                      width:
                                          372 *
                                          launchBloc
                                              .animationHolder
                                              .underlineWidth
                                              .value,
                                      height: 2,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppTheme.accentColor.withValues(
                                              alpha: 0,
                                            ),
                                            AppTheme.accentColor,
                                            AppTheme.accentColor.withValues(
                                              alpha: 0,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 60),

                              // 輪框輪廓
                              AnimatedBuilder(
                                animation: Listenable.merge([
                                  launchBloc.animationHolder.carOpacity,
                                  launchBloc.animationHolder.carDrawProgress,
                                ]),
                                builder: (context, child) => Opacity(
                                  opacity: launchBloc
                                      .animationHolder
                                      .carOpacity
                                      .value,
                                  child: SizedBox(
                                    width: 200,
                                    height: 200,
                                    child: CustomPaint(
                                      painter: WheelRimPainter(
                                        progress: launchBloc
                                            .animationHolder
                                            .carDrawProgress
                                            .value,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // 速度線裝飾
                    _buildSpeedGradient(launchBloc),

                    const SizedBox(height: 20),

                    // Tagline
                    _buildSolgen(launchBloc),

                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gridBackground(LaunchBloc bloc) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: bloc.animationHolder.gridOpacity,
        builder: (context, child) => Opacity(
          opacity: bloc.animationHolder.gridOpacity.value,
          child: CustomPaint(
            painter: GridBackgroundPainter(color: AppTheme.systemGray),
          ),
        ),
      ),
    );
  }

  Widget _overlapGridbackgroundMask(LaunchBloc bloc) {
    return AnimatedBuilder(
      animation: bloc.animationHolder.gradientOpacity,
      builder: (context, child) => Opacity(
        opacity: bloc.animationHolder.gradientOpacity.value,
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, 0.5),
              radius: 1.2,
              colors: [
                const Color(0xFF1E1E1E).withValues(alpha: 0.8),
                const Color(0xFF0A0A0A),
              ],
              stops: const [0.0, 0.7],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopIndicator(LaunchBloc bloc) {
    return AnimatedBuilder(
      animation: bloc.animationHolder.indicatorOpacity,
      builder: (context, child) => Opacity(
        opacity: bloc.animationHolder.indicatorOpacity.value,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDot(false),
            const SizedBox(width: 8),
            _buildDot(true),
            const SizedBox(width: 8),
            _buildDot(false),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? AppTheme.accentColor
            : AppTheme.accentColor.withValues(alpha: 0.3),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppTheme.accentColor.withValues(alpha: 0.5),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
    );
  }

  Widget _buildSpeedGradient(LaunchBloc bloc) {
    return SizedBox(
      height: 100,
      width: 200,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          bloc.animationHolder.speedLinesController,
          bloc.animationHolder.speedLinesOpacity,
        ]),
        builder: (context, child) => Opacity(
          opacity: bloc.animationHolder.speedLinesOpacity.value,
          child: CustomPaint(
            painter: SpeedLinesPainter(
              progress: bloc.animationHolder.speedLinesController.value,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSolgen(LaunchBloc bloc) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        bloc.animationHolder.taglineOpacity,
        bloc.animationHolder.taglinePosition,
      ]),
      builder: (context, child) => Opacity(
        opacity: bloc.animationHolder.taglineOpacity.value,
        child: Transform.translate(
          offset: Offset(0, bloc.animationHolder.taglinePosition.value),
          child: Text(
            'Your Cash · Your Call',
            style: TextStyle(
              fontSize: 18,
              letterSpacing: 4,
              fontWeight: FontWeight.w300,
              color: AppTheme.accentColor.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}

// 輪框繪製器 (TE37 風格)
class WheelRimPainter extends CustomPainter {
  final double progress;

  WheelRimPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    final paint = Paint()
      ..color = AppTheme.accentColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = AppTheme.accentColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final path = _createWheelPath(center, radius);

    // 計算路徑長度並根據進度繪製
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      final extractPath = metric.extractPath(0.0, metric.length * progress);
      canvas.drawPath(extractPath, glowPaint);
      canvas.drawPath(extractPath, paint);
    }
  }

  Path _createWheelPath(Offset center, double radius) {
    final path = Path();

    // 1. 外圈 (Rim Lip)
    path.addOval(Rect.fromCircle(center: center, radius: radius));
    path.addOval(Rect.fromCircle(center: center, radius: radius * 0.92));

    // 2. 內圈 (Hub)
    final hubRadius = radius * 0.25;
    path.addOval(Rect.fromCircle(center: center, radius: hubRadius));

    // 3. 螺絲孔 (Bolt Holes) - 5孔
    final boltRadius = radius * 0.15;
    for (int i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + (i * 2 * math.pi / 5);
      final boltCenter = Offset(
        center.dx + math.cos(angle) * boltRadius,
        center.dy + math.sin(angle) * boltRadius,
      );
      path.addOval(Rect.fromCircle(center: boltCenter, radius: radius * 0.02));
    }

    // 4. 輪輻 (Spokes) - 6爪 (TE37 Style)
    final spokeCount = 6;
    final spokeStartRadius = hubRadius;
    final spokeEndRadius = radius * 0.92;
    final spokeWidth = radius * 0.2; // 固定輪輻寬度

    for (int i = 0; i < spokeCount; i++) {
      final angle = -math.pi / 2 + (i * 2 * math.pi / spokeCount);

      // 計算輪輻的四個角點 (使用平行線邏輯)
      // 內側點 (Hub端)
      final p1 = _getOffsetFromCenterLine(
        center,
        spokeStartRadius,
        angle,
        -spokeWidth / 2,
      );
      final p2 = _getOffsetFromCenterLine(
        center,
        spokeStartRadius,
        angle,
        spokeWidth / 2,
      );

      // 外側點 (Rim端)
      final p3 = _getOffsetFromCenterLine(
        center,
        spokeEndRadius,
        angle,
        spokeWidth / 2,
      );
      final p4 = _getOffsetFromCenterLine(
        center,
        spokeEndRadius,
        angle,
        -spokeWidth / 2,
      );

      // 繪製單個輪輻的輪廓
      final spokePath = Path();
      spokePath.moveTo(p1.dx, p1.dy);
      spokePath.lineTo(p4.dx, p4.dy); // 左邊線
      spokePath.moveTo(p2.dx, p2.dy);
      spokePath.lineTo(p3.dx, p3.dy); // 右邊線

      // 添加裝飾貼紙區域 (TE37 特有的紅色貼紙位置)
      if (i == 2) {
        // 在其中一個輪輻上畫貼紙框
        final stickerWidth = spokeWidth * 0.6;
        final stickerStartRadius = radius * 0.3;
        final stickerEndRadius = radius * 0.8;

        // 貼紙輪廓
        final stickerPath = Path();

        final s1 = _getOffsetFromCenterLine(
          center,
          stickerStartRadius,
          angle,
          -stickerWidth / 2,
        );
        final s2 = _getOffsetFromCenterLine(
          center,
          stickerStartRadius,
          angle,
          stickerWidth / 2,
        );
        final s3 = _getOffsetFromCenterLine(
          center,
          stickerEndRadius,
          angle,
          stickerWidth / 2,
        );
        final s4 = _getOffsetFromCenterLine(
          center,
          stickerEndRadius,
          angle,
          -stickerWidth / 2,
        );

        stickerPath.moveTo(s1.dx, s1.dy);
        stickerPath.lineTo(s2.dx, s2.dy);
        stickerPath.lineTo(s3.dx, s3.dy);
        stickerPath.lineTo(s4.dx, s4.dy);
        stickerPath.close();

        path.addPath(stickerPath, Offset.zero);
      }

      path.addPath(spokePath, Offset.zero);
    }

    return path;
  }

  // 根據中心線和垂直偏移量計算點
  Offset _getOffsetFromCenterLine(
    Offset center,
    double distance,
    double angle,
    double offset,
  ) {
    // 中心線方向向量
    final dx = math.cos(angle);
    final dy = math.sin(angle);

    // 垂直向量 (-dy, dx)
    final pdx = -dy;
    final pdy = dx;

    return Offset(
      center.dx + dx * distance + pdx * offset,
      center.dy + dy * distance + pdy * offset,
    );
  }

  @override
  bool shouldRepaint(WheelRimPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
