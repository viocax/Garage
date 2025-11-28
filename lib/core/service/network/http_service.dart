import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_request.dart';
import 'http_method.dart';
import 'http_exception.dart' as custom;

/// HTTP 服務
///
/// 負責執行 API 請求，基於抽象的 [ApiRequest] 介面。
/// 使用 Dio 套件，支援請求取消、攔截器等進階功能。
class HttpService {
  final Dio _dio;

  HttpService({
    Dio? dio,
    Duration defaultTimeout = const Duration(seconds: 30),
  }) : _dio = dio ?? Dio() {
    // 設定預設配置
    _dio.options = BaseOptions(
      connectTimeout: defaultTimeout,
      receiveTimeout: defaultTimeout,
      sendTimeout: defaultTimeout,
      validateStatus: (status) => status != null && status < 500,
    );

    // 添加 Log 攔截器（僅在 Debug 模式）
    if (kDebugMode) {
      _dio.interceptors.add(_LogInterceptor());
    }
  }

  /// 執行 API 請求
  ///
  /// [request] API 請求物件，包含所有請求參數
  /// [cancelToken] 可選的取消令牌，用於取消請求
  /// 返回經過 [ApiRequest.parseResponse] 解析後的結果
  Future<T> execute<T>(
    ApiRequest<T> request, {
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final response = await _sendRequest(
        request,
        cancelToken,
        onSendProgress: onSendProgress,
      );
      return request.parseResponse(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e, stackTrace) {
      debugPrint('✗ Unexpected error: $e');
      throw custom.HttpException(
        '請求失敗: $e',
        stackTrace: stackTrace,
      );
    }
  }

  /// 下載檔案
  ///
  /// [request] API 請求物件
  /// [savePath] 檔案儲存路徑
  /// [cancelToken] 可選的取消令牌
  /// [onReceiveProgress] 下載進度回調
  Future<void> download(
    ApiRequest request,
    String savePath, {
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      await _dio.download(
        request.fullUrl,
        savePath,
        queryParameters: request.queryParameters,
        options: Options(
          method: _getMethodString(request.method),
          headers: request.headers,
          receiveTimeout: request.timeout ?? _dio.options.receiveTimeout,
        ),
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }


  /// 發送 HTTP 請求
  Future<Response> _sendRequest(
    ApiRequest request,
    CancelToken? cancelToken, {
    ProgressCallback? onSendProgress,
  }) async {
    final options = Options(
      method: _getMethodString(request.method),
      headers: request.headers,
      receiveTimeout: request.timeout ?? _dio.options.receiveTimeout,
      sendTimeout: request.timeout ?? _dio.options.sendTimeout,
    );

    return await _dio.request(
      request.fullUrl,
      queryParameters: request.queryParameters,
      data: request.body,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
    );
  }

  /// 將 HttpMethod 轉換為字串
  String _getMethodString(HttpMethod method) {
    switch (method) {
      case HttpMethod.get:
        return 'GET';
      case HttpMethod.post:
        return 'POST';
      case HttpMethod.put:
        return 'PUT';
      case HttpMethod.delete:
        return 'DELETE';
      case HttpMethod.patch:
        return 'PATCH';
      case HttpMethod.head:
        return 'HEAD';
    }
  }

  /// 處理 Dio 異常
  custom.HttpException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return custom.HttpException(
          '請求超時',
          statusCode: 408,
          stackTrace: e.stackTrace,
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        return custom.HttpException(
          _getErrorMessage(statusCode, e.response?.data),
          statusCode: statusCode,
          response: e.response?.data,
          stackTrace: e.stackTrace,
        );

      case DioExceptionType.cancel:
        return custom.HttpException(
          '請求已取消',
          stackTrace: e.stackTrace,
        );

      case DioExceptionType.connectionError:
        return custom.HttpException(
          '網路連線失敗，請檢查網路設定',
          stackTrace: e.stackTrace,
        );

      case DioExceptionType.badCertificate:
        return custom.HttpException(
          'SSL 憑證驗證失敗',
          stackTrace: e.stackTrace,
        );

      case DioExceptionType.unknown:
      // default:
        return custom.HttpException(
          '未知錯誤: ${e.message}',
          stackTrace: e.stackTrace,
        );
    }
  }

  /// 取得錯誤訊息
  String _getErrorMessage(int? statusCode, dynamic responseData) {
    // 先嘗試從回應資料中取得錯誤訊息
    if (responseData != null) {
      try {
        if (responseData is Map) {
          final message = responseData['message'] ?? responseData['error'];
          if (message != null) return message.toString();
        }
      } catch (e) {
        // 忽略解析錯誤
      }
    }

    // 根據狀態碼返回預設訊息
    switch (statusCode) {
      case 400:
        return '請求參數錯誤';
      case 401:
        return '未授權，請重新登入';
      case 403:
        return '無權限存取';
      case 404:
        return '資源不存在';
      case 408:
        return '請求超時';
      case 429:
        return '請求次數過多，請稍後再試';
      case 500:
        return '伺服器內部錯誤';
      case 502:
        return '伺服器網關錯誤';
      case 503:
        return '服務暫時無法使用';
      default:
        return '請求失敗 ($statusCode)';
    }
  }

  /// 取得 Dio 實例（用於進階配置）
  Dio get dio => _dio;

  /// 關閉 HTTP 客戶端
  void close({bool force = false}) {
    _dio.close(force: force);
  }
}

/// 自訂 Log 攔截器
class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('╔══════════════════════════════════════════════════════════════');
    debugPrint('║ ${options.method}: ${options.uri}');
    if (options.queryParameters.isNotEmpty) {
      debugPrint('║ Query: ${options.queryParameters}');
    }
    if (options.data != null) {
      debugPrint('║ Body: ${options.data}');
    }
    if (options.headers.isNotEmpty) {
      debugPrint('║ Headers: ${options.headers}');
    }
    debugPrint('╚══════════════════════════════════════════════════════════════');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('✓ Response: ${response.statusCode} - ${response.requestOptions.uri}');
    debugPrint('  Data: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('✗ Error: ${err.type} - ${err.requestOptions.uri}');
    debugPrint('  Message: ${err.message}');
    if (err.response != null) {
      debugPrint('  Status: ${err.response?.statusCode}');
      debugPrint('  Data: ${err.response?.data}');
    }
    handler.next(err);
  }
}
