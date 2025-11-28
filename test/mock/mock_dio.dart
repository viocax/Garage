import 'package:dio/dio.dart';

/// Mock Dio 類別，使用組合模式包裝 Dio
///
/// 用於測試時模擬 HTTP 請求和回應
///
/// 使用方式：
/// ```dart
/// final mockDio = MockDio();
///
/// // 設定模擬回應
/// mockDio.setMockResponse(Response(
///   data: {'message': 'success'},
///   statusCode: 200,
///   requestOptions: RequestOptions(path: '/test'),
/// ));
///
/// // 或設定模擬錯誤
/// mockDio.setMockError(DioException(
///   requestOptions: RequestOptions(path: '/test'),
///   type: DioExceptionType.connectionTimeout,
/// ));
///
/// // 使用時和一般 Dio 一樣
/// final response = await mockDio.get('/api/test');
/// ```
class MockDio implements Dio {
  /// 模擬的回應
  Response? _mockResponse;

  /// 模擬的錯誤
  DioException? _mockError;

  /// 記錄最後一次請求的 URL
  String? lastRequestUrl;

  /// 記錄最後一次請求的方法
  String? lastRequestMethod;

  /// 記錄最後一次請求的參數
  Map<String, dynamic>? lastQueryParameters;

  /// 記錄最後一次請求的 Body
  dynamic lastRequestBody;

  /// 記錄最後一次請求的 Headers
  Map<String, dynamic>? lastRequestHeaders;

  /// 請求計數器
  int requestCount = 0;

  /// 所有請求的歷史記錄
  final List<RequestRecord> requestHistory = [];

  @override
  late BaseOptions options;

  @override
  final Interceptors interceptors = Interceptors();

  @override
  late HttpClientAdapter httpClientAdapter;

  @override
  late Transformer transformer;

  MockDio([BaseOptions? baseOptions]) {
    options = baseOptions ?? BaseOptions();
    httpClientAdapter = HttpClientAdapter();
    transformer = BackgroundTransformer();
  }

  /// 設定模擬回應
  void setMockResponse(Response response) {
    _mockResponse = response;
    _mockError = null;
  }

  /// 設定模擬錯誤
  void setMockError(DioException error) {
    _mockError = error;
    _mockResponse = null;
  }

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _handleRequest<T>(
      'GET',
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _handleRequest<T>(
      'POST',
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  @override
  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _handleRequest<T>(
      'PUT',
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  @override
  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _handleRequest<T>(
      'DELETE',
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  @override
  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _handleRequest<T>(
      'PATCH',
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  @override
  Future<Response<T>> head<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _handleRequest<T>(
      'HEAD',
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  @override
  Future<Response<T>> request<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _handleRequest<T>(
      options?.method ?? 'GET',
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  @override
  Future<Response> download(
    String urlPath,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Object? data,
    Options? options,
    FileAccessMode fileAccessMode = FileAccessMode.write,
  }) async {
    return _handleRequest(
      'DOWNLOAD',
      urlPath,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  @override
  Future<Response> downloadUri(
    Uri uri,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Object? data,
    Options? options,
    FileAccessMode fileAccessMode = FileAccessMode.write,
  }) async {
    return download(
      uri.toString(),
      savePath,
      onReceiveProgress: onReceiveProgress,
      cancelToken: cancelToken,
      deleteOnError: deleteOnError,
      lengthHeader: lengthHeader,
      data: data,
      options: options,
      fileAccessMode: fileAccessMode,
    );
  }

  @override
  Future<Response<T>> deleteUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return delete<T>(
      uri.toString(),
      data: data,
      options: options,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<Response<T>> getUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    return get<T>(
      uri.toString(),
      data: data,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  @override
  Future<Response<T>> headUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return head<T>(
      uri.toString(),
      data: data,
      options: options,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<Response<T>> patchUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return patch<T>(
      uri.toString(),
      data: data,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  @override
  Future<Response<T>> postUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return post<T>(
      uri.toString(),
      data: data,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  @override
  Future<Response<T>> putUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return put<T>(
      uri.toString(),
      data: data,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  @override
  Future<Response<T>> requestUri<T>(
    Uri uri, {
    Object? data,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return request<T>(
      uri.toString(),
      data: data,
      cancelToken: cancelToken,
      options: options,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  @override
  Future<Response<T>> fetch<T>(RequestOptions requestOptions) async {
    return _handleRequest<T>(
      requestOptions.method,
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
      ),
    );
  }

  @override
  void close({bool force = false}) {
    // Mock implementation - 不需要實際關閉
  }

  @override
  Dio clone({
    HttpClientAdapter? httpClientAdapter,
    Interceptors? interceptors,
    BaseOptions? options,
    Transformer? transformer,
  }) {
    return MockDio(options ?? this.options);
  }

  /// 處理請求並返回模擬回應
  Future<Response<T>> _handleRequest<T>(
    String method,
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    // 記錄請求資訊
    requestCount++;
    lastRequestMethod = method;
    lastRequestUrl = path;
    lastQueryParameters = queryParameters;
    lastRequestBody = data;
    lastRequestHeaders = options?.headers;

    // 記錄到歷史
    requestHistory.add(
      RequestRecord(
        method: method,
        url: path,
        queryParameters: queryParameters,
        body: data,
        headers: options?.headers,
      ),
    );

    // 如果設定了錯誤，拋出錯誤
    if (_mockError != null) {
      throw _mockError!;
    }

    // 如果設定了回應，返回回應
    if (_mockResponse != null) {
      return _mockResponse! as Response<T>;
    }

    // 預設回應
    return Response<T>(
      data: {} as T,
      statusCode: 200,
      requestOptions: RequestOptions(
        path: path,
        method: method,
        data: data,
        queryParameters: queryParameters,
      ),
    );
  }

  /// 重置 Mock 狀態
  void reset() {
    _mockResponse = null;
    _mockError = null;
    lastRequestUrl = null;
    lastRequestMethod = null;
    lastQueryParameters = null;
    lastRequestBody = null;
    lastRequestHeaders = null;
    requestCount = 0;
    requestHistory.clear();
  }
}

/// 請求記錄
class RequestRecord {
  final String method;
  final String url;
  final Map<String, dynamic>? queryParameters;
  final dynamic body;
  final Map<String, dynamic>? headers;

  RequestRecord({
    required this.method,
    required this.url,
    this.queryParameters,
    this.body,
    this.headers,
  });

  @override
  String toString() {
    return 'RequestRecord(method: $method, url: $url, queryParameters: $queryParameters, body: $body, headers: $headers)';
  }
}
