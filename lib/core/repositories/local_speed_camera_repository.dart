import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import 'package:garage/core/di/service_locator.dart';
import 'package:garage/core/models/tts_speaking_token.dart';
import 'package:garage/core/service/location/location_service.dart';
import 'package:garage/core/service/tts/tts_service.dart';
import 'package:garage/core/models/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'speed_camera_repository.dart';
import 'package:garage/core/models/speed_camera_model.dart';

/// 本地測速照相資料倉儲實作
///
/// 從 assets/cameras.json 讀取資料，並使用記憶體快取避免重複解析
class LocalSpeedCameraRepository implements ISpeedCameraRepository {
  // Service
  final LocationService _locationService = getIt.service.location;
  final TtsService _ttsService = getIt.service.tts;

  StreamSubscription<Position>? _speedSubscription;

  /// 快取的測速照相資料
  List<Camera> _cachedCameras = [];

  /// 資料載入時間
  DateTime? _loadedAt;

  /// 從本地 JSON 檔案載入所有測速照相資料（私有方法）
  ///
  /// 只在第一次呼叫時讀取並解析 JSON，之後使用快取資料
  Future<List<Camera>> _loadCamerasFromAssets() async {
    // 如果已有快取，直接返回
    if (_cachedCameras.isNotEmpty) {
      debugPrint(
        'LocalSpeedCameraRepository: 使用快取資料 (${_cachedCameras.length} 筆)',
      );
      return _cachedCameras;
    }

    debugPrint('LocalSpeedCameraRepository: 從 assets 載入資料...');

    try {
      // 讀取 JSON 檔案
      final String jsonString = await rootBundle.loadString(
        'assets/cameras.json',
      );

      // 解析 JSON
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> resultList = jsonData['result'] ?? [];

      // 轉換為 SpeedCamera 物件列表
      _cachedCameras = resultList
          .map((item) => Camera.fromJson(item as Map<String, dynamic>))
          .toList();

      _loadedAt = DateTime.now();

      debugPrint(
        'LocalSpeedCameraRepository: 載入完成，共 ${_cachedCameras.length} 筆資料',
      );

      return _cachedCameras;
    } catch (e, stackTrace) {
      debugPrint('LocalSpeedCameraRepository: 載入失敗 - $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> syncFromRemote({bool force = false}) async {
    // 本地資料不需要同步，直接載入即可
    debugPrint(
      'LocalSpeedCameraRepository: syncFromRemote called (force: $force)',
    );
    if (force) {
      // 強制重新載入，清除快取
      _cachedCameras = [];
      _loadedAt = null;
    }
    await _loadCamerasFromAssets();
  }

  @override
  Future<List<Camera>> getAll() async {
    return await _loadCamerasFromAssets();
  }

  @override
  Future<int> getCount() async {
    final cameras = await _loadCamerasFromAssets();
    return cameras.length;
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    return _loadedAt;
  }

  @override
  Future<void> clearAll() async {
    debugPrint('LocalSpeedCameraRepository: 清除快取');
    _cachedCameras = [];
    _loadedAt = null;
  }

  @override
  Future<bool> checkPermission() async {
    return _locationService.checkPermission();
  }
  @override
  Future<bool> requestPermission() {
    return _locationService.requestPermission();
  }

  @override
  Future<void> startLocationTracking(void Function(SpeedCameraModel?) callback) async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        debugPrint('LocalSpeedCameraRepository: No location permission');
        throw Exception('Location permission denied'); // TODO: 跳轉到權限設定頁面
      }
      _speedSubscription = _locationService.getPositionStream().listen((position) {
        final speedCameraModel = _positionToSpeedCameraModel(position, _cachedCameras);
        callback(speedCameraModel);
      }, onError: (error) {
        debugPrint('LocalSpeedCameraRepository: Error: $error');
        callback(null);
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> stopLocationTracking() async {
    // LocationService 目前使用 Stream，取消訂閱即可停止監聽，不需要顯式停止服務
    // 如果未來有需要顯式停止定位服務的需求，可以在這裡實作
    _speedSubscription?.cancel();
    _speedSubscription = null;
    return;
  }
  SpeedCameraModel _positionToSpeedCameraModel(Position position, List<Camera> cameras) {
    final currentSpeed = position.speed;
    Camera? nearestCamera;
    double minDistance = double.infinity;
    int speedLimit = 0;
    for (final camera in cameras) {
      final distance = camera.distanceTo(
        position.latitude,
        position.longitude,
      );
      if (distance < minDistance) {
        minDistance = distance;
        nearestCamera = camera;
      }
    }
    bool isOverSpeed = false;
    if (nearestCamera != null) {
      speedLimit = nearestCamera.speedLimit;
      isOverSpeed = currentSpeed > speedLimit;
      //TODO: 是否使用者關閉提醒，是否超速，是否到了100, 是否到了使用者第一個設定
      if (isOverSpeed) {
        _ttsService.speakOverSpeed(
          TTSSpeakingToken(
            speedLimit: speedLimit.toDouble(),
            currentSpeed: currentSpeed,
            distance: minDistance,
            lastReportTime: DateTime.now(),
          ),
        );
      }
    }
    return SpeedCameraModel(
      speedLimit: speedLimit,
      currentSpeed: currentSpeed,
      distance: minDistance,
      isOverSpeed: isOverSpeed,
    );
  }

  @override
  Future<void> updateLocationAccuracyPolicy(double currentSpeed) {
    throw UnimplementedError();
  }
  @override
  Future<void> updateVolume(double percentage) async {
    final volume = percentage.clamp(0.0, 1.0);
    await _ttsService.setVolume(volume);
  }
}
