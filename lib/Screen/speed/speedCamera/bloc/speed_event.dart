import 'package:equatable/equatable.dart';

sealed class SpeedEvent extends Equatable {
  const SpeedEvent();

  @override
  List<Object?> get props => []; 
}

// 更新速度事件
final class UpdateSpeed extends SpeedEvent {
  final double speed;

  const UpdateSpeed(this.speed);

  @override
  List<Object?> get props => [speed];
}
