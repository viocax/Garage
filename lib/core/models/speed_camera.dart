// import 'package:isar/isar.dart'; // MARK: Isar 暫時不使用
import 'dart:math';

// part 'speed_camera.g.dart'; // MARK: Isar 暫時不使用

/// 測速照相點位資料模型
// @collection // MARK: Isar 暫時不使用
class SpeedCamera {
  // Id id = Isar.autoIncrement; // Auto-increment ID // MARK: Isar 暫時不使用

  // @Index(type: IndexType.value, caseSensitive: false) // MARK: Isar 暫時不使用
  late String cityName; // 城市名稱

  // @Index(type: IndexType.value, caseSensitive: false) // MARK: Isar 暫時不使用
  late String regionName; // 地區名稱

  // @Index(type: IndexType.value, caseSensitive: false) // MARK: Isar 暫時不使用
  late String address; // 地址

  late String deptName; // 部門名稱

  late String branchName; // 分局名稱

  // @Index(type: IndexType.value) // MARK: Isar 暫時不使用
  late double longitude; // WGS84 東經度

  // @Index(type: IndexType.value) // MARK: Isar 暫時不使用
  late double latitude; // WGS84 北緯度

  // @Index() // MARK: Isar 暫時不使用
  late String direction; // 方向

  // @Index() // MARK: Isar 暫時不使用
  late int speedLimit; // 速限（公里/小時）

  late DateTime lastUpdated; // 最後更新時間

  /// 預設 constructor
  SpeedCamera();

  /// 從 JSON 資料建立 SpeedCamera 物件
  factory SpeedCamera.fromJson(Map<String, dynamic> json) {
    return SpeedCamera()
      ..cityName = json['CityName'] ?? ''
      ..regionName = json['RegionName'] ?? ''
      ..address = json['Address'] ?? ''
      ..deptName = json['DeptNm'] ?? ''
      ..branchName = json['BranchNm'] ?? ''
      ..longitude = (json['Longitude'] as num?)?.toDouble() ?? 0.0
      ..latitude = (json['Latitude'] as num?)?.toDouble() ?? 0.0
      ..direction = json['direct'] ?? ''
      ..speedLimit = int.tryParse(json['limitspeed']?.toString() ?? '0') ?? 0
      ..lastUpdated = DateTime.now();
  }

  /// 轉換為 JSON 格式
  Map<String, dynamic> toJson() {
    return {
      'CityName': cityName,
      'RegionName': regionName,
      'Address': address,
      'DeptNm': deptName,
      'BranchNm': branchName,
      'Longitude': longitude,
      'Latitude': latitude,
      'direct': direction,
      'limitspeed': speedLimit.toString(),
    };
  }

  /// 計算與指定座標的距離（公尺）
  double distanceTo(double lat, double lon) {
    const double earthRadius = 6371000; // 地球半徑（公尺）
    final double dLat = _toRadians(lat - latitude);
    final double dLon = _toRadians(lon - longitude);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
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

  @override
  String toString() {
    return 'SpeedCamera(city: $cityName, region: $regionName, address: $address, direction: $direction, speedLimit: $speedLimit km/h)';
  }
}
