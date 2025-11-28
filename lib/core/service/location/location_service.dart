import 'package:geolocator/geolocator.dart';
import 'package:garage/core/service/location/geolocator_interface.dart';

class LocationService {
  final GeolocatorInterface geolocator;

  LocationService({this.geolocator = const GeolocatorWrapper()});

  /// 檢查並請求定位權限
  Future<bool> _handlePermission() async {
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
    final hasPermission = await _handlePermission();
    if (!hasPermission) {
      return null;
    }

    return await geolocator.getCurrentPosition();
  }

  /// 監聽位置變化
  Stream<Position> getPositionStream({LocationSettings? locationSettings}) {
    return geolocator.getPositionStream(locationSettings: locationSettings);
  }
}
