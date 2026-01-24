import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import 'package:garage/core/di/service_locator.dart';
import 'package:garage/core/utils/log.dart';
import 'package:garage/core/models/tts_speaking_token.dart';
import 'package:garage/core/service/location/location_service.dart';
import 'package:garage/core/service/location/interval_manager.dart';
import 'package:garage/core/service/tts/tts_service.dart';
import 'package:garage/core/models/camera.dart';
import 'package:garage/core/models/interval_zone.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quadtree/quadtree.dart';
import 'speed_camera_repository.dart';
import 'package:garage/core/models/speed_camera_model.dart';
import 'user_settings_repository.dart';

/// 本地測速照相資料倉儲實作
///
/// 從 assets/speedCameras.json 讀取資料，並使用記憶體快取避免重複解析
class LocalSpeedCameraRepository implements ISpeedCameraRepository {
  // Services - support DI
  final LocationService _locationService;
  final TtsService _ttsService;
  final UserSettingsRepository _userSettingsRepo;
  final IntervalManager _intervalManager;

  StreamSubscription<Position>? _speedSubscription;

  /// 快取的測速照相資料
  List<Camera> _cachedCameras = [];

  /// 快取的區間測速資料
  List<IntervalZone> _cachedIntervalZones = [];

  /// 資料載入時間
  DateTime? _loadedAt;

  /// 正在進行的載入 Future
  Future<List<Camera>>? _loadFuture;

  /// 當前追蹤的測速相機
  Camera? _currentCamera;

  /// 區間測速起點位置
  Position? _entryPosition;

  /// 區間測速當前總距離
  double _totalDistanceInZone = 0.0;

  /// 上次區間測速語音提醒時間
  DateTime? _lastIntervalAlertTime;

  /// 已播報的距離閾值集合（用於追蹤哪些閾值已經播報過）
  Set<int> _alertedThresholds = {};

  /// QuadTree 用於快速查找附近相機
  Quadtree? _cameraQuadTree;

  /// Creates a LocalSpeedCameraRepository with optional dependency injection.
  ///
  /// For production, use the default constructor without parameters.
  /// For testing, inject mock services.
  LocalSpeedCameraRepository({
    LocationService? locationService,
    TtsService? ttsService,
    UserSettingsRepository? userSettingsRepo,
    IntervalManager? intervalManager,
  }) : _locationService = locationService ?? getIt.service.location,
       _ttsService = ttsService ?? getIt.service.tts,
       _userSettingsRepo = userSettingsRepo ?? getIt.repo.userSettings,
       _intervalManager = intervalManager ?? IntervalManager();

  @override
  bool get isTracking => _speedSubscription != null;

  /// 從本地 JSON 檔案載入所有測速照相資料（私有方法）
  Future<List<Camera>> _loadCamerasFromAssets() {
    if (_cachedCameras.isNotEmpty) {
      return Future.value(_cachedCameras);
    }

    _loadFuture ??= _performLoad();
    return _loadFuture!;
  }

  Future<List<Camera>> _performLoad() async {
    Log.d('LocalSpeedCameraRepository: 從 assets 載入資料...');

    try {
      // 讀取 JSON 檔案
      Log.d('LocalSpeedCameraRepository: 開始讀取 JSON 檔案...');
      // 使用 rootBundle.loadString讀取
      final String jsonString = await rootBundle.loadString(
        'assets/models/speedCameras.json',
      );
      Log.d('LocalSpeedCameraRepository: JSON 檔案讀取完成，長度: ${jsonString.length}');

      // 解析 JSON - 使用 compute 避免阻塞主執行緒
      Log.d('LocalSpeedCameraRepository: 開始解析 JSON...');
      final List<dynamic> jsonData = await compute(_decodeJson, jsonString);
      Log.d('LocalSpeedCameraRepository: JSON 解析完成，共 ${jsonData.length} 筆');

      Log.d('LocalSpeedCameraRepository: 開始轉換為 Camera 物件...');
      // 轉換物件也使用 compute 處理以防萬一資料量大
      _cachedCameras = await compute(_parseCameras, jsonData);
      Log.d('LocalSpeedCameraRepository: Camera 物件轉換完成');

      // 暫時添加模擬的區間測速資料
      _cachedIntervalZones = [
        const IntervalZone(
          id: 'MOCK_ZONE_1',
          startCameraId: 'MOCK_START',
          endCameraId: 'MOCK_END',
          distance: 2000.0,
          speedLimit: 60,
        ),
      ];

      // 將起點和終點相機加入相機列表（如果不存在）
      _cachedCameras.addAll([
        const Camera(
          id: 'MOCK_START',
          speedLimit: 60,
          latitude: 25.0330,
          longitude: 121.5654,
          direction: '測試',
          description: '模擬區間起點',
          type: 'interval',
          zoneId: 'MOCK_ZONE_1',
        ),
        const Camera(
          id: 'MOCK_END',
          speedLimit: 60,
          latitude: 25.0430,
          longitude: 121.5654,
          direction: '測試',
          description: '模擬區間終點',
          type: 'interval',
          zoneId: 'MOCK_ZONE_1',
        ),
      ]);

      _loadedAt = DateTime.now();
      _buildQuadTree();

      Log.d('LocalSpeedCameraRepository: 載入完成，共 ${_cachedCameras.length} 筆資料');

      return _cachedCameras;
    } catch (e, stackTrace) {
      _loadFuture = null; // 失敗時重設 Future 以便下次重試
      Log.e('LocalSpeedCameraRepository: 載入失敗 - $e', e, stackTrace);
      rethrow;
    }
  }

  /// 靜態解析函數，供 compute 使用
  static List<dynamic> _decodeJson(String jsonString) {
    return json.decode(jsonString) as List<dynamic>;
  }

  /// 靜態解析函數，供 compute 使用
  static List<Camera> _parseCameras(dynamic jsonData) {
    if (jsonData is! List) return [];
    return jsonData
        .map((item) => Camera.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> syncFromRemote({bool force = false}) async {
    // 本地資料不需要同步，直接載入即可
    Log.d('LocalSpeedCameraRepository: syncFromRemote called (force: $force)');
    if (force) {
      // 強制重新載入，清除快取
      _cachedCameras = [];
      _cachedIntervalZones = [];
      _loadedAt = null;
      _loadFuture = null;
    }
    await _loadCamerasFromAssets();
  }

  @override
  List<Camera> getAll() {
    return _cachedCameras;
  }

  @override
  List<IntervalZone> getIntervalZones() {
    return _cachedIntervalZones;
  }

  @override
  IntervalZone? getIntervalZoneById(String id) {
    try {
      return _cachedIntervalZones.firstWhere((z) => z.id == id);
    } catch (_) {
      return null;
    }
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
    Log.d('LocalSpeedCameraRepository: 清除快取');
    _cachedCameras = [];
    _cachedIntervalZones = [];
    _loadedAt = null;
  }

  @override
  Future<bool> checkPermission() async {
    final status = await _locationService.checkPermission();
    return status == PermissionCase.enable || status == PermissionCase.once;
  }

  @override
  Future<bool> requestPermission({bool background = false}) async {
    final status = await _locationService.requestPermission(
      background: background,
    );
    return status == PermissionCase.enable || status == PermissionCase.once;
  }

  @override
  Future<void> startLocationTracking(
    void Function(SpeedCameraModel?) callback,
  ) async {
    try {
      final hasPermission = await requestPermission(background: true);
      if (!hasPermission) {
        Log.d('LocalSpeedCameraRepository: No location permission');
        throw Exception('Location permission denied');
      }
      _speedSubscription = _locationService.getPositionStream().listen(
        (position) async {
          final speedCameraModel = await _positionToSpeedCameraModel(position);
          callback(speedCameraModel);
        },
        onError: (error) {
          Log.e('LocalSpeedCameraRepository: Error: $error', error);
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
    _resetAlertState();
    return;
  }

  /// 將位置資訊轉換為 SpeedCameraModel 並處理警告邏輯
  ///
  /// 處理流程：
  /// 1. 載入使用者設定並檢查是否開啟語音提醒
  /// 2. 相機選擇：找在使用者 heading ±10度內最近的相機，heading 無效時退回找最近的
  /// 3. Reset 條件：0m 已播報 或 超過 alertDistance
  /// 4. 播報閾值：根據 alertDistance 決定
  ///    - alertDistance = 500 → [500, 100, 0]
  ///    - alertDistance = 800 → [800, 400, 100, 0]
  Future<SpeedCameraModel> _positionToSpeedCameraModel(
    Position position,
  ) async {
    // 將速度從 m/s 轉換為 km/h
    final currentSpeed = position.speed * 3.6;
    final lat = position.latitude;
    final lon = position.longitude;
    final heading = position.heading;
    final isHeadingValid = heading > 0 && heading < 360;

    // 1. 載入使用者設定
    final settings = await _userSettingsRepo.loadSettings();
    final alertDistance = settings.alertDistance.toDouble();

    // 初始化回傳模型
    var speedCameraModel = SpeedCameraModel(
      speedLimit: 0,
      currentSpeed: currentSpeed,
      distance: 0,
      isOverSpeed: false,
      latitude: lat,
      longitude: lon,
      heading: heading,
    );

    final isVoiceEnabled = settings.isVoiceAlertEnabled;

    // --- 區間測速邏輯 ---
    if (_intervalManager.isActive) {
      final zone = _intervalManager.currentZone!;

      // 計算從起點到現在的距離
      if (_entryPosition != null) {
        final double incrementalDist = Geolocator.distanceBetween(
          _entryPosition!.latitude,
          _entryPosition!.longitude,
          lat,
          lon,
        );
        _totalDistanceInZone = incrementalDist;
      }

      final status = _intervalManager.calculateStatus(
        distanceTraveled: _totalDistanceInZone,
        currentTime: position.timestamp,
      );

      // 更新回傳模型
      speedCameraModel = speedCameraModel.copyWith(
        isInterval: true,
        speedLimit: zone.speedLimit,
        averageSpeed: status.averageSpeed,
        remainingDistance: status.remainingDistance,
        isOverSpeed: status.isOverSpeed,
      );

      // 檢查是否超速並播放提醒 (每 10 秒提醒一次)
      if (status.isOverSpeed && isVoiceEnabled) {
        final now = position.timestamp;
        if (_lastIntervalAlertTime == null ||
            now.difference(_lastIntervalAlertTime!).inSeconds >= 10) {
          _ttsService.speak('區間平均速度過高，請減速');
          _lastIntervalAlertTime = now;
        }
      }

      // 檢查是否到達終點 (距離終點相機 < 50m)
      final endCamera = _cachedCameras.cast<Camera?>().firstWhere(
        (c) => c?.id == zone.endCameraId,
        orElse: () => null,
      );

      if (status.remainingDistance <= 50 ||
          (endCamera != null && endCamera.distanceTo(lat, lon) < 50)) {
        Log.d('SpeedCamera: 離開區間測速 ${zone.id}');
        if (isVoiceEnabled) {
          _ttsService.speak('離開區間測速');
        }
        _resetAlertState();
      }

      return speedCameraModel;
    }

    // --- 一般/區間起點 偵測邏輯 ---

    // 2. 如果沒有追蹤的相機，找一台新的
    if (_currentCamera == null) {
      if (isHeadingValid) {
        _currentCamera = _findCameraInHeading(lat, lon, heading, alertDistance);
      } else {
        _currentCamera = _findNearestCamera(lat, lon, alertDistance);
      }

      if (_currentCamera != null) {
        _alertedThresholds = {};
        Log.d('SpeedCamera: 開始追蹤相機 ${_currentCamera!.id}');
      }
    }

    if (_currentCamera == null) {
      return speedCameraModel;
    }

    final distance = _currentCamera!.distanceTo(lat, lon);
    final speedLimit = _currentCamera!.speedLimit;

    // 更新基礎資訊
    speedCameraModel = speedCameraModel.copyWith(
      speedLimit: speedLimit,
      distance: distance,
      isOverSpeed: currentSpeed > speedLimit + settings.speedTolerance,
    );

    // 4. 檢查播報閾值
    final thresholds = _getAlertThresholds(settings.alertDistance);
    final now = DateTime.now();

    for (final threshold in thresholds) {
      if (distance <= threshold && !_alertedThresholds.contains(threshold)) {
        // 如果是區間測速起點
        if (_currentCamera!.isInterval && threshold == settings.alertDistance) {
          if (isVoiceEnabled) {
            _ttsService.speak('進入區間測速，速限 $speedLimit');
          }

          // 正式進入區間
          final zone = getIntervalZoneById(_currentCamera!.zoneId ?? '');
          if (zone != null) {
            _intervalManager.enterZone(zone, startTime: position.timestamp);
            _entryPosition = position;
            _totalDistanceInZone = 0.0;
          }
        } else {
          // 一般相機播報
          if (isVoiceEnabled) {
            _ttsService.speakOverSpeed(
              TTSSpeakingToken(
                speedLimit: speedLimit.toDouble(),
                currentSpeed: currentSpeed,
                distance: distance,
                lastReportTime: now,
              ),
            );
          }
        }

        _alertedThresholds.add(threshold);
        break;
      }
    }

    // 5. Reset 條件
    if (_alertedThresholds.contains(0) || distance > alertDistance) {
      _resetAlertState();
    }

    return speedCameraModel;
  }

  /// 重置提醒狀態
  void _resetAlertState() {
    _currentCamera = null;
    _entryPosition = null;
    _totalDistanceInZone = 0.0;
    _alertedThresholds = {};
    _intervalManager.exitZone();
  }

  /// 建立 QuadTree 索引
  ///
  /// 將所有相機位置建立成 QuadTree 結構，用於快速查找附近相機
  void _buildQuadTree() {
    // 台灣經緯度範圍約：lat 21.9-25.3, lon 120.0-122.0
    // 使用較大範圍以確保涵蓋所有相機
    _cameraQuadTree = Quadtree(Rectangle(119.0, 21.0, 4.0, 5.0));

    for (final camera in _cachedCameras) {
      _cameraQuadTree!.insert(
        Point(
          camera.longitude,
          camera.latitude,
          camera, // 儲存 Camera 物件作為 data
        ),
      );
    }

    Log.d(
      'LocalSpeedCameraRepository: QuadTree 建立完成，共 ${_cachedCameras.length} 個點',
    );
  }

  /// 使用 QuadTree 查找 alertDistance 範圍內最近的相機
  ///
  /// [lat] 使用者緯度
  /// [lon] 使用者經度
  /// [alertDistanceMeters] 提醒距離（公尺）
  Camera? _findNearestCamera(
    double lat,
    double lon,
    double alertDistanceMeters,
  ) {
    if (_cameraQuadTree == null) return null;

    // 將公尺轉換為經緯度偏移量（粗略估計）
    // 1度緯度 ≈ 111km, 1度經度在台灣約 ≈ 100km
    final latOffset = alertDistanceMeters / 111000;
    final lonOffset = alertDistanceMeters / 100000;

    final points = _cameraQuadTree!.query(
      Rectangle(lon - lonOffset, lat - latOffset, lonOffset * 2, latOffset * 2),
    );

    if (points.isEmpty) return null;

    Camera? nearest;
    double minDistance = double.infinity;

    for (final point in points) {
      final camera = point.data as Camera;
      final distance = camera.distanceTo(lat, lon);
      if (distance < minDistance && distance <= alertDistanceMeters) {
        minDistance = distance;
        nearest = camera;
      }
    }

    return nearest;
  }

  /// 根據 alertDistance 計算播報距離閾值列表
  ///
  /// 規則：
  /// - 固定閾值：100m, 0m
  /// - alertDistance 本身
  /// - 如果 alertDistance > 500，加入 alertDistance / 2
  ///
  /// 範例：
  /// - alertDistance = 300 → [300, 100, 0]
  /// - alertDistance = 500 → [500, 100, 0]
  /// - alertDistance = 800 → [800, 400, 100, 0]
  /// - alertDistance = 1000 → [1000, 500, 100, 0]
  List<int> _getAlertThresholds(int alertDistance) {
    final thresholds = <int>{0, 100, alertDistance};
    if (alertDistance > 500) {
      thresholds.add(alertDistance ~/ 2);
    }
    return thresholds.toList()..sort((a, b) => b.compareTo(a)); // 降序排列
  }

  /// 查找在使用者 heading 方向 ±10度內最近的相機
  ///
  /// [lat] 使用者緯度
  /// [lon] 使用者經度
  /// [heading] 使用者行駛方向（0-360度）
  /// [alertDistanceMeters] 提醒距離（公尺）
  Camera? _findCameraInHeading(
    double lat,
    double lon,
    double heading,
    double alertDistanceMeters,
  ) {
    if (_cameraQuadTree == null) return null;

    // 將公尺轉換為經緯度偏移量（粗略估計）
    final latOffset = alertDistanceMeters / 111000;
    final lonOffset = alertDistanceMeters / 100000;

    final points = _cameraQuadTree!.query(
      Rectangle(lon - lonOffset, lat - latOffset, lonOffset * 2, latOffset * 2),
    );

    if (points.isEmpty) return null;

    Camera? nearest;
    double minDistance = double.infinity;

    for (final point in points) {
      final camera = point.data as Camera;
      final distance = camera.distanceTo(lat, lon);

      // 檢查是否在 alertDistance 範圍內
      if (distance > alertDistanceMeters) continue;

      // 計算相機相對於使用者的方位角
      final bearing = _calculateBearing(
        lat,
        lon,
        camera.latitude,
        camera.longitude,
      );

      // 計算 heading 與 bearing 的角度差
      var angleDiff = (heading - bearing).abs();
      if (angleDiff > 180) {
        angleDiff = 360 - angleDiff;
      }

      // 只選擇在 heading ±10度內的相機
      if (angleDiff <= 10 && distance < minDistance) {
        minDistance = distance;
        nearest = camera;
      }
    }

    return nearest;
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

  @override
  Future<void> updateVolume(double percentage) async {
    final volume = percentage.clamp(0.0, 1.0);
    await _ttsService.setVolume(volume);
  }

  @override
  void setLocationPolicyBest() {
    _locationService.updatePolicy(LocationPolicy.best);
  }

  @override
  void setLocationPolicyBackground() {
    _locationService.updatePolicy(LocationPolicy.background);
  }
}
