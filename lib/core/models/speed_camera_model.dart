import 'package:flutter/material.dart';
import 'package:garage/core/utils/log.dart';

class SpeedCameraModel {
  int speedLimit;
  double currentSpeed;
  double distance;
  bool isOverSpeed;
  double latitude;
  double longitude;
  double heading; // 使用者行駛方向（0-360度）

  static const double maxSpeed = 300;

  SpeedCameraModel({
    required this.speedLimit,
    required this.currentSpeed,
    required this.distance,
    required this.isOverSpeed,
    required this.latitude,
    required this.longitude,
    this.heading = 0.0,
  });

  SpeedCameraModel copyWith({
    int? speedLimit,
    double? currentSpeed,
    double? distance,
    bool? isOverSpeed,
    double? latitude,
    double? longitude,
    double? heading,
  }) {
    return SpeedCameraModel(
      speedLimit: speedLimit ?? this.speedLimit,
      currentSpeed: currentSpeed ?? this.currentSpeed,
      distance: distance ?? this.distance,
      isOverSpeed: isOverSpeed ?? this.isOverSpeed,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      heading: heading ?? this.heading,
    );
  }

  // 根據速度計算動畫時長（速度越快，時長越短，動畫跑得越快）
  // 速度區間：0-10, 11-30, 31-60, 61-100, 101-150, 150+
  Duration calculateDuration() {
    if (currentSpeed == 0) {
      return Duration.zero;
    }
    // 你的持續時間範圍
    const int minDuration = 4700;
    const int maxDuration = 5200;
    double maxSpeed = SpeedCameraModel.maxSpeed;

    // --- 邏輯處理 ---

    // 1. 限制輸入速度，防止計算溢出 (例如速度為負數或超速)
    final double clampedSpeed = currentSpeed.clamp(0.0, maxSpeed);

    // 2. 計算速度比例 (speedRatio)，將速度映射到 [0.0, 1.0] 區間
    // 0.0 表示 0 km/h，1.0 表示 MAX_SPEED (200 km/h)
    final double speedRatio = clampedSpeed / maxSpeed;

    // 3. 進行線性插值 (Linear Interpolation, Lerp)

    // 由於你的數值設定是 (速度增加 -> Duration 增加)，
    // 我們直接從 MIN_DURATION_MS (4700) 開始，
    // 隨著 speedRatio 增加，持續時間線性遞增，直到 MAX_DURATION_MS (5200)。

    // 總持續時間變化量 (5200 - 4700 = 500)
    final double durationDifference = (maxDuration - minDuration).toDouble();

    // 計算最終持續時間
    // 最終結果將在 [4700.0, 5200.0] 之間平滑變化
    final double finalDuration =
        minDuration + (speedRatio * durationDifference);

    Log.d('SpeedBloc: finalDuration=$finalDuration');

    return Duration(milliseconds: finalDuration.toInt());
  }

}