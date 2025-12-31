import 'dart:io';

import 'cloud_sync_service.dart';
import 'icloud_sync_service.dart';
import 'google_drive_sync_service.dart';

class CloudSyncServiceFactory {
  static final Map<CloudProvider, CloudSyncService> _instances = {};

  /// Get available cloud providers for current platform
  static List<CloudProvider> getAvailableProviders() {
    if (Platform.isIOS) {
      return [CloudProvider.iCloud, CloudProvider.googleDrive];
    } else if (Platform.isAndroid) {
      return [CloudProvider.googleDrive];
    }
    return [];
  }

  /// Get service for a specific provider
  static CloudSyncService getService(CloudProvider provider) {
    if (!_instances.containsKey(provider)) {
      switch (provider) {
        case CloudProvider.iCloud:
          _instances[provider] = ICloudSyncService();
        case CloudProvider.googleDrive:
          _instances[provider] = GoogleDriveSyncService();
      }
    }
    return _instances[provider]!;
  }
}
