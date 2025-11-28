/// HTTP 服務異常
class HttpException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic response;
  final StackTrace? stackTrace;

  HttpException(
    this.message, {
    this.statusCode,
    this.response,
    this.stackTrace,
  });

  @override
  String toString() {
    if (statusCode != null) {
      return 'HttpException: $message (Status: $statusCode)';
    }
    return 'HttpException: $message';
  }

  /// 是否為網路連線錯誤
  bool get isNetworkError => statusCode == null;

  /// 是否為客戶端錯誤 (4xx)
  bool get isClientError => statusCode != null && statusCode! >= 400 && statusCode! < 500;

  /// 是否為伺服器錯誤 (5xx)
  bool get isServerError => statusCode != null && statusCode! >= 500;

  /// 是否為超時錯誤
  bool get isTimeout => statusCode == 408;

  /// 是否為未授權錯誤
  bool get isUnauthorized => statusCode == 401;

  /// 是否為禁止存取錯誤
  bool get isForbidden => statusCode == 403;

  /// 是否為找不到資源錯誤
  bool get isNotFound => statusCode == 404;
}
