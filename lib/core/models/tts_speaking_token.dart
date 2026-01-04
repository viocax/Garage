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
    String text = '前方 ${distance.toStringAsFixed(0)} 公尺， 限速 ${speedLimit.toStringAsFixed(0)} 公里， 目前速度 ${currentSpeed.toStringAsFixed(0)} 公里';
    if (currentSpeed > speedLimit) {
      text += '已超速';
    } else {
      text += '未超速，請注意';
    }
    return text;
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
