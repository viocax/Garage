import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/service/firebase_service.dart';

// Mock CrashlyticsWrapper
class MockCrashlyticsWrapper implements CrashlyticsWrapper {
  bool collectionEnabled = false;
  List<String> logs = [];
  List<Map<String, dynamic>> recordedErrors = [];
  String? userIdentifier;
  Map<String, Object> customKeys = {};
  bool crashCalled = false;
  FlutterErrorDetails? lastFlutterError;

  @override
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    collectionEnabled = enabled;
  }

  @override
  Future<void> recordFlutterFatalError(FlutterErrorDetails details) async {
    lastFlutterError = details;
  }

  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    recordedErrors.add({
      'exception': exception,
      'stack': stack,
      'reason': reason,
      'fatal': fatal,
    });
  }

  @override
  Future<void> log(String message) async {
    logs.add(message);
  }

  @override
  Future<void> setUserIdentifier(String identifier) async {
    userIdentifier = identifier;
  }

  @override
  Future<void> setCustomKey(String key, Object value) async {
    customKeys[key] = value;
  }

  @override
  void crash() {
    crashCalled = true;
  }

  void reset() {
    collectionEnabled = false;
    logs.clear();
    recordedErrors.clear();
    userIdentifier = null;
    customKeys.clear();
    crashCalled = false;
    lastFlutterError = null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FirebaseService', () {
    late MockCrashlyticsWrapper mockCrashlytics;
    late FirebaseService service;

    setUp(() {
      mockCrashlytics = MockCrashlyticsWrapper();
      service = FirebaseService(crashlytics: mockCrashlytics);
      // Manually set initialized to true for testing delegation logic
      service.setInitializedForTesting(true);
    });

    tearDown(() {
      mockCrashlytics.reset();
    });

    // Note: We cannot easily test initialize() here as it depends on Firebase Core
    // which requires platform channel mocking. We focus on testing the
    // Crashlytics delegation logic assuming initialization succeeded.

    group('recordError', () {
      test('should record non-fatal error when initialized', () async {
        final exception = Exception('Test error');
        final stack = StackTrace.current;

        await service.recordError(exception, stack);

        expect(mockCrashlytics.recordedErrors.length, 1);
        expect(mockCrashlytics.recordedErrors.first['exception'], exception);
        expect(mockCrashlytics.recordedErrors.first['fatal'], false);
      });

      test('should NOT record error when NOT initialized', () async {
        service.setInitializedForTesting(false);
        final exception = Exception('Test error');
        final stack = StackTrace.current;

        await service.recordError(exception, stack);

        expect(mockCrashlytics.recordedErrors.isEmpty, true);
      });

      test('should record fatal error', () async {
        final exception = Exception('Fatal error');
        final stack = StackTrace.current;

        await service.recordError(exception, stack, fatal: true);

        expect(mockCrashlytics.recordedErrors.length, 1);
        expect(mockCrashlytics.recordedErrors.first['fatal'], true);
      });

      test('should record error with reason', () async {
        final exception = Exception('Error with reason');
        const reason = 'Network failure';

        await service.recordError(exception, null, reason: reason);

        expect(mockCrashlytics.recordedErrors.first['reason'], reason);
      });
    });

    group('log', () {
      test('should log message when initialized', () async {
        const message = 'Debug log message';

        await service.log(message);

        expect(mockCrashlytics.logs, contains(message));
      });

      test('should NOT log message when NOT initialized', () async {
        service.setInitializedForTesting(false);
        const message = 'Debug log message';

        await service.log(message);

        expect(mockCrashlytics.logs.isEmpty, true);
      });
    });

    group('setUserIdentifier', () {
      test('should set user identifier', () async {
        const userId = 'user-123';

        await service.setUserIdentifier(userId);

        expect(mockCrashlytics.userIdentifier, userId);
      });
    });

    group('setCustomKey', () {
      test('should set string custom key', () async {
        await service.setCustomKey('app_version', '1.0.0');

        expect(mockCrashlytics.customKeys['app_version'], '1.0.0');
      });
    });

    group('triggerTestCrash', () {
      test('should call crash method', () {
        service.triggerTestCrash();

        expect(mockCrashlytics.crashCalled, isTrue);
      });
    });
  });
}
