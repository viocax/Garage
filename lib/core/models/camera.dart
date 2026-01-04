import 'dart:math';

/// 測速照相點位資料模型
class Camera {
  /// 測速照相機 ID
  final String id;

  /// 速限（公里/小時）
  final int speedLimit;

  /// WGS84 北緯度
  final double latitude;

  /// WGS84 東經度
  final double longitude;

  /// 方向
  final String direction;

  /// 描述（包含完整地址和方向）
  final String description;

  const Camera({
    required this.id,
    required this.speedLimit,
    required this.latitude,
    required this.longitude,
    required this.direction,
    required this.description,
  });

  /// 從 JSON 資料建立 Camera 物件
  factory Camera.fromJson(Map<String, dynamic> json) {
    return Camera(
      id: json['id'] as String? ?? '',
      speedLimit: json['lim'] as int? ?? 0,
      latitude: (json['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['lon'] as num?)?.toDouble() ?? 0.0,
      direction: json['dir'] as String? ?? '',
      description: json['disc'] as String? ?? '',
    );
  }

  /// 轉換為 JSON 格式
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lim': speedLimit,
      'lat': latitude,
      'lon': longitude,
      'dir': direction,
      'disc': description,
    };
  }

  /// 計算與指定座標的距離（公尺）
  double distanceTo(double lat, double lon) {
    const double earthRadius = 6371000; // 地球半徑（公尺）
    final double dLat = _toRadians(lat - latitude);
    final double dLon = _toRadians(lon - longitude);

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(latitude)) *
            cos(_toRadians(lat)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  /// 複製並修改部分屬性
  Camera copyWith({
    String? id,
    int? speedLimit,
    double? latitude,
    double? longitude,
    String? direction,
    String? description,
  }) {
    return Camera(
      id: id ?? this.id,
      speedLimit: speedLimit ?? this.speedLimit,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      direction: direction ?? this.direction,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Camera && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Camera(id: $id, speedLimit: $speedLimit km/h, direction: $direction, description: $description)';
  }
}
