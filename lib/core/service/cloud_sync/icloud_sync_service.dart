import 'dart:io';

import 'package:garage/core/core.dart';
import 'package:icloud_storage/icloud_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ICloudSyncService extends CloudSyncService with CloudSyncDataMixin {
  static const _backupFileName = 'garage_backup.json';
  static const _containerId = 'iCloud.com.drake.garage';
  static const _lastSyncKey = 'icloud_last_sync';

  @override
  CloudProvider get provider => CloudProvider.iCloud;

  @override
  Future<bool> isAvailable() async {
    // iCloud is only available on iOS
    if (!Platform.isIOS) return false;

    try {
      // Check if iCloud is available by trying to gather files
      await ICloudStorage.gather(containerId: _containerId);
      return true;
    } catch (e) {
      // If gather fails, iCloud is not available or not configured
      return false;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    // iCloud uses system authentication
    // If iCloud is available, user is authenticated
    return await isAvailable();
  }

  @override
  Future<CloudSyncResult> authenticate() async {
    if (!Platform.isIOS) {
      return CloudSyncResult.failure('iCloud 僅支援 iOS');
    }

    final available = await isAvailable();
    if (available) {
      return CloudSyncResult.success();
    } else {
      return CloudSyncResult.failure('請在 iOS 設定中登入 iCloud');
    }
  }

  @override
  Future<void> signOut() async {
    // iCloud sign out is done via iOS Settings
    // We can only clear local cached data
  }

  @override
  Future<CloudSyncResult> uploadData() async {
    try {
      if (!await isAvailable()) {
        return CloudSyncResult.failure('iCloud 不可用，請確認已登入 iCloud');
      }

      // Get app data to export
      final exportData = await getExportData();
      if (exportData == null) {
        return CloudSyncResult.failure('無法取得匯出資料');
      }

      // Write to temporary file first
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$_backupFileName');
      await tempFile.writeAsString(exportData);

      // Upload to iCloud
      await ICloudStorage.upload(
        containerId: _containerId,
        filePath: tempFile.path,
        destinationRelativePath: _backupFileName,
        onProgress: (progress) {
          // Progress callback - could be used for UI updates
        },
      );

      // Clean up temp file
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      // Save sync time
      final syncTime = DateTime.now();
      await _saveLastSyncTime(syncTime);

      return CloudSyncResult.success(syncTime: syncTime);
    } catch (e) {
      return CloudSyncResult.failure('上傳失敗：${e.toString()}');
    }
  }

  @override
  Future<CloudSyncResult> downloadData() async {
    try {
      if (!await isAvailable()) {
        return CloudSyncResult.failure('iCloud 不可用，請確認已登入 iCloud');
      }

      // Check if backup file exists in iCloud
      final files = await ICloudStorage.gather(containerId: _containerId);
      final backupFile = files.where((f) => f.relativePath == _backupFileName);

      if (backupFile.isEmpty) {
        return CloudSyncResult.failure('iCloud 沒有備份資料');
      }

      // Download to temporary file
      final tempDir = await getTemporaryDirectory();
      final tempFilePath = '${tempDir.path}/$_backupFileName';

      await ICloudStorage.download(
        containerId: _containerId,
        relativePath: _backupFileName,
        destinationFilePath: tempFilePath,
        onProgress: (progress) {
          // Progress callback
        },
      );

      // Read and restore data
      final tempFile = File(tempFilePath);
      if (!await tempFile.exists()) {
        return CloudSyncResult.failure('下載失敗');
      }

      final jsonString = await tempFile.readAsString();
      final success = await restoreData(jsonString);

      // Clean up temp file
      await tempFile.delete();

      if (!success) {
        return CloudSyncResult.failure('還原資料失敗');
      }

      // Save sync time
      final syncTime = DateTime.now();
      await _saveLastSyncTime(syncTime);

      return CloudSyncResult.success(syncTime: syncTime);
    } catch (e) {
      return CloudSyncResult.failure('下載失敗：${e.toString()}');
    }
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastSyncKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  @override
  Future<CloudSyncResult> deleteBackup() async {
    try {
      if (!await isAvailable()) {
        return CloudSyncResult.failure('iCloud 不可用，請確認已登入 iCloud');
      }

      // Check if backup file exists in iCloud
      final files = await ICloudStorage.gather(containerId: _containerId);
      final backupFile = files.where((f) => f.relativePath == _backupFileName);

      if (backupFile.isEmpty) {
        return CloudSyncResult.failure('iCloud 沒有備份資料');
      }

      // Delete the backup file
      await ICloudStorage.delete(
        containerId: _containerId,
        relativePath: _backupFileName,
      );

      // Clear local sync time record
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastSyncKey);

      return CloudSyncResult.success();
    } catch (e) {
      return CloudSyncResult.failure('刪除失敗：${e.toString()}');
    }
  }

  // Private helper methods

  Future<void> _saveLastSyncTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSyncKey, time.millisecondsSinceEpoch);
  }
}
