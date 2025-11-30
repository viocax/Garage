import 'package:flutter_bloc/flutter_bloc.dart';
import 'launch_event.dart';
import 'launch_state.dart';
import 'package:flutter/material.dart';
import '../../../../core/core.dart';

class LaunchBloc extends Bloc<LaunchEvent, LaunchState> {
  final TickerProvider vsync;
  late final LaunchAnimationHolder animationHolder;

  LaunchBloc(this.vsync) : super(const LaunchInitializing()) {
    on<StartInitialization>(_onStartInitialization);
    animationHolder = LaunchAnimationHolder(vsync);
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
      debugPrint('LaunchBloc: 開始初始化...');

      // 取得 SpeedCamera Repository
      final speedCameraRepo = getIt.repo.speedCamera;

      // 載入測速照相資料
      debugPrint('LaunchBloc: 載入測速照相資料...');
      await speedCameraRepo.syncFromRemote();

      final count = await speedCameraRepo.getCount();
      debugPrint('LaunchBloc: 測速照相資料載入完成，共 $count 筆');

      // 等待動畫完成
      await Future.delayed(const Duration(seconds: 4));

      // 初始化完成
      debugPrint('LaunchBloc: 初始化完成');
      emit(const LaunchCompleted());
    } catch (e, stackTrace) {
      debugPrint('LaunchBloc: 初始化失敗 - $e');
      debugPrint('StackTrace: $stackTrace');
      emit(LaunchError('初始化失敗: $e'));
    }
  }
}

class LaunchAnimationHolder {
  final TickerProvider vsync;

  // 各種動畫控制器
  late AnimationController _gridController;
  late AnimationController _gradientController;
  late AnimationController _logoController;
  late AnimationController _carController;
  late AnimationController _speedLinesController;
  late AnimationController _speedLinesFadeController;
  late AnimationController _indicatorController;
  late AnimationController _taglineController;
  late AnimationController _underlineController;
  late AnimationController _carDrawController;

  // 動畫
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

  late double totolAnimationTime;

  LaunchAnimationHolder(this.vsync) {
    _setupAnimation();
    _startAnimationSequence();
  }

  // 公開速度線控制器供外部使用
  AnimationController get speedLinesController => _speedLinesController;

  void _setupAnimation() {
    // 初始化所有動畫控制器
    _gridController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1000),
    );

    _gradientController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1500),
    );

    _logoController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 800),
    );

    _carController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 500),
    );

    _speedLinesController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _speedLinesFadeController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 500),
    );

    _indicatorController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 500),
    );

    _taglineController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 800),
    );

    _underlineController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 600),
    );

    _carDrawController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 2000),
    );

    // 創建動畫
    gridOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _gridController, curve: Curves.easeOut));

    gradientOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _gradientController, curve: Curves.easeOut),
    );

    logoOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));

    logoScale = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    carOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _carController, curve: Curves.easeOut));

    speedLinesOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _speedLinesFadeController, curve: Curves.easeOut),
    );

    indicatorOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _indicatorController, curve: Curves.easeOut),
    );

    taglineOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );

    taglinePosition = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );

    underlineWidth = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _underlineController, curve: Curves.easeOut),
    );

    carDrawProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _carDrawController, curve: Curves.easeOut),
    );
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _gridController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _gradientController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _carController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _carDrawController.forward();

    await Future.delayed(const Duration(milliseconds: 100));
    _underlineController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    // 速度線控制器已在 initState 中設置為 repeat()，這裡只啟動淡入動畫
    _speedLinesFadeController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _indicatorController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _taglineController.forward();
  }

  void dispose() {
    _gridController.dispose();
    _gradientController.dispose();
    _logoController.dispose();
    _carController.dispose();
    _speedLinesController.dispose();
    _speedLinesFadeController.dispose();
    _indicatorController.dispose();
    _taglineController.dispose();
    _underlineController.dispose();
    _carDrawController.dispose();
  }
}
