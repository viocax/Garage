import '../models/speed_camera.dart';
import '../service/location/location_service.dart';

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

  /// 根據位置取得附近的測速照相點位
  ///
  /// [latitude] 緯度
  /// [longitude] 經度
  /// [radiusInMeters] 搜尋半徑（公尺），預設 5000
  /// [limit] 最多返回數量，預設 10
  Future<List<SpeedCamera>> getNearby({
    required double latitude,
    required double longitude,
    double radiusInMeters = 5000,
    int limit = 10,
  });

  /// 多條件過濾
  ///
  /// [roadNumber] 道路編號（精確匹配）
  /// [minSpeedLimit] 最低速限
  /// [maxSpeedLimit] 最高速限
  /// [direction] 道路方向
  Future<List<SpeedCamera>> filterByConditions({
    String? roadNumber,
    int? minSpeedLimit,
    int? maxSpeedLimit,
    String? direction,
  });

  /// 取得資料總數
  Future<int> getCount();

  /// 取得最後同步時間
  Future<DateTime?> getLastSyncTime();

  /// 清除所有本地資料
  Future<void> clearAll();

  // --- 速度追蹤相關方法 ---

  /// 檢查定位權限並獲取當前位置
  ///
  /// 返回當前位置的經緯度，如果權限被拒絕或服務未開啟則返回 null
  Future<LatLng?> getCurrentLocation();

  /// 監聽速度變化（km/h）
  ///
  /// 返回實時速度流，單位為公里/小時
  Stream<double> getSpeedStream();
}
