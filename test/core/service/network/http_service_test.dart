import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:garage/core/service/network/http_service.dart';
import 'package:garage/core/service/network/api_request.dart';
import 'package:garage/core/service/network/http_method.dart';
import 'package:garage/core/service/network/http_exception.dart' as custom;
import '../../../mock/mock_dio.dart';

void main() {
  late MockDio mockDio;
  late HttpService httpService;

  setUp(() {
    mockDio = MockDio();
    httpService = HttpService(dio: mockDio);
  });

  tearDown(() {
    mockDio.reset();
  });

  group('HttpService - execute', () {
    test('應該成功執行 GET 請求並解析回應', () async {
      // Arrange
      final testRequest = _TestGetRequest();
      final mockData = {'id': 1, 'name': 'Test User'};

      mockDio.setMockResponse(Response(
        data: mockData,
        statusCode: 200,
        requestOptions: RequestOptions(path: testRequest.fullUrl),
      ));

      // Act
      final result = await httpService.execute(testRequest);

      // Assert
      expect(result.id, 1);
      expect(result.name, 'Test User');
      expect(mockDio.requestCount, 1);
      expect(mockDio.lastRequestMethod, 'GET');
      expect(mockDio.lastRequestUrl, testRequest.fullUrl);
    });

    test('應該成功執行 POST 請求並傳送 body', () async {
      // Arrange
      final testRequest = _TestPostRequest();
      final mockData = {'id': 2, 'name': 'Created User'};

      mockDio.setMockResponse(Response(
        data: mockData,
        statusCode: 201,
        requestOptions: RequestOptions(path: testRequest.fullUrl),
      ));

      // Act
      final result = await httpService.execute(testRequest);

      // Assert
      expect(result.id, 2);
      expect(result.name, 'Created User');
      expect(mockDio.requestCount, 1);
      expect(mockDio.lastRequestMethod, 'POST');
      expect(mockDio.lastRequestBody, testRequest.body);
    });

    test('應該正確處理 query parameters', () async {
      // Arrange
      final testRequest = _TestGetRequestWithParams();
      final mockData = {'results': []};

      mockDio.setMockResponse(Response(
        data: mockData,
        statusCode: 200,
        requestOptions: RequestOptions(path: testRequest.fullUrl),
      ));

      // Act
      await httpService.execute(testRequest);

      // Assert
      expect(mockDio.lastQueryParameters, {'page': 1, 'limit': 10});
    });

    test('應該正確處理自訂 headers', () async {
      // Arrange
      final testRequest = _TestGetRequestWithHeaders();

      mockDio.setMockResponse(Response(
        data: <String, dynamic>{},
        statusCode: 200,
        requestOptions: RequestOptions(path: testRequest.fullUrl),
      ));

      // Act
      await httpService.execute(testRequest);

      // Assert
      expect(mockDio.lastRequestHeaders, {'Authorization': 'Bearer token123'});
    });
  });

  group('HttpService - 錯誤處理', () {
    test('應該處理連線超時錯誤', () async {
      // Arrange
      final testRequest = _TestGetRequest();

      mockDio.setMockError(DioException(
        requestOptions: RequestOptions(path: testRequest.fullUrl),
        type: DioExceptionType.connectionTimeout,
      ));

      // Act & Assert
      expect(
        () => httpService.execute(testRequest),
        throwsA(isA<custom.HttpException>().having(
          (e) => e.message,
          'message',
          '請求超時',
        )),
      );
    });

    test('應該處理連線錯誤', () async {
      // Arrange
      final testRequest = _TestGetRequest();

      mockDio.setMockError(DioException(
        requestOptions: RequestOptions(path: testRequest.fullUrl),
        type: DioExceptionType.connectionError,
      ));

      // Act & Assert
      expect(
        () => httpService.execute(testRequest),
        throwsA(isA<custom.HttpException>().having(
          (e) => e.message,
          'message',
          '網路連線失敗，請檢查網路設定',
        )),
      );
    });

    test('應該處理 404 錯誤', () async {
      // Arrange
      final testRequest = _TestGetRequest();

      mockDio.setMockError(DioException(
        requestOptions: RequestOptions(path: testRequest.fullUrl),
        type: DioExceptionType.badResponse,
        response: Response(
          statusCode: 404,
          requestOptions: RequestOptions(path: testRequest.fullUrl),
        ),
      ));

      // Act & Assert
      expect(
        () => httpService.execute(testRequest),
        throwsA(isA<custom.HttpException>().having(
          (e) => e.statusCode,
          'statusCode',
          404,
        )),
      );
    });

    test('應該處理 500 伺服器錯誤', () async {
      // Arrange
      final testRequest = _TestGetRequest();

      mockDio.setMockError(DioException(
        requestOptions: RequestOptions(path: testRequest.fullUrl),
        type: DioExceptionType.badResponse,
        response: Response(
          statusCode: 500,
          data: {'error': '伺服器錯誤'},
          requestOptions: RequestOptions(path: testRequest.fullUrl),
        ),
      ));

      // Act & Assert
      expect(
        () => httpService.execute(testRequest),
        throwsA(isA<custom.HttpException>()),
      );
    });

    test('應該處理請求取消', () async {
      // Arrange
      final testRequest = _TestGetRequest();

      mockDio.setMockError(DioException(
        requestOptions: RequestOptions(path: testRequest.fullUrl),
        type: DioExceptionType.cancel,
      ));

      // Act & Assert
      expect(
        () => httpService.execute(testRequest),
        throwsA(isA<custom.HttpException>().having(
          (e) => e.message,
          'message',
          '請求已取消',
        )),
      );
    });
  });

  group('HttpService - download', () {
    test('應該成功下載檔案', () async {
      // Arrange
      final testRequest = _TestGetRequest();
      final savePath = '/tmp/test.zip';

      mockDio.setMockResponse(Response(
        data: 'file content',
        statusCode: 200,
        requestOptions: RequestOptions(path: testRequest.fullUrl),
      ));

      // Act
      await httpService.download(testRequest, savePath);

      // Assert
      expect(mockDio.requestCount, 1);
      expect(mockDio.lastRequestMethod, 'DOWNLOAD');
      expect(mockDio.lastRequestUrl, testRequest.fullUrl);
    });
  });

  group('HttpService - 多次請求', () {
    test('應該正確追蹤多次請求', () async {
      // Arrange
      final testRequest1 = _TestGetRequest();
      final testRequest2 = _TestPostRequest();

      mockDio.setMockResponse(Response(
        data: {'id': 1, 'name': 'User 1'},
        statusCode: 200,
        requestOptions: RequestOptions(path: testRequest1.fullUrl),
      ));

      // Act - 第一次請求
      await httpService.execute(testRequest1);

      mockDio.setMockResponse(Response(
        data: {'id': 2, 'name': 'User 2'},
        statusCode: 201,
        requestOptions: RequestOptions(path: testRequest2.fullUrl),
      ));

      // Act - 第二次請求
      await httpService.execute(testRequest2);

      // Assert
      expect(mockDio.requestCount, 2);
      expect(mockDio.requestHistory.length, 2);
      expect(mockDio.requestHistory[0].method, 'GET');
      expect(mockDio.requestHistory[1].method, 'POST');
    });
  });
}

// ==================== Mock API Requests ====================

class _TestUser {
  final int id;
  final String name;

  _TestUser({required this.id, required this.name});
}

class _TestGetRequest implements ApiRequest<_TestUser> {
  @override
  String get baseUrl => 'https://api.example.com';

  @override
  String get path => '/users/1';

  @override
  HttpMethod get method => HttpMethod.get;

  @override
  Map<String, String>? get headers => null;

  @override
  Map<String, dynamic>? get queryParameters => null;

  @override
  dynamic get body => null;

  @override
  Duration? get timeout => null;

  @override
  String get fullUrl {
    final base = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final apiPath = path.startsWith('/') ? path : '/$path';
    return '$base$apiPath';
  }

  @override
  _TestUser parseResponse(dynamic response) {
    return _TestUser(
      id: response['id'] as int,
      name: response['name'] as String,
    );
  }
}

class _TestPostRequest implements ApiRequest<_TestUser> {
  @override
  String get baseUrl => 'https://api.example.com';

  @override
  String get path => '/users';

  @override
  HttpMethod get method => HttpMethod.post;

  @override
  Map<String, String>? get headers => null;

  @override
  Map<String, dynamic>? get queryParameters => null;

  @override
  dynamic get body => {'name': 'New User', 'email': 'user@example.com'};

  @override
  Duration? get timeout => null;

  @override
  String get fullUrl {
    final base = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final apiPath = path.startsWith('/') ? path : '/$path';
    return '$base$apiPath';
  }

  @override
  _TestUser parseResponse(dynamic response) {
    return _TestUser(
      id: response['id'] as int,
      name: response['name'] as String,
    );
  }
}

class _TestGetRequestWithParams implements ApiRequest<Map<String, dynamic>> {
  @override
  String get baseUrl => 'https://api.example.com';

  @override
  String get path => '/users';

  @override
  HttpMethod get method => HttpMethod.get;

  @override
  Map<String, String>? get headers => null;

  @override
  Map<String, dynamic>? get queryParameters => {'page': 1, 'limit': 10};

  @override
  dynamic get body => null;

  @override
  Duration? get timeout => null;

  @override
  String get fullUrl {
    final base = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final apiPath = path.startsWith('/') ? path : '/$path';
    return '$base$apiPath';
  }

  @override
  Map<String, dynamic> parseResponse(dynamic response) {
    return response as Map<String, dynamic>;
  }
}

class _TestGetRequestWithHeaders implements ApiRequest<Map<String, dynamic>> {
  @override
  String get baseUrl => 'https://api.example.com';

  @override
  String get path => '/protected';

  @override
  HttpMethod get method => HttpMethod.get;

  @override
  Map<String, String>? get headers => {'Authorization': 'Bearer token123'};

  @override
  Map<String, dynamic>? get queryParameters => null;

  @override
  dynamic get body => null;

  @override
  Duration? get timeout => null;

  @override
  String get fullUrl {
    final base = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final apiPath = path.startsWith('/') ? path : '/$path';
    return '$base$apiPath';
  }

  @override
  Map<String, dynamic> parseResponse(dynamic response) {
    return response as Map<String, dynamic>;
  }
}
