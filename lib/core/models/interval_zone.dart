/// 區間測速路段資料模型
class IntervalZone {
  /// 區間 ID
  final String id;

  /// 起點相機 ID
  final String startCameraId;

  /// 終點相機 ID
  final String endCameraId;

  /// 區間總距離（公尺）
  final double distance;

  /// 速限（公里/小時）
  final int speedLimit;

  const IntervalZone({
    required this.id,
    required this.startCameraId,
    required this.endCameraId,
    required this.distance,
    required this.speedLimit,
  });

  /// 從 JSON 資料建立 IntervalZone 物件
  factory IntervalZone.fromJson(Map<String, dynamic> json) {
    return IntervalZone(
      id: json['id'] as String? ?? '',
      startCameraId: json['start_id'] as String? ?? '',
      endCameraId: json['end_id'] as String? ?? '',
      distance: (json['dist'] as num?)?.toDouble() ?? 0.0,
      speedLimit: json['lim'] as int? ?? 0,
    );
  }

  /// 轉換為 JSON 格式
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_id': startCameraId,
      'end_id': endCameraId,
      'dist': distance,
      'lim': speedLimit,
    };
  }

  /// 複製並修改部分屬性
  IntervalZone copyWith({
    String? id,
    String? startCameraId,
    String? endCameraId,
    double? distance,
    int? speedLimit,
  }) {
    return IntervalZone(
      id: id ?? this.id,
      startCameraId: startCameraId ?? this.startCameraId,
      endCameraId: endCameraId ?? this.endCameraId,
      distance: distance ?? this.distance,
      speedLimit: speedLimit ?? this.speedLimit,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IntervalZone && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'IntervalZone(id: $id, limit: $speedLimit, dist: $distance)';
  }
}
