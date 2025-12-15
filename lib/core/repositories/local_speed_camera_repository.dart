import 'dart:async';
import 'dart:convert';
import 'dart:math';
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
import 'user_settings_repository.dart';

/// 本地測速照相資料倉儲實作
///
/// 從 assets/speedCameras.json 讀取資料，並使用記憶體快取避免重複解析
class LocalSpeedCameraRepository implements ISpeedCameraRepository {
  // Service
  final LocationService _locationService = getIt.service.location;
  final TtsService _ttsService = getIt.service.tts;
  final UserSettingsRepository _userSettingsRepo = getIt.repo.userSettings;

  StreamSubscription<Position>? _speedSubscription;

  /// 快取的測速照相資料
  List<Camera> _cachedCameras = [];

  /// 資料載入時間
  DateTime? _loadedAt;

  /// 當前追蹤的測速相機（用於判斷是否還在同一路段）
  Camera? _currentCamera;

  /// 當前路段的提醒次數
  int _alertCount = 0;

  /// 上次提醒時間
  DateTime? _lastAlertTime;

  /// 上次的行駛方向（度數，0-360）
  double? _lastHeading;

  @override
  bool get isTracking => _speedSubscription != null;

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
        'assets/speedCameras.json',
      );

      // 解析 JSON
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // 遍歷所有城市，將每個城市的 speedCamera 陣列合併
      _cachedCameras = jsonData.values.fold<List<Camera>>([], (
        allCameras,
        cityData,
      ) {
        if (cityData is Map<String, dynamic>) {
          final speedCameraList = cityData['speedCamera'] as List<dynamic>?;
          if (speedCameraList != null) {
            final cameras = speedCameraList
                .map((item) => Camera.fromJson(item as Map<String, dynamic>))
                .toList();
            return [...allCameras, ...cameras];
          }
        }
        return allCameras;
      });

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
  Future<void> startLocationTracking(
    void Function(SpeedCameraModel?) callback,
  ) async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        debugPrint('LocalSpeedCameraRepository: No location permission');
        throw Exception('Location permission denied'); // TODO: 跳轉到權限設定頁面
      }
      _speedSubscription = _locationService.getPositionStream().listen(
        (position) {
          final speedCameraModel = _positionToSpeedCameraModel(
            position,
            _cachedCameras,
          );
          callback(speedCameraModel);
        },
        onError: (error) {
          debugPrint('LocalSpeedCameraRepository: Error: $error');
          callback(null);
        },
      );
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

  SpeedCameraModel _positionToSpeedCameraModel(
    Position position,
    List<Camera> cameras,
  ) {
    final currentSpeed = position.speed;
    Camera? nearestCamera;
    double minDistance = double.infinity;
    int speedLimit = 0;
    for (final camera in cameras) {
      final distance = camera.distanceTo(position.latitude, position.longitude);
      if (distance < minDistance) {
        minDistance = distance;
        nearestCamera = camera;
      }
    }
    bool isOverSpeed = false;
    if (nearestCamera != null) {
      speedLimit = nearestCamera.speedLimit;
      isOverSpeed = currentSpeed > speedLimit;

      // 實現 TODO 邏輯
      _handleSpeedAlert(
        nearestCamera,
        position,
        currentSpeed,
        speedLimit,
        minDistance,
      );
    } else {
      // 沒有最近的測速相機，重置狀態
      _resetAlertState();
    }
    return SpeedCameraModel(
      speedLimit: speedLimit,
      currentSpeed: currentSpeed,
      distance: minDistance,
      isOverSpeed: isOverSpeed,
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  /// 處理速度警告邏輯
  ///
  /// 實現以下需求：
  /// 1. 檢查使用者是否關閉提醒 ✓
  /// 2. 判斷是否還在同一個路段 ✓
  /// 3. 根據使用者設定的距離，決定提醒次數（2-3次）✓
  /// 4. 控制播報間隔至少5秒 ✓
  Future<void> _handleSpeedAlert(
    Camera camera,
    Position position,
    double currentSpeed,
    int speedLimit,
    double distance,
  ) async {
    // 1. 檢查使用者是否關閉提醒
    final settings = await _userSettingsRepo.loadSettings();
    if (!settings.isVoiceAlertEnabled) {
      // 使用者已關閉語音提醒，直接返回
      return;
    }

    final now = DateTime.now();

    // 2. 判斷是否還在同一個路段（使用進階檢測）
    final isSameSegment = _isSameRoadSegment(camera, position);

    if (!isSameSegment) {
      // 進入新的路段，重置狀態
      _currentCamera = camera;
      _alertCount = 0;
      _lastAlertTime = null;
      _lastHeading = position.heading;
    }

    // 3. 檢查是否超速
    if (currentSpeed <= speedLimit) {
      // 未超速，不需要提醒
      return;
    }

    // 4. 檢查播報間隔（至少5秒）
    if (_lastAlertTime != null) {
      final timeSinceLastAlert = now.difference(_lastAlertTime!);
      if (timeSinceLastAlert.inSeconds < 5) {
        // 距離上次播報不足5秒，跳過
        return;
      }
    }

    // 5. 根據距離決定最大提醒次數
    final maxAlerts = await _getMaxAlerts();

    // 6. 檢查提醒次數是否已達上限
    if (_alertCount >= maxAlerts) {
      // 已達最大提醒次數，不再提醒
      return;
    }

    // 7. 執行提醒
    _ttsService.speakOverSpeed(
      TTSSpeakingToken(
        speedLimit: speedLimit.toDouble(),
        currentSpeed: currentSpeed,
        distance: distance,
        lastReportTime: now,
      ),
    );

    // 8. 更新狀態
    _alertCount++;
    _lastAlertTime = now;
    _lastHeading = position.heading;
  }

  /// 獲取最大提醒次數
  ///
  /// 根據使用者設定的 alertDistance 決定：
  /// - 如果 500 < alertDistance <= 1000，則提醒3次
  /// - 如果 alertDistance <= 500，則提醒2次
  Future<int> _getMaxAlerts() async {
    // 從使用者設定中獲取 alertDistance
    final settings = await _userSettingsRepo.loadSettings();
    final alertDistance = settings.alertDistance;

    if (alertDistance > 500 && alertDistance <= 1000) {
      return 3;
    } else {
      return 2;
    }
  }

  /// 重置提醒狀態
  void _resetAlertState() {
    _currentCamera = null;
    _alertCount = 0;
    _lastAlertTime = null;
    _lastHeading = null;
  }

  /// 計算從使用者位置到測速相機的方位角（bearing）
  ///
  /// 返回值範圍：0-360度
  /// - 0度 = 正北
  /// - 90度 = 正東
  /// - 180度 = 正南
  /// - 270度 = 正西
  double _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    final dLon = (lon2 - lon1) * pi / 180;
    final lat1Rad = lat1 * pi / 180;
    final lat2Rad = lat2 * pi / 180;

    final y = sin(dLon) * cos(lat2Rad);
    final x =
        cos(lat1Rad) * sin(lat2Rad) - sin(lat1Rad) * cos(lat2Rad) * cos(dLon);

    final bearing = atan2(y, x) * 180 / pi;
    return (bearing + 360) % 360; // 轉換為0-360度
  }

  /// 判斷是否在同一條路段上
  ///
  /// 結合方案一（行駛方向）和方案二（相機方位）：
  /// 1. 檢查是否是同一個測速相機位置
  /// 2. 比較使用者行駛方向，檢測迴轉（方向改變>90度）
  /// 3. 比較使用者行駛方向與朝向相機的方位，確認是否接近相機
  bool _isSameRoadSegment(Camera camera, Position position) {
    // 1. 檢查是否是同一個相機（使用 id 比較）
    if (_currentCamera == null || _currentCamera!.id != camera.id) {
      return false;
    }

    //2. 檢查行駛方向變化（方案一：檢測迴轉）
    if (_lastHeading != null && position.heading != 0) {
      final headingDiff = (position.heading - _lastHeading!).abs();

      // 方向差異在90-270度之間，表示可能迴轉了或換了相反方向的車道
      if (headingDiff > 90 && headingDiff < 270) {
        debugPrint(
          'SpeedCamera: 行駛方向改變 ${headingDiff.toStringAsFixed(1)}度，判定為不同路段',
        );
        return false;
      }
    }

    // 3. 檢查是否朝向相機行駛（方案二：方位角比對）
    if (position.heading != 0) {
      final bearing = _calculateBearing(
        position.latitude,
        position.longitude,
        camera.latitude,
        camera.longitude,
      );

      // 計算使用者行駛方向與朝向相機的方位差異
      var bearingDiff = (position.heading - bearing).abs();
      if (bearingDiff > 180) {
        bearingDiff = 360 - bearingDiff;
      }

      // 如果方位差異超過90度，表示正在遠離相機或平行經過
      // 這種情況下應該視為離開該路段
      if (bearingDiff > 90) {
        debugPrint(
          'SpeedCamera: 行駛方位與相機方位差異 ${bearingDiff.toStringAsFixed(1)}度，判定為不同路段',
        );
        return false;
      }
    }

    return true;
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
