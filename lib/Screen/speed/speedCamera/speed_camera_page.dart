import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_map/flutter_map.dart';
import 'package:garage/theme/grid_background_painter.dart';
import 'package:latlong2/latlong.dart';
import 'package:garage/theme/themed_status_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/theme/app_theme.dart';
import 'package:garage/core/models/tabbar_type.dart';
import 'package:garage/screen/app/home/bloc/garage_home_bloc.dart';
import 'package:garage/screen/app/home/bloc/garage_home_state.dart';
import '../car3d/car_3d_view.dart';
import '../car3d/bloc/car_3d_bloc.dart';
import '../car3d/bloc/car_3d_event.dart';
import 'bloc/speed_bloc.dart';
import 'bloc/speed_state.dart';
import 'bloc/speed_event.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:geolocator/geolocator.dart';
import 'package:garage/core/extensions/extensions.dart';

class SpeedCameraPage extends StatefulWidget {
  const SpeedCameraPage({super.key});

  @override
  State<SpeedCameraPage> createState() => _SpeedCameraPageState();
}

class _SpeedCameraPageState extends State<SpeedCameraPage>
    with TickerProviderStateMixin {
  late AnimationController _roadAnimationController;
  late AnimationController _mapAnimationController;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // 初始化道路動畫控制器（不自動播放）
    _roadAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // 初始化地圖動畫控制器
    _mapAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _roadAnimationController.dispose();
    _mapAnimationController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // 帶動畫的地圖移動
  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final camera = _mapController.camera;
    final startLocation = camera.center;
    final startZoom = camera.zoom;

    final latTween = Tween<double>(
      begin: startLocation.latitude,
      end: destLocation.latitude,
    );
    final lngTween = Tween<double>(
      begin: startLocation.longitude,
      end: destLocation.longitude,
    );
    final zoomTween = Tween<double>(begin: startZoom, end: destZoom);

    final Animation<double> animation = CurvedAnimation(
      parent: _mapAnimationController,
      curve: Curves.easeInOut,
    );

    void listener() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    }

    _mapAnimationController.addListener(listener);

    _mapAnimationController.forward(from: 0).whenComplete(() {
      _mapAnimationController.removeListener(listener);
    });
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
              if (state is SpeedData) {
                if (state.showPermissionAlert) {
                  context.showAdaptivePermissionAlert(
                    title: 'speedCamera.permission.title'.tr(),
                    message: 'speedCamera.permission.message'.tr(),
                    cancelText: 'common.cancel'.tr(),
                    confirmText: 'common.goToSettings'.tr(),
                    onConfirm: () async {
                      // 開啟系統設定
                      await Geolocator.openAppSettings();
                    },
                    onCancel: () {
                      // 使用者取消，可以在這裡重置狀態（如果需要）
                    },
                  );
                }
              }

              switch (state) {
                case SpeedData(
                  // :final animationDuration, // TODO: 到時侯試試看要不要移除
                  :final currentLocation,
                ):
                  // 更新道路動畫時長
                  // _roadAnimationController.duration = animationDuration;

                  // 如果速度為 0，停止動畫
                  if (!state.isStartAnimation) {
                    _roadAnimationController.stop();
                    // 停止車輛動畫
                    context.read<Car3DBloc>().add(const StopCar3DAnimation());
                  } else {
                    // 啟動車輛動畫
                    context.read<Car3DBloc>().add(const StartCar3DAnimation());

                    // 如果速度 > 0 且未在播放，或者需要更新速率，則重新播放
                    if (!_roadAnimationController.isAnimating) {
                      _roadAnimationController.repeat();
                    }
                  }

                  // 更新地圖位置（往南偏移讓使用者位置在上方）
                  if (currentLocation != null) {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(
                      LatLng(
                        currentLocation.latitude -
                            _getLatitudeOffset(currentZoom),
                        currentLocation.longitude,
                      ),
                      currentZoom,
                    );
                  }
              }
            },
          ),
          BlocListener<GarageHomeBloc, GarageHomeState>(
            listener: (context, state) {
              // 當切換到測速 tab 時，重新載入設定
              if (state.tabbarType is SpeedCameraTab) {
                context.read<SpeedBloc>().add(const SpeedLoading());
              }
            },
          ),
        ],
        child: ThemedStatusBar(
          theme: StatusBarTheme.light,
          child: Scaffold(
            backgroundColor: AppTheme.blackTransparent90,
            body: Stack(
              children: [
                // 1. Map (Full Screen Background)
                Positioned.fill(
                  child: BlocBuilder<SpeedBloc, SpeedState>(
                    builder: (context, state) {
                      return switch (state) {
                        SpeedData() => _buildFullScreenMap(state),
                      };
                    },
                  ),
                ),

                // 2. Speed Limit Overlay (Top Left - over map)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 16,
                  child: BlocBuilder<SpeedBloc, SpeedState>(
                    builder: (context, state) {
                      return switch (state) {
                        SpeedData() => _buildSpeedLimitOverlay(state),
                      };
                    },
                  ),
                ),

                // 3. Map Zoom Controls (Top Right)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  right: 16,
                  child: BlocBuilder<SpeedBloc, SpeedState>(
                    builder: (context, state) {
                      return switch (state) {
                        SpeedData(:final currentLocation, :final isDetecting) =>
                          _buildMapControls(
                            context,
                            isDetecting,
                            currentLocation,
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
                  height: MediaQuery.of(context).size.height * 0.35,
                  child: BlocBuilder<SpeedBloc, SpeedState>(
                    builder: (context, state) {
                      final isDetecting = state is SpeedData
                          ? state.isDetecting
                          : false;
                      return _roadPath(context, isDetecting);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedLimitOverlay(SpeedData speedData) {
    if (!speedData.isDetecting) {
      return const SizedBox.shrink();
    }
    final lowerSpeed = speedData.lowerSpeed;
    final upperSpeed = speedData.upperSpeed;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.blackTransparent30,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.whiteTransparent20, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                speedData.displaySpeed,
                style: const TextStyle(
                  color: AppTheme.accentColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                speedData.unit.displayName,
                style: TextStyle(
                  color: AppTheme.whiteTransparent70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (lowerSpeed != null || upperSpeed != null)
                Container(
                  width: 1,
                  height: 24,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  color: AppTheme.whiteTransparent24,
                ),

              if (upperSpeed != null)
                _speedLimitCircle(upperSpeed, AppTheme.systemRed),
              if (lowerSpeed != null && upperSpeed != null)
                const SizedBox(width: 8),
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

  Widget _buildMapControls(
    BuildContext context,
    bool isDetecting,
    LocationData? currentLocation,
  ) {
    final defaultLocation = LatLng(25.0330, 121.5654);
    final currentLatLng = currentLocation != null
        ? LatLng(currentLocation.latitude, currentLocation.longitude)
        : defaultLocation;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.blackTransparent30,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.whiteTransparent20,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Zoom In
                  _buildZoomButton(
                    icon: Icons.add,
                    onTap: () {
                      final currentZoom = _mapController.camera.zoom;
                      if (currentZoom < 18) {
                        final newZoom = currentZoom + 1;
                        _animatedMapMove(
                          LatLng(
                            currentLatLng.latitude -
                                _getLatitudeOffset(newZoom),
                            currentLatLng.longitude,
                          ),
                          newZoom,
                        );
                      }
                    },
                  ),
                  Container(
                    height: 1,
                    width: 30,
                    color: AppTheme.whiteTransparent20,
                  ),
                  // Zoom Out
                  _buildZoomButton(
                    icon: Icons.remove,
                    onTap: () {
                      final currentZoom = _mapController.camera.zoom;
                      if (currentZoom > 10) {
                        final newZoom = currentZoom - 1;
                        _animatedMapMove(
                          LatLng(
                            currentLatLng.latitude -
                                _getLatitudeOffset(newZoom),
                            currentLatLng.longitude,
                          ),
                          newZoom,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Start/Stop Toggle Button
        GestureDetector(
          onTap: () {
            if (isDetecting) {
              context.read<SpeedBloc>().add(const StopDetection());
            } else {
              context.read<SpeedBloc>().add(const StartDetection());
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDetecting
                      ? AppTheme.systemRed.withValues(alpha: 0.8)
                      : AppTheme.systemGreen.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.whiteTransparent20,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDetecting
                          ? AppTheme.systemRed.withValues(alpha: 0.4)
                          : AppTheme.systemGreen.withValues(alpha: 0.4),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  isDetecting ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  color: AppTheme.accentColor,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        child: Icon(icon, color: AppTheme.accentColor, size: 22),
      ),
    );
  }

  // 基準緯度偏移量（在 zoom 16 時的偏移）
  static const double _baseLatitudeOffset = 0.001;
  static const double _baseZoom = 16.0;

  // 根據當前 zoom level 動態計算緯度偏移量
  // zoom 越大（越近），偏移量越小；zoom 越小（越遠），偏移量越大
  double _getLatitudeOffset(double zoom) {
    return _baseLatitudeOffset * pow(2, _baseZoom - zoom);
  }

  Widget _buildFullScreenMap(SpeedData data) {
    final location = data.currentLocation;
    final defaultLocation = LatLng(25.0330, 121.5654);
    final currentLatLng = location != null
        ? LatLng(location.latitude, location.longitude)
        : defaultLocation;
    // 地圖中心往南偏移，讓使用者位置顯示在上方（初始使用基準偏移量，對應 zoom 16）
    final mapCenter = LatLng(
      currentLatLng.latitude - _baseLatitudeOffset,
      currentLatLng.longitude,
    );

    return Stack(
      children: [
        // 地圖
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: mapCenter,
            initialZoom: 15.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
              userAgentPackageName: 'com.example.garage',
              retinaMode: true,
            ),
            CircleLayer(
              circles: [
                CircleMarker(
                  point: currentLatLng,
                  radius: data.alertDistance.toDouble(),
                  useRadiusInMeter: true,
                  color: data.isOverSpeed
                      ? AppTheme.redTransparent30
                      : AppTheme.greenTransparent30,
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: currentLatLng,
                  width: 45,
                  height: 45,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 300),
                    builder: (context, value, child) {
                      return Transform.scale(scale: value, child: child);
                    },
                    child: Transform.rotate(
                      angle: data.model.heading * (pi / 180), // 將度數轉換為弧度
                      child: Icon(
                        Icons.navigation_rounded,
                        color: AppTheme.primaryColor,
                        size: 16,
                      ),
                    ),
                  ),
                ),

                ...data.cameraLocations.map((location) {
                  return Marker(
                    point: LatLng(location.latitude, location.longitude),
                    width: 45,
                    height: 45,
                    child: Icon(
                      Icons.circle_notifications,
                      color: AppTheme.redTransparent30,
                    ),
                  );
                }),
              ],
            ),
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                  onTap: () => launchUrl(
                    Uri.parse('https://openstreetmap.org/copyright'),
                  ),
                ),
              ],
            ),
          ],
        ),
        if (location == null) ...[
          IgnorePointer(child: Container(color: AppTheme.blackTransparent75)),
          IgnorePointer(
            child: CustomPaint(
              painter: GridBackgroundPainter(),
              size: Size.infinite,
            ),
          ),
        ] else ...[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.25,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.darkSurface,
                      AppTheme.darkSurface.withValues(alpha: 0.9),
                      AppTheme.darkSurface.withValues(alpha: 0.7),
                      AppTheme.darkSurface.withValues(alpha: 0),
                    ],
                    stops: const [0.0, 0.2, 0.45, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ],
        // 中間漸層遮罩（讓速度表清楚顯示，但保留底部道路區域）
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.6,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.darkSurface.withValues(alpha: 0),
                    AppTheme.darkSurface.withValues(alpha: 0.7),
                    AppTheme.darkSurface.withValues(alpha: 0.9),
                    AppTheme.darkSurface,
                  ],
                  stops: const [0.0, 0.6, 0.85, 1.0],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _roadPath(BuildContext context, bool isDetecting) {
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
                activeLaneColor: AppTheme.whiteTransparent20,
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
    final path = ui.Path()
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
