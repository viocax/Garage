/// Cloud sync result with status and optional error
class CloudSyncResult {
  final bool success;
  final String? errorMessage;
  final DateTime? lastSyncTime;

  const CloudSyncResult({
    required this.success,
    this.errorMessage,
    this.lastSyncTime,
  });

  factory CloudSyncResult.success({DateTime? syncTime}) => CloudSyncResult(
        success: true,
        lastSyncTime: syncTime ?? DateTime.now(),
      );

  factory CloudSyncResult.failure(String message) => CloudSyncResult(
        success: false,
        errorMessage: message,
      );
}

/// Cloud provider types
enum CloudProvider {
  iCloud,
  googleDrive;

  String get displayName {
    switch (this) {
      case CloudProvider.iCloud:
        return 'iCloud';
      case CloudProvider.googleDrive:
        return 'Google Drive';
    }
  }
}

/// Abstract interface for cloud sync operations
abstract class CloudSyncService {
  /// Get the provider type
  CloudProvider get provider;

  /// Check if the provider is available on this platform
  Future<bool> isAvailable();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Authenticate with the cloud provider
  Future<CloudSyncResult> authenticate();

  /// Sign out from the cloud provider
  Future<void> signOut();

  /// Upload all data to cloud
  Future<CloudSyncResult> uploadData();

  /// Download and restore data from cloud
  Future<CloudSyncResult> downloadData();

  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTime();
}
