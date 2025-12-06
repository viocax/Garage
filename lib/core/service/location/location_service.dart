import 'package:geolocator/geolocator.dart';
import 'package:garage/core/service/location/geolocator_interface.dart';

/// 經緯度資料類別
class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);

  @override
  String toString() => 'LatLng($latitude, $longitude)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LatLng &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}

class LocationService {
  final GeolocatorInterface geolocator;

  LocationService({
    this.geolocator = const GeolocatorWrapper(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1, // 更新距離閾值（公尺）
      ),
    ),
  });

  /// 檢查並請求定位權限
  Future<bool> requestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 檢查定位服務是否開啟
    serviceEnabled = await geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 定位服務未開啟，無法使用
      return false;
    }

    permission = await geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // 權限被拒絕
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // 權限被永久拒絕，無法請求
      return false;
    }

    return true;
  }

  /// 取得目前位置
  ///
  /// 如果權限不足或服務未開啟，可能拋出異常或返回 null
  Future<Position?> getCurrentPosition() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) {
      return null;
    }

    return await geolocator.getCurrentPosition();
  }

  /// 監聽位置變化
  Stream<Position> getPositionStream() {
    return geolocator.getPositionStream();
  }

  /// 取得目前 GPS 速度（單位：公尺/秒）
  ///
  /// 返回當前速度，如果無法取得則返回 null
  Future<double?> getCurrentSpeed() async {
    final position = await getCurrentPosition();
    return position?.speed;
  }

  /// 取得目前 GPS 速度（單位：公里/小時）
  ///
  /// 返回當前速度，如果無法取得則返回 null
  Future<double?> getCurrentSpeedKmh() async {
    final speed = await getCurrentSpeed();
    if (speed == null) return null;
    // 1 m/s = 3.6 km/h
    return speed * 3.6;
  }

  /// 取得目前位置的經緯度
  ///
  /// 返回 LatLng 物件，如果無法取得則返回 null
  Future<LatLng?> getCurrentLatLng() async {
    final position = await getCurrentPosition();
    if (position == null) return null;
    return LatLng(position.latitude, position.longitude);
  }

  /// 監聽速度變化（單位：公尺/秒）
  // Stream<double> getSpeedStream() {
  //   return getPositionStream().map((position) => position.speed);
  // }

  // /// 監聽速度變化（單位：公里/小時）
  // Stream<double> getSpeedKmhStream() {
  //   return getPositionStream().map((position) => position.speed * 3.6);
  // }

  // /// 監聽經緯度變化
  // Stream<LatLng> getLatLngStream() {
  //   return getPositionStream().map((position) => LatLng(position.latitude, position.longitude));
  // }
}
