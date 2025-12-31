import 'cloud_sync_service.dart';

class GoogleDriveSyncService implements CloudSyncService {
  @override
  CloudProvider get provider => CloudProvider.googleDrive;

  @override
  Future<bool> isAvailable() async {
    // Google Drive is available on both iOS and Android
    return true;
  }

  @override
  Future<bool> isAuthenticated() async {
    // TODO: Check Google Sign-In status
    return false;
  }

  @override
  Future<CloudSyncResult> authenticate() async {
    // TODO: Implement Google Sign-In
    return CloudSyncResult.failure('尚未實作');
  }

  @override
  Future<void> signOut() async {
    // TODO: Sign out from Google
  }

  @override
  Future<CloudSyncResult> uploadData() async {
    // TODO: Upload to Google Drive App Data folder
    return CloudSyncResult.failure('尚未實作');
  }

  @override
  Future<CloudSyncResult> downloadData() async {
    // TODO: Download from Google Drive
    return CloudSyncResult.failure('尚未實作');
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    // TODO: Store and retrieve from local preferences
    return null;
  }
}
