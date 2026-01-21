import 'dart:convert';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:garage/core/core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Interface for Google Sign-In operations, allowing injection for testing.
abstract class GoogleSignInWrapper {
  GoogleSignInAccount? get currentUser;
  Future<bool> isSignedIn();
  Future<GoogleSignInAccount?> signIn();
  Future<GoogleSignInAccount?> signInSilently();
  Future<GoogleSignInAccount?> signOut();
  Future<http.Client?> authenticatedClient();
}

/// Default implementation using actual GoogleSignIn.
class DefaultGoogleSignInWrapper implements GoogleSignInWrapper {
  final GoogleSignIn _googleSignIn;

  DefaultGoogleSignInWrapper()
    : _googleSignIn = GoogleSignIn(scopes: [drive.DriveApi.driveAppdataScope]);

  @override
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  @override
  Future<bool> isSignedIn() => _googleSignIn.isSignedIn();

  @override
  Future<GoogleSignInAccount?> signIn() => _googleSignIn.signIn();

  @override
  Future<GoogleSignInAccount?> signInSilently() =>
      _googleSignIn.signInSilently();

  @override
  Future<GoogleSignInAccount?> signOut() => _googleSignIn.signOut();

  @override
  Future<http.Client?> authenticatedClient() =>
      _googleSignIn.authenticatedClient();
}

/// Interface for Drive API operations, allowing injection for testing.
abstract class DriveApiWrapper {
  Future<drive.FileList> listFiles({
    required String spaces,
    required String q,
    required String fields,
  });
  Future<drive.File> createFile(drive.File file, {drive.Media? uploadMedia});
  Future<drive.File> updateFile(
    drive.File file,
    String fileId, {
    drive.Media? uploadMedia,
  });
  Future<void> deleteFile(String fileId);
  Future<drive.Media> downloadFile(String fileId);
}

/// Default implementation using actual DriveApi.
class DefaultDriveApiWrapper implements DriveApiWrapper {
  final drive.DriveApi _driveApi;

  DefaultDriveApiWrapper(http.Client client)
    : _driveApi = drive.DriveApi(client);

  @override
  Future<drive.FileList> listFiles({
    required String spaces,
    required String q,
    required String fields,
  }) {
    return _driveApi.files.list(spaces: spaces, q: q, $fields: fields);
  }

  @override
  Future<drive.File> createFile(drive.File file, {drive.Media? uploadMedia}) {
    return _driveApi.files.create(file, uploadMedia: uploadMedia);
  }

  @override
  Future<drive.File> updateFile(
    drive.File file,
    String fileId, {
    drive.Media? uploadMedia,
  }) {
    return _driveApi.files.update(file, fileId, uploadMedia: uploadMedia);
  }

  @override
  Future<void> deleteFile(String fileId) {
    return _driveApi.files.delete(fileId);
  }

  @override
  Future<drive.Media> downloadFile(String fileId) async {
    return await _driveApi.files.get(
          fileId,
          downloadOptions: drive.DownloadOptions.fullMedia,
        )
        as drive.Media;
  }
}

class GoogleDriveSyncService extends CloudSyncService with CloudSyncDataMixin {
  static const _backupFileName = 'garage_backup.json';
  static const _lastSyncKey = 'google_drive_last_sync';

  final GoogleSignInWrapper _googleSignIn;
  final Future<SharedPreferences> Function() _getPrefs;
  DriveApiWrapper? _driveApi;

  /// Creates a GoogleDriveSyncService with optional dependency injection.
  ///
  /// For production, use the default constructor without parameters.
  /// For testing, inject mock implementations.
  GoogleDriveSyncService({
    GoogleSignInWrapper? googleSignIn,
    Future<SharedPreferences> Function()? getPrefs,
    DriveApiWrapper? driveApi,
  }) : _googleSignIn = googleSignIn ?? DefaultGoogleSignInWrapper(),
       _getPrefs = getPrefs ?? SharedPreferences.getInstance,
       _driveApi = driveApi;

  /// For testing: allows setting the DriveApi directly.
  void setDriveApiForTesting(DriveApiWrapper api) {
    _driveApi = api;
  }

  @override
  CloudProvider get provider => CloudProvider.googleDrive;

  @override
  Future<bool> isAvailable() async {
    // Google Drive is available on both iOS and Android
    return true;
  }

  @override
  Future<bool> isAuthenticated() async {
    return _googleSignIn.currentUser != null ||
        await _googleSignIn.isSignedIn();
  }

  @override
  Future<CloudSyncResult> authenticate() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        return CloudSyncResult.failure('登入已取消');
      }

      // Initialize Drive API
      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null) {
        return CloudSyncResult.failure('無法取得認證');
      }
      _driveApi = DefaultDriveApiWrapper(httpClient);

      return CloudSyncResult.success();
    } catch (e) {
      return CloudSyncResult.failure('登入失敗：${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _driveApi = null;
  }

  @override
  Future<CloudSyncResult> uploadData() async {
    try {
      // Ensure we have a valid Drive API client
      if (!await _ensureDriveApi()) {
        return CloudSyncResult.failure('請先登入 Google 帳號');
      }

      // Get app data to export
      final exportData = await getExportData();
      if (exportData == null) {
        return CloudSyncResult.failure('無法取得匯出資料');
      }

      // Check if backup file already exists
      final existingFileId = await _findBackupFile();

      // Create or update the backup file
      final media = drive.Media(
        Stream.value(utf8.encode(exportData)),
        utf8.encode(exportData).length,
      );

      if (existingFileId != null) {
        // Update existing file
        await _driveApi!.updateFile(
          drive.File(),
          existingFileId,
          uploadMedia: media,
        );
      } else {
        // Create new file in app data folder
        final driveFile = drive.File()
          ..name = _backupFileName
          ..parents = ['appDataFolder'];

        await _driveApi!.createFile(driveFile, uploadMedia: media);
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
      // Ensure we have a valid Drive API client
      if (!await _ensureDriveApi()) {
        return CloudSyncResult.failure('請先登入 Google 帳號');
      }

      // Find the backup file
      final fileId = await _findBackupFile();
      if (fileId == null) {
        return CloudSyncResult.failure('雲端沒有備份資料');
      }

      // Download the file content
      final response = await _driveApi!.downloadFile(fileId);

      final bytes = <int>[];
      await for (final chunk in response.stream) {
        bytes.addAll(chunk);
      }
      final jsonString = utf8.decode(bytes);

      // Restore the data
      final success = await restoreData(jsonString);
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
    final prefs = await _getPrefs();
    final timestamp = prefs.getInt(_lastSyncKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  @override
  Future<CloudSyncResult> deleteBackup() async {
    try {
      // Ensure we have a valid Drive API client
      if (!await _ensureDriveApi()) {
        return CloudSyncResult.failure('請先登入 Google 帳號');
      }

      // Find the backup file
      final fileId = await _findBackupFile();
      if (fileId == null) {
        return CloudSyncResult.failure('雲端沒有備份資料');
      }

      // Delete the backup file
      await _driveApi!.deleteFile(fileId);

      // Clear local sync time record
      final prefs = await _getPrefs();
      await prefs.remove(_lastSyncKey);

      return CloudSyncResult.success();
    } catch (e) {
      return CloudSyncResult.failure('刪除失敗：${e.toString()}');
    }
  }

  // Private helper methods

  Future<bool> _ensureDriveApi() async {
    if (_driveApi != null) return true;

    // Try to restore from silent sign-in
    try {
      final account = await _googleSignIn.signInSilently();
      if (account == null) return false;

      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null) return false;

      _driveApi = DefaultDriveApiWrapper(httpClient);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> _findBackupFile() async {
    try {
      final fileList = await _driveApi!.listFiles(
        spaces: 'appDataFolder',
        q: "name = '$_backupFileName'",
        fields: 'files(id, name)',
      );

      if (fileList.files == null || fileList.files!.isEmpty) {
        return null;
      }

      return fileList.files!.first.id;
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveLastSyncTime(DateTime time) async {
    final prefs = await _getPrefs();
    await prefs.setInt(_lastSyncKey, time.millisecondsSinceEpoch);
  }
}
