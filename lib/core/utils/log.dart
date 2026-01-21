import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// 全域 Log 工具
/// 提供統一的日誌記錄接口，封裝 logger 套件
/// 使用方式: Log.i('message')
class Log {
  Log._(); // 私有建構子，防止實例化

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: kDebugMode ? Level.trace : Level.warning,
  );

  /// 追蹤級別日誌（最詳細）
  static void t(String message) {
    _logger.t(message);
  }

  /// 除錯級別日誌
  static void d(String message) {
    _logger.d(message);
  }

  /// 資訊級別日誌
  static void i(String message) {
    _logger.i(message);
  }

  /// 警告級別日誌
  static void w(String message) {
    _logger.w(message);
  }

  /// 錯誤級別日誌
  static void e(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// 嚴重錯誤級別日誌
  static void f(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}
