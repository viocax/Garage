import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:garage/core/service/location/geolocator_interface.dart';
import 'package:garage/core/utils/log.dart';

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

enum PermissionCase { enable, disable, once }

class LocationService {
  LocationPolicy _currentPolicy = LocationPolicy.best;
  GeolocatorInterface? _geolocator;
  int _currentDistanceFilter = 0;
  StreamSubscription<Position>? _geolocatorSubscription;
  StreamController<Position>? _positionController;

  LocationService({GeolocatorInterface? geolocator}) {
    _geolocator = geolocator;
    _currentDistanceFilter = 0; // 初始設為0以在靜止時也能收到更新
  }

  /// 更新定位策略
  void updatePolicy(LocationPolicy policy) {
    if (_currentPolicy != policy) {
      _currentPolicy = policy;
      Log.d('LocationService: 切換策略至 $policy');
      _recreateGeolocatorStream();
    }
  }

  /// 取得或創建 GeolocatorInterface
  GeolocatorInterface get geolocator {
    _geolocator ??= GeolocatorWrapper(
      locationSettings: _getLocationSettings(_currentDistanceFilter),
    );
    return _geolocator!;
  }

  /// 根據當前平台與策略獲取定位設定
  LocationSettings _getLocationSettings(int distanceFilter) {
    final accuracy = _currentPolicy == LocationPolicy.best
        ? LocationAccuracy.bestForNavigation
        : LocationAccuracy.medium;

    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
        intervalDuration: const Duration(seconds: 1),
        foregroundNotificationConfig: ForegroundNotificationConfig(
          notificationText: 'speedDetection.notificationText'.tr(),
          notificationTitle: 'speedDetection.notificationTitle'.tr(),
          enableWakeLock: true,
          setOngoing: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return AppleSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
        allowBackgroundLocationUpdates: true,
        pauseLocationUpdatesAutomatically:
            _currentPolicy == LocationPolicy.background,
        showBackgroundLocationIndicator: true,
      );
    } else {
      return LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      );
    }
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
      Log.d(
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
      locationSettings: _getLocationSettings(_currentDistanceFilter),
    );

    // 重新訂閱
    _subscribeToGeolocator();
  }

  PermissionCase _mapPermissionToCase(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.always:
        return PermissionCase.enable;
      case LocationPermission.whileInUse:
        return PermissionCase.once;
      case LocationPermission.denied:
      case LocationPermission.deniedForever:
      case LocationPermission.unableToDetermine:
        return PermissionCase.disable;
    }
  }

  Future<PermissionCase> checkPermission() async {
    final permission = await geolocator.checkPermission();
    return _mapPermissionToCase(permission);
  }

  /// 檢查並請求定位權限
  Future<PermissionCase> requestPermission({bool background = false}) async {
    bool serviceEnabled;
    LocationPermission permission;

    // 檢查定位服務是否開啟
    serviceEnabled = await geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return PermissionCase.disable;
    }

    permission = await geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return PermissionCase.disable;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return PermissionCase.disable;
    }

    // 如果需要背景權限（Always）
    if (background && permission != LocationPermission.always) {
      // 再次請求權限以提升至 Always
      permission = await geolocator.requestPermission();
    }

    return _mapPermissionToCase(permission);
  }

  /// 取得目前位置
  ///
  /// 如果權限不足或服務未開啟，可能拋出異常或返回 null
  Future<Position?> getCurrentPosition() async {
    final permissionCase = await requestPermission();
    if (permissionCase == PermissionCase.disable) {
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
