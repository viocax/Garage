import 'package:equatable/equatable.dart';

import 'package:garage/core/models/near_speed_camera.dart';

sealed class SpeedEvent extends Equatable {
  const SpeedEvent();

  @override
  List<Object?> get props => [];
}

// 更新速度事件
final class UpdateSpeed extends SpeedEvent {
  final NearSpeedCamera nearSpeedCamera;

  const UpdateSpeed(this.nearSpeedCamera);

  @override
  List<Object?> get props => [nearSpeedCamera];
}

// 開始偵測
final class StartDetection extends SpeedEvent {
  const StartDetection();
}

// 停止偵測
final class StopDetection extends SpeedEvent {
  const StopDetection();
}
