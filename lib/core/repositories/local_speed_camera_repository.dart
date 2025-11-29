import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import '../models/speed_camera.dart';
import 'speed_camera_repository.dart';

/// 本地測速照相資料倉儲實作
///
/// 從 assets/cameras.json 讀取資料，並使用記憶體快取避免重複解析
class LocalSpeedCameraRepository implements ISpeedCameraRepository {
  /// 快取的測速照相資料
  List<SpeedCamera>? _cachedCameras;

  /// 資料載入時間
  DateTime? _loadedAt;

  /// 從本地 JSON 檔案載入所有測速照相資料（私有方法）
  ///
  /// 只在第一次呼叫時讀取並解析 JSON，之後使用快取資料
  Future<List<SpeedCamera>> _loadCamerasFromAssets() async {
    // 如果已有快取，直接返回
    if (_cachedCameras != null) {
      debugPrint('LocalSpeedCameraRepository: 使用快取資料 (${_cachedCameras!.length} 筆)');
      return _cachedCameras!;
    }

    debugPrint('LocalSpeedCameraRepository: 從 assets 載入資料...');

    try {
      // 讀取 JSON 檔案
      final String jsonString = await rootBundle.loadString('assets/cameras.json');

      // 解析 JSON
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> resultList = jsonData['result'] ?? [];

      // 轉換為 SpeedCamera 物件列表
      _cachedCameras = resultList
          .map((item) => SpeedCamera.fromJson(item as Map<String, dynamic>))
          .toList();

      _loadedAt = DateTime.now();

      debugPrint('LocalSpeedCameraRepository: 載入完成，共 ${_cachedCameras!.length} 筆資料');

      return _cachedCameras!;
    } catch (e, stackTrace) {
      debugPrint('LocalSpeedCameraRepository: 載入失敗 - $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> syncFromRemote({bool force = false}) async {
    // 本地資料不需要同步，直接載入即可
    debugPrint('LocalSpeedCameraRepository: syncFromRemote called (force: $force)');
    if (force) {
      // 強制重新載入，清除快取
      _cachedCameras = null;
      _loadedAt = null;
    }
    await _loadCamerasFromAssets();
  }

  @override
  Future<List<SpeedCamera>> getAll() async {
    return await _loadCamerasFromAssets();
  }

  @override
  Future<List<SpeedCamera>> getNearby({
    required double latitude,
    required double longitude,
    double radiusInMeters = 5000,
    int limit = 10,
  }) async {
    final cameras = await _loadCamerasFromAssets();

    // 計算每個測速照相點的距離
    final camerasWithDistance = cameras.map((camera) {
      final distance = camera.distanceTo(latitude, longitude);
      return {'camera': camera, 'distance': distance};
    }).toList();

    // 篩選在範圍內的
    final nearby = camerasWithDistance
        .where((item) => (item['distance'] as double) <= radiusInMeters)
        .toList();

    // 按距離排序
    nearby.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

    // 取前 N 筆
    final result = nearby
        .take(limit)
        .map((item) => item['camera'] as SpeedCamera)
        .toList();

    debugPrint('LocalSpeedCameraRepository: getNearby found ${result.length} cameras within ${radiusInMeters}m');

    return result;
  }

  @override
  Future<List<SpeedCamera>> filterByConditions({
    String? roadNumber,
    int? minSpeedLimit,
    int? maxSpeedLimit,
    String? direction,
  }) async {
    final cameras = await _loadCamerasFromAssets();

    return cameras.where((camera) {
      // 速限過濾
      if (minSpeedLimit != null && camera.speedLimit < minSpeedLimit) {
        return false;
      }
      if (maxSpeedLimit != null && camera.speedLimit > maxSpeedLimit) {
        return false;
      }

      // 方向過濾（部分匹配）
      if (direction != null && !camera.direction.contains(direction)) {
        return false;
      }

      return true;
    }).toList();
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
    _cachedCameras = null;
    _loadedAt = null;
  }
}
