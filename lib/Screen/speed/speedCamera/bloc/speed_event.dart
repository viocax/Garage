import 'package:equatable/equatable.dart';
import 'package:garage/core/models/speed_camera_model.dart';

sealed class SpeedEvent extends Equatable {
  const SpeedEvent();

  @override
  List<Object?> get props => [];
}

// 初始化速度事件
final class SpeedLoading extends SpeedEvent {
  const SpeedLoading();
}

// 更新速度事件
final class UpdateSpeed extends SpeedEvent {
  final SpeedCameraModel speedCameraModel;

  const UpdateSpeed(this.speedCameraModel);

  // km/s
  double get currentSpeed => speedCameraModel.currentSpeed;

  @override
  List<Object?> get props => [speedCameraModel];
}

// 開始偵測
final class StartDetection extends SpeedEvent {
  const StartDetection();
}

// 停止偵測
final class StopDetection extends SpeedEvent {
  const StopDetection();
}
