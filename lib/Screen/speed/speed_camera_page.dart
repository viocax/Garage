import 'package:flutter/material.dart';

class SpeedCameraPage extends StatefulWidget {
  const SpeedCameraPage({super.key});

  @override
  State<SpeedCameraPage> createState() => _SpeedCameraPageState();
}

class _SpeedCameraPageState extends State<SpeedCameraPage> {
  bool _isDetecting = false;

  @override
  Widget build(BuildContext context) {
    // Use theme colors
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 3D Road Scene Placeholder
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorScheme.surface,
                      colorScheme.surface.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Road perspective lines
                    CustomPaint(
                      size: Size.infinite,
                      painter: RoadPainter(
                        color: colorScheme.onSurface.withValues(alpha: 0.1),
                      ),
                    ),

                    // Speed Display (HUD Style)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isDetecting ? '72' : '--',
                          style: textTheme.displayLarge?.copyWith(
                            fontSize: 120,
                            fontWeight: FontWeight.w200,
                            height: 1.0,
                            letterSpacing: -5,
                          ),
                        ),
                        Text(
                          'km/h',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),

                    // Speed Limit Warning (Hidden when not detecting or safe)
                    if (_isDetecting)
                      Positioned(
                        bottom: 40,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: colorScheme.error.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: colorScheme.error,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '500m 限速 50',
                                style: textTheme.titleMedium?.copyWith(
                                  color: colorScheme.error,
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
            ),

            // Control Panel
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _isDetecting
                                        ? const Color(0xFF34C759) // iOS Green
                                        : colorScheme.onSurface.withValues(
                                            alpha: 0.3,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isDetecting ? '測速偵測中' : '測速偵測已關閉',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isDetecting ? '正在監聽測速照相...' : '開啟以接收提醒',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Switch.adaptive(
                          value: _isDetecting,
                          onChanged: (value) {
                            setState(() {
                              _isDetecting = value;
                            });
                          },
                          activeTrackColor: const Color(0xFF34C759),
                        ),
                      ],
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
}

class RoadPainter extends CustomPainter {
  final Color color;

  RoadPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = size.width / 2;
    final horizon = size.height * 0.3;

    // Draw perspective lines
    canvas.drawLine(Offset(center, horizon), Offset(0, size.height), paint);
    canvas.drawLine(
      Offset(center, horizon),
      Offset(size.width, size.height),
      paint,
    );

    // Draw horizon
    canvas.drawLine(Offset(0, horizon), Offset(size.width, horizon), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
