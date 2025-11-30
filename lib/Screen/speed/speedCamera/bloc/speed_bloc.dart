import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/core/core.dart';
import 'package:garage/core/repositories/speed_camera_repository.dart';
import 'package:garage/core/models/speed_unit.dart';
import 'speed_event.dart';
import 'speed_state.dart';

class SpeedBloc extends Bloc<SpeedEvent, SpeedState> {
  final ISpeedCameraRepository repository = getIt.repo.speedCamera;
  StreamSubscription<double>? _speedSubscription;

  // TODO: maxSpeed and unit and lower and upper，到時候會在設定方式注入進來
  SpeedBloc()
    : super(
        const SpeedData(
          speed: 0.0,
          animationDuration: Duration(milliseconds: 5300),
          unit: SpeedUnit.kmh,
          maxSpeed: 300,
          lowerSpeed: '110',
          upperSpeed: '120',
        ),
      ) {
    on<UpdateSpeed>(_onUpdateSpeed);
    on<StartDetection>(_onStartDetection);
    on<StopDetection>(_onStopDetection);
  }

  void _onUpdateSpeed(UpdateSpeed event, Emitter<SpeedState> emit) {
    final currentState = state;
    if (currentState is! SpeedData) return;

    final newSpeed = event.speed;
    final newDuration = _calculateDuration(newSpeed, currentState.maxSpeed);
    final isOverSpeed = _checkOverSpeed(newSpeed, currentState.upperSpeed);

    debugPrint(
      'SpeedBloc: update speed=$newSpeed, duration=$newDuration, isOverSpeed=$isOverSpeed',
    );

    emit(
      currentState.copyWith(
        speed: newSpeed,
        animationDuration: newDuration,
        isOverSpeed: isOverSpeed,
      ),
    );
  }

  Future<void> _onStartDetection(
    StartDetection event,
    Emitter<SpeedState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SpeedData) return;

    try {
      // 1. 檢查定位權限（通過 Repository）
      final location = await repository.getCurrentLocation();
      if (location == null) {
        debugPrint('SpeedBloc: 定位權限被拒絕或服務未開啟');
        return;
      }

      debugPrint('SpeedBloc: 開始偵測');

      // 2. 開始位置追蹤（通過 Repository）
      _speedSubscription = repository.getSpeedStream().listen(
        (speed) {
          add(UpdateSpeed(speed));
        },
        onError: (error) {
          debugPrint('SpeedBloc: 速度追蹤錯誤 - $error');
          add(const StopDetection());
        },
      );

      // 更新狀態為偵測中
      emit(currentState.copyWith(isDetecting: true));
    } catch (e) {
      // 3. 處理錯誤
      debugPrint('SpeedBloc: 啟動偵測失敗 - $e');
      emit(currentState.copyWith(isDetecting: false));
    }
  }

  Future<void> _onStopDetection(
    StopDetection event,
    Emitter<SpeedState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SpeedData) return;

    debugPrint('SpeedBloc: 停止偵測');

    // 取消訂閱
    await _speedSubscription?.cancel();
    _speedSubscription = null;

    emit(
      currentState.copyWith(speed: 0, isOverSpeed: false, isDetecting: false),
    );
  }

  // 檢查是否超速
  bool _checkOverSpeed(double currentSpeed, String? upperSpeedLimit) {
    if (upperSpeedLimit == null) return false;
    final limit = double.tryParse(upperSpeedLimit);
    if (limit == null) return false;
    return currentSpeed > limit;
  }

  // 根據速度計算動畫時長（速度越快，時長越短，動畫跑得越快）
  // 速度區間：0-10, 11-30, 31-60, 61-100, 101-150, 150+
  Duration _calculateDuration(double speed, double maxSpeed) {
    if (speed == 0) {
      return Duration.zero;
    }
    // 你的持續時間範圍
    const int minDuration = 4700;
    const int maxDuration = 5200;

    // --- 邏輯處理 ---

    // 1. 限制輸入速度，防止計算溢出 (例如速度為負數或超速)
    final double clampedSpeed = speed.clamp(0.0, maxSpeed);

    // 2. 計算速度比例 (speedRatio)，將速度映射到 [0.0, 1.0] 區間
    // 0.0 表示 0 km/h，1.0 表示 MAX_SPEED (200 km/h)
    final double speedRatio = clampedSpeed / maxSpeed;

    // 3. 進行線性插值 (Linear Interpolation, Lerp)

    // 由於你的數值設定是 (速度增加 -> Duration 增加)，
    // 我們直接從 MIN_DURATION_MS (4700) 開始，
    // 隨著 speedRatio 增加，持續時間線性遞增，直到 MAX_DURATION_MS (5200)。

    // 總持續時間變化量 (5200 - 4700 = 500)
    final double durationDifference = (maxDuration - minDuration).toDouble();

    // 計算最終持續時間
    // 最終結果將在 [4700.0, 5200.0] 之間平滑變化
    final double finalDuration =
        minDuration + (speedRatio * durationDifference);

    debugPrint('SpeedBloc: finalDuration=$finalDuration');

    return Duration(milliseconds: finalDuration.toInt());
  }

  @override
  Future<void> close() {
    _speedSubscription?.cancel();
    return super.close();
  }
}
