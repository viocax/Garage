import 'package:garage/core/utils/auto_release_queue.dart';

/// TTS 播报状态令牌
///
/// 用于追踪和控制超速警告的播报频率，防止高频重复播报
/// 实现 QueueableItem 接口，可以直接放入 AutoReleaseQueue 中执行
class TTSSpeakingToken implements QueueableItem {
  /// 当前速度 (km/h)
  final double currentSpeed;

  /// 速度限制 (km/h)
  final double speedLimit;

  /// 距离测速相机的距离 (米)
  final double distance;

  /// 上次播报时间
  final DateTime lastReportTime;

  /// 执行回调函数（可选）
  final Future<void> Function(TTSSpeakingToken)? _onExecute;

  const TTSSpeakingToken({
    required this.currentSpeed,
    required this.speedLimit,
    required this.distance,
    required this.lastReportTime,
    Future<void> Function(TTSSpeakingToken)? onExecute,
  }) : _onExecute = onExecute;

  /// 实现 QueueableItem 接口的 execute 方法
  @override
  Future<void> execute() async {
    if (_onExecute != null) {
      await _onExecute(this);
    }
  }

  /// 判断是否应该重新播报
  ///
  /// 条件：
  /// 1. 冷却时间已过
  /// 2. 速度变化超过阈值
  /// 3. 距离变化超过阈值（可选）
  ///
  /// [nextToken] 下一个要播报的令牌
  bool shouldSpeak(
    TTSSpeakingToken nextToken, {
    Duration cooldown = const Duration(seconds: 5),
    double speedThreshold = 10.0,
    double distanceThreshold = 100.0,
  }) {
    final timeSinceLastReport = nextToken.lastReportTime.difference(lastReportTime);

    // 1. 检查冷却时间
    if (timeSinceLastReport < cooldown) {
      return false;
    }

    // 2. 检查速度限制是否改变（进入不同测速区域）
    if (nextToken.speedLimit != speedLimit) {
      return true;
    }

    // 3. 检查速度变化是否显著
    final speedDiff = (nextToken.currentSpeed - currentSpeed).abs();
    if (speedDiff < speedThreshold) {
      return false;
    }

    // 4. 检查距离变化是否显著
    final distanceDiff = (nextToken.distance - distance).abs();
    if (distanceDiff < distanceThreshold) {
      return false;
    }

    return true;
  }

  /// 创建新的令牌副本
  TTSSpeakingToken copyWith({
    double? currentSpeed,
    double? speedLimit,
    double? distance,
    DateTime? lastReportTime,
    Future<void> Function(TTSSpeakingToken)? onExecute,
  }) {
    return TTSSpeakingToken(
      currentSpeed: currentSpeed ?? this.currentSpeed,
      speedLimit: speedLimit ?? this.speedLimit,
      distance: distance ?? this.distance,
      lastReportTime: lastReportTime ?? this.lastReportTime,
      onExecute: onExecute ?? _onExecute,
    );
  }

  @override
  String toString() {
    return 'TTSSpeakingToken(currentSpeed: $currentSpeed, speedLimit: $speedLimit, '
        'distance: $distance, lastReportTime: $lastReportTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TTSSpeakingToken &&
        other.currentSpeed == currentSpeed &&
        other.speedLimit == speedLimit &&
        other.distance == distance &&
        other.lastReportTime == lastReportTime;
  }

  @override
  int get hashCode {
    return currentSpeed.hashCode ^
        speedLimit.hashCode ^
        distance.hashCode ^
        lastReportTime.hashCode;
  }
}
