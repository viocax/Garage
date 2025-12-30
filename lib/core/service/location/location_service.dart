import 'dart:async';
import 'package:flutter/foundation.dart';
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

enum LocationPolicy { best, background, hightSpeed }

class LocationService {
  GeolocatorInterface? _geolocator;
  int _currentDistanceFilter = 0;
  StreamSubscription<Position>? _geolocatorSubscription;
  StreamController<Position>? _positionController;

  LocationService({GeolocatorInterface? geolocator}) {
    _geolocator = geolocator;
    _currentDistanceFilter = 0; // 初始設為0以在靜止時也能收到更新
  }

  /// 取得或創建 GeolocatorInterface
  GeolocatorInterface get geolocator {
    _geolocator ??= GeolocatorWrapper(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: _currentDistanceFilter,
      ),
    );
    return _geolocator!;
  }

  /// 根據當前速度更新 distanceFilter（內部自動調用）
  ///
  /// 速度範圍與對應的 distanceFilter：
  /// - 0-10 km/h: 0m (頻繁更新，確保低速時響應快)
  /// - 10-30 km/h: 5m (中低速)
  /// - 30-60 km/h: 10m (中速)
  /// - >60 km/h: 20m (高速，節省電池)
  void _updateDistanceFilterBySpeed(double speedKmh) {
    final int newFilter;
    if (speedKmh < 10) {
      newFilter = 0;
    } else if (speedKmh < 30) {
      newFilter = 5;
    } else if (speedKmh < 60) {
      newFilter = 10;
    } else {
      newFilter = 20;
    }

    // 如果 distanceFilter 需要改變，重新創建 stream
    if (newFilter != _currentDistanceFilter) {
      final oldFilter = _currentDistanceFilter;
      _currentDistanceFilter = newFilter;
      debugPrint(
        'LocationService: 速度 ${speedKmh.toStringAsFixed(1)} km/h，'
        'distanceFilter 從 ${oldFilter}m 調整為 ${newFilter}m',
      );
      _recreateGeolocatorStream();
    }
  }

  /// 重新創建 geolocator stream（使用新的 distanceFilter）
  void _recreateGeolocatorStream() {
    if (_positionController == null || _positionController!.isClosed) {
      return; // 沒有活動的 stream，不需要重建
    }

    // 創建新的 geolocator（使用新的 distanceFilter）
    _geolocator = GeolocatorWrapper(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: _currentDistanceFilter,
      ),
    );

    // 重新訂閱
    _subscribeToGeolocator();
  }

  Future<bool> checkPermission() async {
    final permission = await geolocator.checkPermission();
    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return true;
      default:
        return false;
    }
  }

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

  /// 監聯位置變化
  ///
  /// 返回一個可以動態調整 distanceFilter 的位置 stream
  Stream<Position> getPositionStream() {
    if (_positionController != null && !_positionController!.isClosed) {
      return _positionController!.stream;
    }

    // 創建新的 StreamController
    _positionController = StreamController<Position>.broadcast(
      onListen: () {
        if (_geolocatorSubscription == null) {
          _subscribeToGeolocator();
        }
      },
      onCancel: () {
        // 當所有訂閱者都取消時，停止底層的 geolocator 訂閱
        _geolocatorSubscription?.cancel();
        _geolocatorSubscription = null;
      },
    );

    return _positionController!.stream;
  }

  /// 訂閱 geolocator stream 並轉發到 positionController
  void _subscribeToGeolocator() {
    _geolocatorSubscription?.cancel();
    _geolocatorSubscription = geolocator.getPositionStream().listen(
      (position) {
        if (_positionController != null && !_positionController!.isClosed) {

          _positionController!.add(position);
          // 根據當前速度自動調整 distanceFilter
          final speedKmh = position.speed * 3.6;
          _updateDistanceFilterBySpeed(speedKmh);
        }
      },
      onError: (error) {
        if (_positionController != null && !_positionController!.isClosed) {
          _positionController!.addError(error);
        }
      },
    );
  }

  /// 停止位置監聽並釋放資源
  void dispose() {
    _geolocatorSubscription?.cancel();
    _positionController?.close();
    _geolocatorSubscription = null;
    _positionController = null;
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
