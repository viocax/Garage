import 'package:flutter/foundation.dart';
import 'package:garage/core/di/service_locator.dart';
import 'package:garage/core/service/cloud_sync/cloud_sync_service.dart';

import 'cloud_sync_repository.dart';

/// 雲端同步儲存庫本地實作
class LocalCloudSyncRepository implements CloudSyncRepository {
  /// 取得指定提供者的服務實例（從 GetIt）
  CloudSyncService _getService(CloudProvider provider) {
    return getIt.service.cloudSync;
  }

  @override
  CloudProvider getAvailableProvider() {
    return getIt.service.cloudSync.provider;
  }

  @override
  Future<bool> isAvailable(CloudProvider provider) {
    return _getService(provider).isAvailable();
  }

  @override
  Future<bool> isAuthenticated(CloudProvider provider) {
    return _getService(provider).isAuthenticated();
  }

  @override
  Future<CloudSyncResult> authenticate(CloudProvider provider) {
    return _getService(provider).authenticate();
  }

  @override
  Future<void> signOut(CloudProvider provider) {
    return _getService(provider).signOut();
  }

  @override
  Future<CloudSyncResult> uploadData(CloudProvider provider) {
    return _getService(provider).uploadData();
  }

  @override
  Future<CloudSyncResult> downloadData(CloudProvider provider) {
    return _getService(provider).downloadData();
  }

  @override
  Future<DateTime?> getLastSyncTime(CloudProvider provider) {
    return _getService(provider).getLastSyncTime();
  }

  @override
  Future<CloudSyncResult> deleteBackup(CloudProvider provider) {
    return _getService(provider).deleteBackup();
  }
}
