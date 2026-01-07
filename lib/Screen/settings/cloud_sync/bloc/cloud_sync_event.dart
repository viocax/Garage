import 'package:garage/core/core.dart';

sealed class CloudSyncEvent {
  const CloudSyncEvent();
}

/// Load available providers and their status
final class LoadCloudSyncStatus extends CloudSyncEvent {
  const LoadCloudSyncStatus();
}


/// Authenticate with selected provider
final class AuthenticateProvider extends CloudSyncEvent {
  final CloudProvider provider;
  const AuthenticateProvider(this.provider);
}

/// Sign out from provider
final class SignOutProvider extends CloudSyncEvent {
  final CloudProvider provider;
  const SignOutProvider(this.provider);
}

/// Upload data to cloud
final class UploadToCloud extends CloudSyncEvent {
  const UploadToCloud();
}

/// Download data from cloud
final class DownloadFromCloud extends CloudSyncEvent {
  const DownloadFromCloud();
}

/// Clear all local data
final class ClearLocalData extends CloudSyncEvent {
  const ClearLocalData();
}

/// Delete cloud backup
final class DeleteCloudBackup extends CloudSyncEvent {
  const DeleteCloudBackup();
}
