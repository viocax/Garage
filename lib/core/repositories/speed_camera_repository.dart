import 'package:geolocator/geolocator.dart';

import '../models/speed_camera.dart';

/// 測速照相資料倉儲介面
///
/// 提供測速照相點位資料的存取抽象層，遵循依賴反轉原則。
/// 外部程式碼應依賴此介面而非具體實作。
abstract class ISpeedCameraRepository {
  /// 同步遠端資料到本地
  ///
  /// [force] 是否強制同步，忽略快取時間限制
  Future<void> syncFromRemote({bool force = false});

  /// 取得所有測速照相點位
  Future<List<SpeedCamera>> getAll();

  /// 取得資料總數
  Future<int> getCount();

  /// 取得最後同步時間
  Future<DateTime?> getLastSyncTime();

  /// 清除所有本地資料
  Future<void> clearAll();

  Future<bool> checkPermission();

  Future<bool> requestPermission();

  Stream<Position> startLocationTracking();

  Future<void> stopLocationTracking();

  void readOverSpeedTTS(
    Position position,
    double speedLimit,
    double currentSpeed,
  );
}
