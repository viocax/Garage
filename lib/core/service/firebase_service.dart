import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:garage/core/utils/log.dart';

/// Interface for Crashlytics operations, allowing injection for testing.
abstract class CrashlyticsWrapper {
  Future<void> setCrashlyticsCollectionEnabled(bool enabled);
  Future<void> recordFlutterFatalError(FlutterErrorDetails details);
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal,
  });
  Future<void> log(String message);
  Future<void> setUserIdentifier(String identifier);
  Future<void> setCustomKey(String key, Object value);
  void crash();
}

/// Default implementation using actual FirebaseCrashlytics.
class DefaultCrashlyticsWrapper implements CrashlyticsWrapper {
  const DefaultCrashlyticsWrapper();

  FirebaseCrashlytics get _crashlytics => FirebaseCrashlytics.instance;

  @override
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) {
    return _crashlytics.setCrashlyticsCollectionEnabled(enabled);
  }

  @override
  Future<void> recordFlutterFatalError(FlutterErrorDetails details) {
    return _crashlytics.recordFlutterFatalError(details);
  }

  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) {
    return _crashlytics.recordError(
      exception,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }

  @override
  Future<void> log(String message) {
    return _crashlytics.log(message);
  }

  @override
  Future<void> setUserIdentifier(String identifier) {
    return _crashlytics.setUserIdentifier(identifier);
  }

  @override
  Future<void> setCustomKey(String key, Object value) {
    return _crashlytics.setCustomKey(key, value);
  }

  @override
  void crash() {
    _crashlytics.crash();
  }
}

/// Firebase 服務
/// 負責 Firebase 初始化及相關服務（如 Crashlytics）的管理
class FirebaseService {
  final CrashlyticsWrapper _crashlytics;

  /// Creates a FirebaseService with optional dependency injection.
  FirebaseService({CrashlyticsWrapper? crashlytics})
    : _crashlytics = crashlytics ?? const DefaultCrashlyticsWrapper();

  bool _isInitialized = false;

  /// 檢查 Firebase 是否已初始化
  bool get isInitialized => _isInitialized;

  /// For testing: manually set initialization state
  @visibleForTesting
  void setInitializedForTesting(bool value) {
    _isInitialized = value;
  }

  /// 初始化 Firebase 及相關服務
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      _isInitialized = true;
      Log.i('Firebase initialized successfully');

      // 初始化 Crashlytics
      await _initCrashlytics();
    } catch (e) {
      Log.e('Firebase initialization failed: $e', e);
      _isInitialized = false;
    }
  }

  /// 初始化 Crashlytics
  Future<void> _initCrashlytics() async {
    if (!_isInitialized) return;

    try {
      // 在 debug 模式下停用 Crashlytics
      await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

      // 捕獲 Flutter framework 錯誤
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (errorDetails) {
        if (_isInitialized) {
          _crashlytics.recordFlutterFatalError(errorDetails);
        }
        originalOnError?.call(errorDetails);
      };

      // 捕獲平台層錯誤（Platform Dispatcher）
      PlatformDispatcher.instance.onError = (error, stack) {
        if (_isInitialized) {
          _crashlytics.recordError(error, stack, fatal: true);
        }
        return true;
      };
    } catch (e) {
      Log.e('Crashlytics initialization failed: $e', e);
    }
  }

  // MARK: - Crashlytics Proxy Methods

  /// 記錄非致命錯誤
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    if (!_isInitialized) return;
    try {
      await _crashlytics.recordError(
        exception,
        stack,
        reason: reason,
        fatal: fatal,
      );
    } catch (_) {
      // 忽略記錄錯誤時的錯誤
    }
  }

  /// 記錄日誌（用於除錯上下文）
  Future<void> log(String message) async {
    if (!_isInitialized) return;
    try {
      await _crashlytics.log(message);
    } catch (_) {}
  }

  /// 設置用戶識別碼
  Future<void> setUserIdentifier(String identifier) async {
    if (!_isInitialized) return;
    try {
      await _crashlytics.setUserIdentifier(identifier);
    } catch (_) {}
  }

  /// 設置自定義鍵值對
  Future<void> setCustomKey(String key, Object value) async {
    if (!_isInitialized) return;
    try {
      await _crashlytics.setCustomKey(key, value);
    } catch (_) {}
  }

  /// 觸發測試崩潰（僅用於測試）
  void triggerTestCrash() {
    if (!_isInitialized) return;
    _crashlytics.crash();
  }
}
