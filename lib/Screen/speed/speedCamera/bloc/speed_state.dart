import 'package:garage/core/models/speed_unit.dart';

sealed class SpeedState {
  const SpeedState();
}

// 位置數據
class LocationData {
  final double latitude;
  final double longitude;

  const LocationData({
    required this.latitude,
    required this.longitude,
  });
}

// 速度數據狀態
final class SpeedData extends SpeedState {
  final double speed; // 當前速度
  final Duration animationDuration; // 動畫時長
  final SpeedUnit unit; // 速度單位
  final String? lowerSpeed; // 最低速限
  final String? upperSpeed; // 最高速限
  final bool isOverSpeed; // 是否超速
  final bool isDetecting; // 是否正在偵測
  final LocationData? currentLocation; // 當前位置

  const SpeedData({
    required this.speed,
    required this.animationDuration,
    required this.unit,
    this.lowerSpeed,
    this.upperSpeed,
    this.isOverSpeed = false,
    this.isDetecting = false,
    this.currentLocation,
  });

  SpeedData copyWith({
    double? speed,
    Duration? animationDuration,
    SpeedUnit? unit,
    String? lowerSpeed,
    String? upperSpeed,
    bool? isOverSpeed,
    bool? isDetecting,
    LocationData? currentLocation,
  }) {
    return SpeedData(
      speed: speed ?? this.speed,
      animationDuration: animationDuration ?? this.animationDuration,
      unit: unit ?? this.unit,
      lowerSpeed: lowerSpeed ?? this.lowerSpeed,
      upperSpeed: upperSpeed ?? this.upperSpeed,
      isOverSpeed: isOverSpeed ?? this.isOverSpeed,
      isDetecting: isDetecting ?? this.isDetecting,
      currentLocation: currentLocation ?? this.currentLocation,
    );
  }
}
