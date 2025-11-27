import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'speed_event.dart';
import 'speed_state.dart';

class SpeedBloc extends Bloc<SpeedEvent, SpeedState> {
  SpeedBloc()
      : super(const SpeedState(
          speed: 0.0,
          animationDuration: Duration(milliseconds: 5300),
        )) {
    on<UpdateSpeed>(_onUpdateSpeed);
  }

  void _onUpdateSpeed(UpdateSpeed event, Emitter<SpeedState> emit) {
    final newSpeed = event.speed;
    final newDuration = _calculateDuration(newSpeed);

    debugPrint(
      'SpeedBloc: update speed=$newSpeed, duration=$newDuration',
    );

    emit(SpeedState(
      speed: newSpeed,
      animationDuration: newDuration,
    ));
  }

  // 根據速度計算動畫時長（速度越快，時長越短）
  // 每 25 單位變換一個數值：5.3, 5.2, 5.1, 5.0, 4.9, 4.8, 4.7, 4.6 秒
  Duration _calculateDuration(double speed) {
    if (speed == 0) {
      return Duration.zero;
    }

    // 將速度四捨五入到最近的 25 倍數
    final roundedSpeed = (speed / 25).round() * 25.0;

    // 8 個區間：0, 25, 50, 75, 100, 125, 150, 175
    // 對應：5300, 5200, 5100, 5000, 4900, 4800, 4700, 4600 ms
    final durationMs = 5300 - (roundedSpeed / 25 * 100);

    return Duration(milliseconds: durationMs.clamp(4600, 5300).toInt());
  }
}
