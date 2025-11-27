sealed class SpeedState {
  const SpeedState();
}

// 速度數據狀態
final class SpeedData extends SpeedState {
  final double speed; // 當前速度
  final Duration animationDuration; // 動畫時長
  final String unit; // 速度單位
  final String? lowerSpeed; // 最低速限
  final String? upperSpeed; // 最高速限

  const SpeedData({
    required this.speed,
    required this.animationDuration,
    required this.unit,
    this.lowerSpeed,
    this.upperSpeed,
  });

  SpeedData copyWith({
    double? speed,
    Duration? animationDuration,
    String? unit,
    String? lowerSpeed,
    String? upperSpeed,
  }) {
    return SpeedData(
      speed: speed ?? this.speed,
      animationDuration: animationDuration ?? this.animationDuration,
      unit: unit ?? this.unit,
      lowerSpeed: lowerSpeed ?? this.lowerSpeed,
      upperSpeed: upperSpeed ?? this.upperSpeed,
    );
  }
}
