import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

sealed class SpeedEvent extends Equatable {
  const SpeedEvent();

  @override
  List<Object?> get props => [];
}

// 更新速度事件
final class UpdateSpeed extends SpeedEvent {
  final Position position;

  const UpdateSpeed(this.position);

  double get currentSpeed => position.speed;

  @override
  List<Object?> get props => [position];
}

// 開始偵測
final class StartDetection extends SpeedEvent {
  const StartDetection();
}

// 停止偵測
final class StopDetection extends SpeedEvent {
  const StopDetection();
}
