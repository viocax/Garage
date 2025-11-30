import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'speed_event.dart';
import 'speed_state.dart';

class SpeedBloc extends Bloc<SpeedEvent, SpeedState> {
  // TODO: maxSpeed and unit and lower and upper，到時候會在設定方式注入進來
  SpeedBloc()
    : super(
        const SpeedData(
          speed: 0.0,
          animationDuration: Duration(milliseconds: 5300),
          unit: 'km/h',
          maxSpeed: 300,
          lowerSpeed: '110',
          upperSpeed: '120',
        ),
      ) {
    // on<UpdateSpeed>(_onUpdateSpeed);
    on<StartDetection>(_onStartDetection);
    on<StopDetection>(_onStopDetection);
  }

  void _onUpdateSpeed(UpdateSpeed event, Emitter<SpeedState> emit) {
    final currentState = state;
    if (currentState is! SpeedData) return;

    final newSpeed = event.speed;
    final newDuration = _calculateDuration(newSpeed);
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

  void _onStartDetection(StartDetection event, Emitter<SpeedState> emit) {
    final currentState = state;
    if (currentState is! SpeedData) return;

    // TODO: check location permission;
    // TODO: start location tracking;
    // TODO: handler error;

    debugPrint('SpeedBloc: 開始偵測');

    final newSpeed = 150.0;
    final newDuration = _calculateDuration(newSpeed);
    final isOverSpeed = _checkOverSpeed(newSpeed, currentState.upperSpeed);

    emit(
      currentState.copyWith(
        speed: newSpeed,
        animationDuration: newDuration,
        isOverSpeed: isOverSpeed,
        isDetecting: true,
      ),
    );
  }

  void _onStopDetection(StopDetection event, Emitter<SpeedState> emit) {
    final currentState = state;
    if (currentState is! SpeedData) return;

    debugPrint('SpeedBloc: 停止偵測');

    emit(currentState.copyWith(speed: 0, isOverSpeed: false, isDetecting: false));
  }

  // 檢查是否超速
  bool _checkOverSpeed(double currentSpeed, String? upperSpeedLimit) {
    if (upperSpeedLimit == null) return false;
    final limit = double.tryParse(upperSpeedLimit);
    if (limit == null) return false;
    return currentSpeed > limit;
  }

  // 根據速度計算動畫時長（速度越快，時長越長）
  // 每 25 單位變換一個數值：4.6, 4.7, 4.8, 4.9, 5.0, 5.1, 5.2, 5.3 秒
  Duration _calculateDuration(double speed) {
    if (speed == 0) {
      return Duration.zero;
    }

    // 將速度四捨五入到最近的 25 倍數
    final roundedSpeed = (speed / 25).round() * 25.0;

    // 8 個區間：0, 25, 50, 75, 100, 125, 150, 175
    // 對應：4600, 4700, 4800, 4900, 5000, 5100, 5200, 5300 ms
    final durationMs = 4600 + (roundedSpeed / 25 * 100);
    debugPrint('SpeedBloc: durationMs=$durationMs');

    return Duration(milliseconds: durationMs.clamp(4600, 5300).toInt());
  }
}
