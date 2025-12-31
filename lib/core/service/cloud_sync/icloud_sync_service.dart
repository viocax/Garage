import 'dart:io';

import 'cloud_sync_service.dart';

class ICloudSyncService implements CloudSyncService {
  @override
  CloudProvider get provider => CloudProvider.iCloud;

  @override
  Future<bool> isAvailable() async {
    // iCloud is only available on iOS
    return Platform.isIOS;
  }

  @override
  Future<bool> isAuthenticated() async {
    // TODO: Check if iCloud is signed in via CloudKit
    return false;
  }

  @override
  Future<CloudSyncResult> authenticate() async {
    if (!await isAvailable()) {
      return CloudSyncResult.failure('iCloud 不支援此平台');
    }
    // iCloud uses system authentication, no explicit login needed
    // TODO: Implement iCloud availability check
    return CloudSyncResult.failure('尚未實作');
  }

  @override
  Future<void> signOut() async {
    // iCloud sign out is done via iOS Settings
    // We can only clear local cached data
  }

  @override
  Future<CloudSyncResult> uploadData() async {
    // TODO: Implement data serialization and upload to iCloud
    return CloudSyncResult.failure('尚未實作');
  }

  @override
  Future<CloudSyncResult> downloadData() async {
    // TODO: Implement download and data restore
    return CloudSyncResult.failure('尚未實作');
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    // TODO: Store and retrieve from local preferences
    return null;
  }
}
