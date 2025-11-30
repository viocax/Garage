sealed class SpeedState {
  const SpeedState();
}

// 速度數據狀態
final class SpeedData extends SpeedState {
  final double speed; // 當前速度
  final Duration animationDuration; // 動畫時長
  final String unit; // 速度單位
  final double maxSpeed;
  final String? lowerSpeed; // 最低速限
  final String? upperSpeed; // 最高速限
  final bool isOverSpeed; // 是否超速
  final bool isDetecting; // 是否正在偵測

  const SpeedData({
    required this.speed,
    required this.animationDuration,
    required this.unit,
    required this.maxSpeed,
    this.lowerSpeed,
    this.upperSpeed,
    this.isOverSpeed = false,
    this.isDetecting = false,
  });

  SpeedData copyWith({
    double? speed,
    Duration? animationDuration,
    String? unit,
    double? maxSpeed,
    String? lowerSpeed,
    String? upperSpeed,
    bool? isOverSpeed,
    bool? isDetecting,
  }) {
    return SpeedData(
      speed: speed ?? this.speed,
      animationDuration: animationDuration ?? this.animationDuration,
      unit: unit ?? this.unit,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      lowerSpeed: lowerSpeed ?? this.lowerSpeed,
      upperSpeed: upperSpeed ?? this.upperSpeed,
      isOverSpeed: isOverSpeed ?? this.isOverSpeed,
      isDetecting: isDetecting ?? this.isDetecting,
    );
  }
}
