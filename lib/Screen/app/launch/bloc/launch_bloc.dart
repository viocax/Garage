import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:garage/core/utils/log.dart';
import 'launch_event.dart';
import 'launch_state.dart';

class LaunchBloc extends Bloc<LaunchEvent, LaunchState> {
  final TickerProvider vsync;
  late final LaunchAnimationHolder animationHolder;

  LaunchBloc({
    required this.vsync,
    LaunchAnimationHolder? animationHolder,
  }) : super(const LaunchInitializing()) {
    on<StartInitialization>(_onStartInitialization);
    this.animationHolder = animationHolder ?? LaunchAnimationHolder(vsync);
    add(const StartInitialization());
  }

  @override
  Future<void> close() {
    animationHolder.dispose();
    return super.close();
  }

  Future<void> _onStartInitialization(
    StartInitialization event,
    Emitter<LaunchState> emit,
  ) async {
    try {
      // 等待動畫完成
      await animationHolder.animationCompleted;
      emit(const LaunchCompleted());
    } catch (e, stackTrace) {
      Log.e('LaunchBloc: 初始化失敗', e, stackTrace);
      emit(LaunchError('初始化失敗: $e'));
    }
  }
}

class LaunchAnimationHolder {
  final TickerProvider vsync;

  // 動畫完成通知
  final Completer<void> _animationCompleter = Completer<void>();
  Future<void> get animationCompleted => _animationCompleter.future;

  // 主動畫控制器 (Staggered Animation Controller)
  late AnimationController _mainController;

  // 獨立控制器 (需要 Loop 的動畫)
  late AnimationController _speedLinesLoopController;

  // 動畫值
  late Animation<double> gridOpacity;
  late Animation<double> gradientOpacity;
  late Animation<double> logoOpacity;
  late Animation<double> logoScale;
  late Animation<double> carOpacity;
  late Animation<double> speedLinesOpacity;
  late Animation<double> indicatorOpacity;
  late Animation<double> taglineOpacity;
  late Animation<double> taglinePosition;
  late Animation<double> underlineWidth;
  late Animation<double> carDrawProgress;

  LaunchAnimationHolder(this.vsync) {
    _setupAnimation();
    _startAnimation();
  }

  // 公開速度線控制器供外部使用 (Loop 動畫)
  AnimationController get speedLinesController => _speedLinesLoopController;
  // 公開主控制器 (如果需要)
  AnimationController get mainController => _mainController;

  void _setupAnimation() {
    // 1. 初始化主控制器
    // 總時長計算：將原本所有的 delay 與 duration 加總估算
    // 0.2(start) + 1.0(grid) ... 實際上因為是並行/交錯，我們設定一個合理的總時長，例如 3.5秒
    _mainController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 3500),
    );

    // 2. 初始化循環控制器 (因為它要一直跑，不適合放在主時間軸)
    _speedLinesLoopController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // 3. 定義 Staggered Animations (使用 Interval)
    // 為了方便調整，這裡將時間歸一化到 0.0 ~ 1.0
    // 假設總長 3500ms

    // Grid: 200ms 開始, 持續 1000ms -> 0.05 ~ 0.35
    gridOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.05, 0.35, curve: Curves.easeOut),
      ),
    );

    // Gradient: 500ms 開始, 持續 1500ms -> 0.15 ~ 0.6
    gradientOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.15, 0.6, curve: Curves.easeOut),
      ),
    );

    // Logo: 800ms 開始, 持續 800ms -> 0.23 ~ 0.46
    logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.23, 0.46, curve: Curves.easeOut),
      ),
    );

    logoScale = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.23, 0.46, curve: Curves.easeOutBack),
      ),
    );

    // Car: 1200ms 開始, 持續 500ms -> 0.34 ~ 0.49
    carOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.34, 0.49, curve: Curves.easeOut),
      ),
    );

    // Car Draw: 1400ms 開始, 持續 2000ms -> 0.4 ~ 0.97
    carDrawProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.97, curve: Curves.easeOut),
      ),
    );

    // Underline: 1500ms 開始, 持續 600ms -> 0.43 ~ 0.6
    underlineWidth = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.43, 0.6, curve: Curves.easeOut),
      ),
    );

    // Speed Lines Fade: 2000ms 開始, 持續 500ms -> 0.57 ~ 0.71
    speedLinesOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.57, 0.71, curve: Curves.easeOut),
      ),
    );

    // Indicator: 2200ms 開始, 持續 500ms -> 0.63 ~ 0.77
    indicatorOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.63, 0.77, curve: Curves.easeOut),
      ),
    );

    // Tagline: 2500ms 開始, 持續 800ms -> 0.71 ~ 0.94
    taglineOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.71, 0.94, curve: Curves.easeOut),
      ),
    );

    taglinePosition = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.71, 0.94, curve: Curves.easeOut),
      ),
    );
  }

  void _startAnimation() {
    _mainController.forward();

    // 監聽動畫完成
    _mainController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!_animationCompleter.isCompleted) {
          _animationCompleter.complete();
        }
      }
    });
  }

  void dispose() {
    _mainController.dispose();
    _speedLinesLoopController.dispose();
  }
}
