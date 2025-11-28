import 'http_method.dart';

/// API 請求抽象介面
///
/// 定義 API 請求的所有必要參數，包含：
/// - baseUrl: 基礎 URL
/// - path: API 路徑
/// - method: HTTP 方法
/// - headers: 請求標頭
/// - queryParameters: URL 查詢參數
/// - body: 請求體
/// - parseResponse: 回應解析方法
abstract class ApiRequest<T> {
  /// 基礎 URL (例如: https://api.example.com)
  String get baseUrl;

  /// API 路徑 (例如: /users, /posts/123)
  String get path;

  /// HTTP 方法
  HttpMethod get method;

  /// 自訂請求標頭
  Map<String, String>? get headers => null;

  /// URL 查詢參數 (例如: ?page=1&limit=10)
  Map<String, dynamic>? get queryParameters => null;

  /// 請求體（用於 POST、PUT、PATCH）
  dynamic get body => null;

  /// 請求超時時間（可選，使用預設值則為 null）
  Duration? get timeout => null;

  /// 解析 HTTP 回應為指定型別
  ///
  /// [response] 可能是：
  /// - Map`<`String, dynamic`>`（JSON 物件）
  /// - List`<`dynamic`>`（JSON 陣列）
  /// - String（原始字串）
  /// - null（空回應）
  T parseResponse(dynamic response);

  /// 取得完整的 URL
  String get fullUrl {
    final base = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final apiPath = path.startsWith('/') ? path : '/$path';
    return '$base$apiPath';
  }
}
