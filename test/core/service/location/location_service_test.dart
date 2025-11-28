import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:garage/core/service/location/location_service.dart';
import '../../../mock/mock_geolocator.dart';

void main() {
  late MockGeolocator mockGeolocator;
  late LocationService locationService;

  setUp(() {
    mockGeolocator = MockGeolocator();
    locationService = LocationService(geolocator: mockGeolocator);
  });

  tearDown(() {
    mockGeolocator.reset();
  });

  group('LocationService - getCurrentPosition', () {
    test('應該成功取得當前位置（權限已授予）', () async {
      // Arrange
      final mockPosition = Position(
        latitude: 25.0330,
        longitude: 121.5654,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );

      mockGeolocator.setLocationServiceEnabled(true);
      mockGeolocator.setPermissionStatus(LocationPermission.always);
      mockGeolocator.setCurrentPosition(mockPosition);

      // Act
      final result = await locationService.getCurrentPosition();

      // Assert
      expect(result, isNotNull);
      expect(result?.latitude, 25.0330);
      expect(result?.longitude, 121.5654);
      expect(mockGeolocator.isLocationServiceEnabledCallCount, 1);
      expect(mockGeolocator.checkPermissionCallCount, 1);
      expect(mockGeolocator.getCurrentPositionCallCount, 1);
      expect(mockGeolocator.requestPermissionCallCount, 0); // 不需要請求權限
    });

    test('應該成功取得當前位置（使用 whileInUse 權限）', () async {
      // Arrange
      final mockPosition = Position(
        latitude: 24.1477,
        longitude: 120.6736,
        timestamp: DateTime.now(),
        accuracy: 5.0,
        altitude: 50.0,
        heading: 90.0,
        speed: 10.0,
        speedAccuracy: 1.0,
        altitudeAccuracy: 2.0,
        headingAccuracy: 5.0,
      );

      mockGeolocator.setLocationServiceEnabled(true);
      mockGeolocator.setPermissionStatus(LocationPermission.whileInUse);
      mockGeolocator.setCurrentPosition(mockPosition);

      // Act
      final result = await locationService.getCurrentPosition();

      // Assert
      expect(result, isNotNull);
      expect(result?.latitude, 24.1477);
      expect(result?.longitude, 120.6736);
    });

    test('當定位服務未開啟時應該返回 null', () async {
      // Arrange
      mockGeolocator.setLocationServiceEnabled(false);

      // Act
      final result = await locationService.getCurrentPosition();

      // Assert
      expect(result, isNull);
      expect(mockGeolocator.isLocationServiceEnabledCallCount, 1);
      expect(mockGeolocator.checkPermissionCallCount, 0); // 不應該檢查權限
      expect(mockGeolocator.getCurrentPositionCallCount, 0); // 不應該取得位置
    });

    test('當權限被拒絕且無法取得時應該返回 null', () async {
      // Arrange
      mockGeolocator.setLocationServiceEnabled(true);
      mockGeolocator.setPermissionStatus(LocationPermission.denied);
      mockGeolocator.setPermissionAfterRequest(LocationPermission.denied);

      // Act
      final result = await locationService.getCurrentPosition();

      // Assert
      expect(result, isNull);
      expect(mockGeolocator.isLocationServiceEnabledCallCount, 1);
      expect(mockGeolocator.checkPermissionCallCount, 1);
      expect(mockGeolocator.requestPermissionCallCount, 1); // 應該嘗試請求權限
      expect(mockGeolocator.getCurrentPositionCallCount, 0); // 不應該取得位置
    });

    test('當權限被永久拒絕時應該返回 null', () async {
      // Arrange
      mockGeolocator.setLocationServiceEnabled(true);
      mockGeolocator.setPermissionStatus(LocationPermission.deniedForever);

      // Act
      final result = await locationService.getCurrentPosition();

      // Assert
      expect(result, isNull);
      expect(mockGeolocator.isLocationServiceEnabledCallCount, 1);
      expect(mockGeolocator.checkPermissionCallCount, 1);
      expect(mockGeolocator.requestPermissionCallCount, 0); // 不應該請求權限
      expect(mockGeolocator.getCurrentPositionCallCount, 0); // 不應該取得位置
    });

    test('當權限從 denied 變為 always 時應該成功取得位置', () async {
      // Arrange
      final mockPosition = Position(
        latitude: 22.9997,
        longitude: 120.2270,
        timestamp: DateTime.now(),
        accuracy: 15.0,
        altitude: 10.0,
        heading: 180.0,
        speed: 5.0,
        speedAccuracy: 1.5,
        altitudeAccuracy: 3.0,
        headingAccuracy: 10.0,
      );

      mockGeolocator.setLocationServiceEnabled(true);
      mockGeolocator.setPermissionStatus(LocationPermission.denied);
      mockGeolocator.setPermissionAfterRequest(LocationPermission.always);
      mockGeolocator.setCurrentPosition(mockPosition);

      // Act
      final result = await locationService.getCurrentPosition();

      // Assert
      expect(result, isNotNull);
      expect(result?.latitude, 22.9997);
      expect(result?.longitude, 120.2270);
      expect(mockGeolocator.isLocationServiceEnabledCallCount, 1);
      expect(mockGeolocator.checkPermissionCallCount, 1);
      expect(mockGeolocator.requestPermissionCallCount, 1); // 應該請求權限
      expect(mockGeolocator.getCurrentPositionCallCount, 1);
    });

    test('當權限從 denied 變為 whileInUse 時應該成功取得位置', () async {
      // Arrange
      final mockPosition = Position(
        latitude: 23.6978,
        longitude: 120.9605,
        timestamp: DateTime.now(),
        accuracy: 8.0,
        altitude: 25.0,
        heading: 270.0,
        speed: 15.0,
        speedAccuracy: 2.0,
        altitudeAccuracy: 4.0,
        headingAccuracy: 8.0,
      );

      mockGeolocator.setLocationServiceEnabled(true);
      mockGeolocator.setPermissionStatus(LocationPermission.denied);
      mockGeolocator.setPermissionAfterRequest(LocationPermission.whileInUse);
      mockGeolocator.setCurrentPosition(mockPosition);

      // Act
      final result = await locationService.getCurrentPosition();

      // Assert
      expect(result, isNotNull);
      expect(result?.latitude, 23.6978);
      expect(result?.longitude, 120.9605);
      expect(mockGeolocator.requestPermissionCallCount, 1);
    });
  });

  group('LocationService - getPositionStream', () {
    test('應該成功返回位置流', () async {
      // Arrange
      final position1 = Position(
        latitude: 25.0330,
        longitude: 121.5654,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );

      final position2 = Position(
        latitude: 25.0340,
        longitude: 121.5664,
        timestamp: DateTime.now().add(const Duration(seconds: 1)),
        accuracy: 10.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 5.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );

      // Act
      final stream = locationService.getPositionStream();
      final positions = <Position>[];

      // 訂閱流
      final subscription = stream.listen((position) {
        positions.add(position);
      });

      // 添加位置數據到流
      mockGeolocator.addPositionToStream(position1);
      mockGeolocator.addPositionToStream(position2);

      // 等待流處理
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(positions.length, 2);
      expect(positions[0].latitude, 25.0330);
      expect(positions[0].longitude, 121.5654);
      expect(positions[1].latitude, 25.0340);
      expect(positions[1].longitude, 121.5664);
      expect(positions[1].speed, 5.0);

      // 清理
      await subscription.cancel();
      mockGeolocator.closePositionStream();
    });

    test('應該可以傳遞 LocationSettings', () {
      // Arrange
      final locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );

      // Act & Assert
      expect(
        () => locationService.getPositionStream(locationSettings: locationSettings),
        returnsNormally,
      );
    });

    test('位置流應該正確處理多個位置更新', () async {
      // Arrange
      final positions = List.generate(
        5,
        (index) => Position(
          latitude: 25.0330 + (index * 0.001),
          longitude: 121.5654 + (index * 0.001),
          timestamp: DateTime.now().add(Duration(seconds: index)),
          accuracy: 10.0,
          altitude: 0.0,
          heading: 0.0,
          speed: index.toDouble(),
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        ),
      );

      // Act
      final stream = locationService.getPositionStream();
      final receivedPositions = <Position>[];

      final subscription = stream.listen((position) {
        receivedPositions.add(position);
      });

      // 添加所有位置
      for (final position in positions) {
        mockGeolocator.addPositionToStream(position);
      }

      // 等待流處理
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(receivedPositions.length, 5);
      for (var i = 0; i < 5; i++) {
        expect(receivedPositions[i].latitude, positions[i].latitude);
        expect(receivedPositions[i].longitude, positions[i].longitude);
        expect(receivedPositions[i].speed, positions[i].speed);
      }

      // 清理
      await subscription.cancel();
      mockGeolocator.closePositionStream();
    });
  });

  group('LocationService - 權限處理邊界情況', () {
    test('當檢查定位服務時拋出異常應該正確處理', () async {
      // Arrange
      mockGeolocator.setError(Exception('定位服務檢查失敗'));

      // Act & Assert
      expect(
        () => locationService.getCurrentPosition(),
        throwsException,
      );
    });

    test('應該正確處理 unableToDetermine 權限狀態', () async {
      // Arrange
      mockGeolocator.setLocationServiceEnabled(true);
      mockGeolocator.setPermissionStatus(LocationPermission.unableToDetermine);
      mockGeolocator.setPermissionAfterRequest(LocationPermission.always);

      final mockPosition = Position(
        latitude: 25.0330,
        longitude: 121.5654,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );

      mockGeolocator.setCurrentPosition(mockPosition);

      // Act
      final result = await locationService.getCurrentPosition();

      // Assert
      // unableToDetermine 不是 denied 或 deniedForever，
      // 所以應該繼續獲取位置
      expect(result, isNotNull);
      expect(mockGeolocator.checkPermissionCallCount, 1);
    });
  });
}
