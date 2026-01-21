import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/service/cloud_sync/google_drive_sync_service.dart';
import 'package:garage/core/service/cloud_sync/cloud_sync_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Mock implementations

class MockGoogleSignInWrapper implements GoogleSignInWrapper {
  GoogleSignInAccount? _currentUser;
  bool shouldSignInSucceed = true;
  bool shouldSilentSignInSucceed = true;
  bool shouldAuthClientSucceed = true;
  String? signInError;

  @override
  GoogleSignInAccount? get currentUser => _currentUser;

  @override
  Future<bool> isSignedIn() async => _currentUser != null;

  @override
  Future<GoogleSignInAccount?> signIn() async {
    if (signInError != null) {
      throw Exception(signInError);
    }
    if (!shouldSignInSucceed) {
      return null; // User cancelled
    }
    _currentUser = _MockGoogleSignInAccount();
    return _currentUser;
  }

  @override
  Future<GoogleSignInAccount?> signInSilently() async {
    if (!shouldSilentSignInSucceed) {
      return null;
    }
    _currentUser ??= _MockGoogleSignInAccount();
    return _currentUser;
  }

  @override
  Future<GoogleSignInAccount?> signOut() async {
    _currentUser = null;
    return null;
  }

  @override
  Future<http.Client?> authenticatedClient() async {
    if (!shouldAuthClientSucceed) {
      return null;
    }
    return _MockHttpClient();
  }

  void setSignedIn(bool value) {
    if (value) {
      _currentUser = _MockGoogleSignInAccount();
    } else {
      _currentUser = null;
    }
  }

  void reset() {
    _currentUser = null;
    shouldSignInSucceed = true;
    shouldSilentSignInSucceed = true;
    shouldAuthClientSucceed = true;
    signInError = null;
  }
}

class _MockGoogleSignInAccount implements GoogleSignInAccount {
  @override
  String get displayName => 'Test User';
  @override
  String get email => 'test@example.com';
  @override
  String get id => 'test-id';
  @override
  String? get photoUrl => null;
  @override
  String? get serverAuthCode => null;
  @override
  Future<GoogleSignInAuthentication> get authentication =>
      throw UnimplementedError();
  @override
  Future<Map<String, String>> get authHeaders async => {};
  @override
  Future<void> clearAuthCache() async {}
}

class _MockHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(Stream.value([]), 200);
  }
}

class MockDriveApiWrapper implements DriveApiWrapper {
  final List<drive.File> files = [];
  bool shouldFailOnList = false;
  bool shouldFailOnCreate = false;
  bool shouldFailOnUpdate = false;
  bool shouldFailOnDelete = false;
  bool shouldFailOnDownload = false;
  String? downloadContent;

  @override
  Future<drive.FileList> listFiles({
    required String spaces,
    required String q,
    required String fields,
  }) async {
    if (shouldFailOnList) {
      throw Exception('Mock list failure');
    }
    return drive.FileList()..files = files;
  }

  @override
  Future<drive.File> createFile(
    drive.File file, {
    drive.Media? uploadMedia,
  }) async {
    if (shouldFailOnCreate) {
      throw Exception('Mock create failure');
    }
    final newFile = drive.File()
      ..id = 'new-file-id'
      ..name = file.name;
    files.add(newFile);
    return newFile;
  }

  @override
  Future<drive.File> updateFile(
    drive.File file,
    String fileId, {
    drive.Media? uploadMedia,
  }) async {
    if (shouldFailOnUpdate) {
      throw Exception('Mock update failure');
    }
    return drive.File()..id = fileId;
  }

  @override
  Future<void> deleteFile(String fileId) async {
    if (shouldFailOnDelete) {
      throw Exception('Mock delete failure');
    }
    files.removeWhere((f) => f.id == fileId);
  }

  @override
  Future<drive.Media> downloadFile(String fileId) async {
    if (shouldFailOnDownload) {
      throw Exception('Mock download failure');
    }
    final content =
        downloadContent ?? '{"version":1,"vehicles":[],"records":[]}';
    return drive.Media(
      Stream.value(utf8.encode(content)),
      utf8.encode(content).length,
    );
  }

  void addFile(String name, String id) {
    files.add(
      drive.File()
        ..id = id
        ..name = name,
    );
  }

  void reset() {
    files.clear();
    shouldFailOnList = false;
    shouldFailOnCreate = false;
    shouldFailOnUpdate = false;
    shouldFailOnDelete = false;
    shouldFailOnDownload = false;
    downloadContent = null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GoogleDriveSyncService', () {
    late MockGoogleSignInWrapper mockGoogleSignIn;
    late MockDriveApiWrapper mockDriveApi;
    late GoogleDriveSyncService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockGoogleSignIn = MockGoogleSignInWrapper();
      mockDriveApi = MockDriveApiWrapper();
      service = GoogleDriveSyncService(
        googleSignIn: mockGoogleSignIn,
        driveApi: mockDriveApi,
      );
    });

    tearDown(() {
      mockGoogleSignIn.reset();
      mockDriveApi.reset();
    });

    group('provider', () {
      test('should return googleDrive', () {
        expect(service.provider, CloudProvider.googleDrive);
      });
    });

    group('isAvailable', () {
      test('should always return true', () async {
        final result = await service.isAvailable();
        expect(result, isTrue);
      });
    });

    group('isAuthenticated', () {
      test('should return false when not signed in', () async {
        mockGoogleSignIn.setSignedIn(false);
        final result = await service.isAuthenticated();
        expect(result, isFalse);
      });

      test('should return true when signed in', () async {
        mockGoogleSignIn.setSignedIn(true);
        final result = await service.isAuthenticated();
        expect(result, isTrue);
      });
    });

    group('authenticate', () {
      test('should return success when sign in succeeds', () async {
        mockGoogleSignIn.shouldSignInSucceed = true;
        mockGoogleSignIn.shouldAuthClientSucceed = true;

        final result = await service.authenticate();

        expect(result.success, isTrue);
        expect(result.errorMessage, isNull);
      });

      test('should return failure when user cancels sign in', () async {
        mockGoogleSignIn.shouldSignInSucceed = false;

        final result = await service.authenticate();

        expect(result.success, isFalse);
        expect(result.errorMessage, contains('取消'));
      });

      test('should return failure when auth client is null', () async {
        mockGoogleSignIn.shouldSignInSucceed = true;
        mockGoogleSignIn.shouldAuthClientSucceed = false;

        final result = await service.authenticate();

        expect(result.success, isFalse);
        expect(result.errorMessage, contains('認證'));
      });

      test('should return failure when sign in throws error', () async {
        mockGoogleSignIn.signInError = 'Network error';

        final result = await service.authenticate();

        expect(result.success, isFalse);
        expect(result.errorMessage, contains('失敗'));
      });
    });

    group('signOut', () {
      test('should sign out user', () async {
        mockGoogleSignIn.setSignedIn(true);

        await service.signOut();

        expect(mockGoogleSignIn.currentUser, isNull);
      });
    });

    group('getLastSyncTime', () {
      test('should return null when no sync time saved', () async {
        final result = await service.getLastSyncTime();
        expect(result, isNull);
      });

      test('should return saved sync time', () async {
        final prefs = await SharedPreferences.getInstance();
        final timestamp = DateTime(2026, 1, 14, 12, 0).millisecondsSinceEpoch;
        await prefs.setInt('google_drive_last_sync', timestamp);

        final result = await service.getLastSyncTime();

        expect(result, isNotNull);
        expect(result!.year, 2026);
        expect(result.month, 1);
        expect(result.day, 14);
      });
    });

    group('deleteBackup', () {
      test('should return failure when not authenticated', () async {
        // Create service without pre-injected driveApi so it tries to authenticate
        final serviceWithoutDriveApi = GoogleDriveSyncService(
          googleSignIn: mockGoogleSignIn,
          // Note: no driveApi injected, so it will try to authenticate
        );
        mockGoogleSignIn.shouldSilentSignInSucceed = false;

        final result = await serviceWithoutDriveApi.deleteBackup();

        expect(result.success, isFalse);
        expect(result.errorMessage, contains('登入'));
      });

      test('should return failure when no backup exists', () async {
        mockGoogleSignIn.setSignedIn(true);
        // No files in mockDriveApi

        final result = await service.deleteBackup();

        expect(result.success, isFalse);
        expect(result.errorMessage, contains('沒有備份'));
      });

      test('should delete backup successfully', () async {
        mockGoogleSignIn.setSignedIn(true);
        mockDriveApi.addFile('garage_backup.json', 'backup-id');

        final result = await service.deleteBackup();

        expect(result.success, isTrue);
        expect(mockDriveApi.files, isEmpty);
      });

      test('should clear sync time after delete', () async {
        mockGoogleSignIn.setSignedIn(true);
        mockDriveApi.addFile('garage_backup.json', 'backup-id');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('google_drive_last_sync', 12345);

        await service.deleteBackup();

        expect(prefs.getInt('google_drive_last_sync'), isNull);
      });
    });
  });
}
