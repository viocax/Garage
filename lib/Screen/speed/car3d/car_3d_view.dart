import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'bloc/car_3d_bloc.dart';
import 'bloc/car_3d_event.dart';
import 'bloc/car_3d_state.dart';

class Car3DView extends StatefulWidget {
  const Car3DView({super.key});

  @override
  State<Car3DView> createState() => _Car3DViewState();
}

class _Car3DViewState extends State<Car3DView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _offsetAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 發送加載模型事件
    context.read<Car3DBloc>().add(const LoadCar3DModel());

    // 初始化動畫控制器
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // 設置動畫：從 0 移動到 -80（往上移）
    // 啟動：緩慢到快速（easeIn）
    // 煞車：快速到緩慢（easeOut）
    _offsetAnimation = Tween<double>(begin: 0.0, end: -60.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Cubic(0.5, 0, 0.5, 1), // 啟動時：慢到快
        reverseCurve: Cubic(0, 0.75, 1, 0), // 煞車時：快到慢
      ),
    );

    // 設置縮放動畫：從 1.0 縮小到 0.85（些微縮小）
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Cubic(0.5, 0, 0.5, 1),
        reverseCurve: Cubic(0, 0.75, 1, 0),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final carWidth = screenWidth * 0.4;
    final carHeight = carWidth * 1.15;
    final cameraOrbit = "180deg 70deg 60%";

    return BlocConsumer<Car3DBloc, Car3DState>(
      listener: (context, state) {
        switch (state) {
          case Car3DAnimating():
            _animationController.forward();
          case Car3DReady():
            _animationController.reverse();
          case Car3DLoading():
          case Car3DLoadError():
            // 不需要處理動畫
            break;
        }
      },
      builder: (context, state) {
        return switch (state) {
          // 加載中
          Car3DLoading() => const SizedBox.shrink(),

          // 加載失敗
          Car3DLoadError() => Center(
            child: Container(
              width: 80,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.directions_car_filled,
                size: 60,
                color: Colors.black,
              ),
            ),
          ),

          // 模型已加載
          Car3DReady(:final modelSrc) || Car3DAnimating(:final modelSrc) =>
            _buildCarModel(modelSrc, carWidth, carHeight, cameraOrbit),
        };
      },
    );
  }

  Widget _buildCarPlaceHolder(double carWidth, double carHeight) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Center(
        child: CustomPaint(
          size: Size(carWidth, carHeight * 0.8),
          painter: TrapezoidShadowPainter(),
        ),
      ),
    );
  }

  Widget _buildCarModel(
    String modelSrc,
    double carWidth,
    double carHeight,
    String cameraOrbit,
  ) {
    return AnimatedBuilder(
      animation: _offsetAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _offsetAnimation.value),
            child: Stack(
              children: [
                // 梯形陰影
                _buildCarPlaceHolder(carWidth, carHeight),
                Padding(
                  padding: EdgeInsets.all(24),
                  child: AbsorbPointer(
                    child: ModelViewer(
                      src: modelSrc,
                      alt: "A 3D car model",
                      autoRotate: false,
                      cameraControls: false,
                      backgroundColor: Colors.transparent,
                      loading: Loading.eager, // 立即載入，隱藏載入指示器
                      // 使用百分比让模型自动适配容器（180度让车尾朝前）
                      cameraOrbit: cameraOrbit, // 相机更远，降低俯视角度
                      cameraTarget: "0m 10mm 0m", // 对准车身上方，让车显示在画面下方
                      fieldOfView: "30deg", // 增大视野让车看起来更小
                      environmentImage: "neutral",
                      exposure: 1.0,
                      shadowIntensity: 0.8,
                      shadowSoftness: 0.5,
                      minCameraOrbit: cameraOrbit,
                      maxCameraOrbit: cameraOrbit,
                      disableZoom: true,
                      disablePan: true,
                      disableTap: true,
                      touchAction: TouchAction.none, // 禁用所有触摸动作
                      interactionPrompt: InteractionPrompt.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 梯形陰影繪製器
class TrapezoidShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.8,
        colors: [Colors.black, Colors.transparent],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    // 繪製梯形：上窄下寬，帶圓角
    final path = Path();
    final topWidth = size.width * 0.6; // 上邊寬度為總寬度的 60%
    final bottomWidth = size.width * 1.2; // 下邊寬度為總寬度的 120%（更寬）
    final topOffset = (size.width - topWidth) / 2;
    final bottomOffset = (size.width - bottomWidth) / 2; // 負值，讓底部向外擴展
    final radius = 8.0; // 圓角半徑

    // 從左上角開始（帶圓角）
    path.moveTo(topOffset + radius, 0);
    // 上邊線到右上角
    path.lineTo(topOffset + topWidth - radius, 0);
    // 右上圓角
    path.quadraticBezierTo(
      topOffset + topWidth,
      0,
      topOffset + topWidth + radius,
      radius,
    );
    // 右邊斜線到右下角
    path.lineTo(bottomOffset + bottomWidth - radius, size.height - radius);
    // 右下圓角
    path.quadraticBezierTo(
      bottomOffset + bottomWidth,
      size.height - radius,
      bottomOffset + bottomWidth,
      size.height,
    );
    // 下邊線到左下角
    path.lineTo(bottomOffset + radius, size.height);
    // 左下圓角
    path.quadraticBezierTo(
      bottomOffset,
      size.height,
      bottomOffset,
      size.height - radius,
    );
    // 左邊斜線回到左上角
    path.lineTo(topOffset - radius, radius);
    // 左上圓角
    path.quadraticBezierTo(topOffset, 0, topOffset + radius, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
