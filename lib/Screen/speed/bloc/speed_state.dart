import 'package:equatable/equatable.dart';

class SpeedState extends Equatable {
  final double speed; // 當前速度
  final Duration animationDuration; // 動畫時長

  const SpeedState({
    required this.speed,
    required this.animationDuration,
  });

  @override
  List<Object?> get props => [speed, animationDuration];

  SpeedState copyWith({
    double? speed,
    Duration? animationDuration,
  }) {
    return SpeedState(
      speed: speed ?? this.speed,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }
}
