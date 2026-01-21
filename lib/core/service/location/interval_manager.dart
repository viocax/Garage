import 'package:garage/core/models/interval_zone.dart';

/// 區間測速狀態模型
class IntervalStatus {
  /// 當前平均速度
  final double averageSpeed;

  /// 剩餘距離（公尺）
  final double remainingDistance;

  /// 是否超速
  final bool isOverSpeed;

  /// 已行駛距離（公尺）
  final double distanceTraveled;

  /// 已行駛時間（秒）
  final int timeElapsed;

  const IntervalStatus({
    required this.averageSpeed,
    required this.remainingDistance,
    required this.isOverSpeed,
    required this.distanceTraveled,
    required this.timeElapsed,
  });
}

/// 區間測速邏輯管理器
class IntervalManager {
  IntervalZone? _currentZone;
  DateTime? _startTime;
  
  /// 是否正在區間測速中
  bool get isActive => _currentZone != null;

  /// 當前區間
  IntervalZone? get currentZone => _currentZone;

  /// 進入區間
  void enterZone(IntervalZone zone, {DateTime? startTime}) {
    _currentZone = zone;
    _startTime = startTime ?? DateTime.now();
  }

  /// 離開區間
  void exitZone() {
    _currentZone = null;
    _startTime = null;
  }

  /// 計算當前狀態
  /// 
  /// [distanceTraveled] 從起點至今行駛的距離（公尺）
  /// [currentTime] 當前時間
  IntervalStatus calculateStatus({
    required double distanceTraveled,
    DateTime? currentTime,
  }) {
    if (_currentZone == null || _startTime == null) {
      return const IntervalStatus(
        averageSpeed: 0,
        remainingDistance: 0,
        isOverSpeed: false,
        distanceTraveled: 0,
        timeElapsed: 0,
      );
    }

    final now = currentTime ?? DateTime.now();
    final seconds = now.difference(_startTime!).inSeconds;
    
    // 防止除以 0
    if (seconds <= 0) {
      return IntervalStatus(
        averageSpeed: 0,
        remainingDistance: _currentZone!.distance - distanceTraveled,
        isOverSpeed: false,
        distanceTraveled: distanceTraveled,
        timeElapsed: 0,
      );
    }

    // 平均速度 (km/h) = (距離/1000) / (秒數/3600)
    final double avgSpeed = (distanceTraveled / 1000.0) / (seconds / 3600.0);
    final double remaining = _currentZone!.distance - distanceTraveled;
    final bool overSpeed = avgSpeed > _currentZone!.speedLimit;

    return IntervalStatus(
      averageSpeed: avgSpeed,
      remainingDistance: remaining,
      isOverSpeed: overSpeed,
      distanceTraveled: distanceTraveled,
      timeElapsed: seconds,
    );
  }
}
