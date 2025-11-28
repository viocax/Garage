import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:garage/core/service/location/geolocator_interface.dart';

/// Mock Geolocator 類別，用於測試時模擬定位服務
///
/// 使用方式：
/// ```dart
/// final mockGeolocator = MockGeolocator();
///
/// // 設定定位服務狀態
/// mockGeolocator.setLocationServiceEnabled(true);
///
/// // 設定權限狀態
/// mockGeolocator.setPermissionStatus(LocationPermission.always);
///
/// // 設定當前位置
/// mockGeolocator.setCurrentPosition(Position(
///   latitude: 25.0330,
///   longitude: 121.5654,
///   timestamp: DateTime.now(),
///   accuracy: 10.0,
///   altitude: 0.0,
///   heading: 0.0,
///   speed: 0.0,
///   speedAccuracy: 0.0,
///   altitudeAccuracy: 0.0,
///   headingAccuracy: 0.0,
/// ));
/// ```
class MockGeolocator implements GeolocatorInterface {
  /// 定位服務是否開啟
  bool _isLocationServiceEnabled = true;

  /// 當前權限狀態
  LocationPermission _currentPermission = LocationPermission.always;

  /// 當請求權限時要返回的權限狀態
  LocationPermission _permissionAfterRequest = LocationPermission.always;

  /// 模擬的當前位置
  Position? _currentPosition;

  /// 模擬的位置流控制器
  StreamController<Position>? _positionStreamController;

  /// 是否拋出錯誤
  Exception? _errorToThrow;

  /// 記錄方法調用次數
  int checkPermissionCallCount = 0;
  int requestPermissionCallCount = 0;
  int getCurrentPositionCallCount = 0;
  int isLocationServiceEnabledCallCount = 0;

  /// 設定定位服務狀態
  void setLocationServiceEnabled(bool enabled) {
    _isLocationServiceEnabled = enabled;
  }

  /// 設定當前權限狀態
  void setPermissionStatus(LocationPermission permission) {
    _currentPermission = permission;
  }

  /// 設定請求權限後的權限狀態
  void setPermissionAfterRequest(LocationPermission permission) {
    _permissionAfterRequest = permission;
  }

  /// 設定當前位置
  void setCurrentPosition(Position position) {
    _currentPosition = position;
  }

  /// 設定要拋出的錯誤
  void setError(Exception error) {
    _errorToThrow = error;
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    isLocationServiceEnabledCallCount++;
    if (_errorToThrow != null) {
      throw _errorToThrow!;
    }
    return _isLocationServiceEnabled;
  }

  @override
  Future<LocationPermission> checkPermission() async {
    checkPermissionCallCount++;
    if (_errorToThrow != null) {
      throw _errorToThrow!;
    }
    return _currentPermission;
  }

  @override
  Future<LocationPermission> requestPermission() async {
    requestPermissionCallCount++;
    if (_errorToThrow != null) {
      throw _errorToThrow!;
    }
    _currentPermission = _permissionAfterRequest;
    return _permissionAfterRequest;
  }

  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) async {
    getCurrentPositionCallCount++;
    if (_errorToThrow != null) {
      throw _errorToThrow!;
    }
    if (_currentPosition == null) {
      throw Exception('Position not set');
    }
    return _currentPosition!;
  }

  @override
  Stream<Position> getPositionStream({LocationSettings? locationSettings}) {
    if (_errorToThrow != null) {
      return Stream.error(_errorToThrow!);
    }

    _positionStreamController = StreamController<Position>();
    return _positionStreamController!.stream;
  }

  /// 向位置流中添加位置數據
  void addPositionToStream(Position position) {
    _positionStreamController?.add(position);
  }

  /// 關閉位置流
  void closePositionStream() {
    _positionStreamController?.close();
  }

  /// 重置 Mock 狀態
  void reset() {
    _isLocationServiceEnabled = true;
    _currentPermission = LocationPermission.always;
    _permissionAfterRequest = LocationPermission.always;
    _currentPosition = null;
    _errorToThrow = null;
    checkPermissionCallCount = 0;
    requestPermissionCallCount = 0;
    getCurrentPositionCallCount = 0;
    isLocationServiceEnabledCallCount = 0;
    _positionStreamController?.close();
    _positionStreamController = null;
  }
}
