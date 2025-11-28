import 'package:isar/isar.dart';
import 'dart:math';

part 'speed_camera.g.dart';

/// 測速照相點位資料模型（Isar Collection）
@collection
class SpeedCamera {
  Id id = Isar.autoIncrement; // Auto-increment ID

  @Index()
  late String code; // 編號

  @Index()
  late String roadNumber; // 道路編號

  @Index()
  late String direction; // 道路方向

  late double mileage; // 里程數（公里）

  @Index()
  late int speedLimit; // 速限（公里/小時）

  late double xCoordinate; // X座標
  late double yCoordinate; // Y座標

  @Index(type: IndexType.value)
  late double longitude; // WGS84 東經度

  @Index(type: IndexType.value)
  late double latitude; // WGS84 北緯度

  // 全文搜尋支援
  @Index(type: IndexType.value, caseSensitive: false)
  String? remarks; // 備註

  late DateTime lastUpdated; // 最後更新時間

  /// 從 CSV 行資料建立 SpeedCamera 物件
  static SpeedCamera fromCsvRow(List<String> row) {
    return SpeedCamera()
      ..code = row[1]
      ..roadNumber = row[2]
      ..direction = row[3]
      ..mileage = double.tryParse(row[4]) ?? 0.0
      ..speedLimit = int.tryParse(row[5]) ?? 0
      ..xCoordinate = double.tryParse(row[6]) ?? 0.0
      ..yCoordinate = double.tryParse(row[7]) ?? 0.0
      ..longitude = double.tryParse(row[8]) ?? 0.0
      ..latitude = double.tryParse(row[9]) ?? 0.0
      ..remarks = row.length > 10 ? row[10] : null
      ..lastUpdated = DateTime.now();
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
    return 'SpeedCamera(code: $code, road: $roadNumber $direction, mileage: $mileage km, speedLimit: $speedLimit km/h)';
  }
}
