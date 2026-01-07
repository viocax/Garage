import 'package:garage/core/service/cloud_sync/cloud_sync_service.dart';

/// 雲端同步儲存庫介面
abstract class CloudSyncRepository {
  /// 取得當前平台可用的雲端服務提供者
  CloudProvider getAvailableProvider();

  /// 檢查指定提供者是否可用
  Future<bool> isAvailable(CloudProvider provider);

  /// 檢查是否已認證
  Future<bool> isAuthenticated(CloudProvider provider);

  /// 執行認證
  Future<CloudSyncResult> authenticate(CloudProvider provider);

  /// 登出
  Future<void> signOut(CloudProvider provider);

  /// 上傳資料到雲端
  Future<CloudSyncResult> uploadData(CloudProvider provider);

  /// 從雲端下載資料
  Future<CloudSyncResult> downloadData(CloudProvider provider);

  /// 取得上次同步時間
  Future<DateTime?> getLastSyncTime(CloudProvider provider);

  /// 刪除雲端備份資料
  Future<CloudSyncResult> deleteBackup(CloudProvider provider);
}
