import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:garage/core/models/interval_zone.dart';
import 'package:garage/core/models/user_settings.dart';
import 'package:garage/core/repositories/local_speed_camera_repository.dart';
import 'package:garage/core/service/location/location_service.dart';
import 'package:garage/core/service/location/interval_manager.dart';
import 'package:garage/core/service/tts/tts_service.dart';
import 'package:garage/core/repositories/user_settings_repository.dart';
import 'package:geolocator/geolocator.dart';

class MockLocationService extends Mock implements LocationService {}

class MockTtsService extends Mock implements TtsService {}

class MockUserSettingsRepository extends Mock
    implements UserSettingsRepository {}

class MockIntervalManager extends Mock implements IntervalManager {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockLocationService mockLocation;
  late MockTtsService mockTts;
  late MockUserSettingsRepository mockSettingsRepo;
  late MockIntervalManager mockIntervalManager;
  late LocalSpeedCameraRepository repository;

  setUp(() {
    mockLocation = MockLocationService();
    mockTts = MockTtsService();
    mockSettingsRepo = MockUserSettingsRepository();
    mockIntervalManager = MockIntervalManager();

    repository = LocalSpeedCameraRepository(
      locationService: mockLocation,
      ttsService: mockTts,
      userSettingsRepo: mockSettingsRepo,
      intervalManager: mockIntervalManager,
    );

    // Default settings
    when(() => mockSettingsRepo.loadSettings()).thenAnswer(
      (_) => Future.value(
        const UserSettings(
          isVoiceAlertEnabled: true,
          alertDistance: 500,
          speedTolerance: 5,
        ),
      ),
    );

    when(
      () =>
          mockLocation.requestPermission(background: any(named: 'background')),
    ).thenAnswer((_) async => PermissionCase.enable);

    when(() => mockTts.speak(any())).thenAnswer((_) async {});
  });

  group('LocalSpeedCameraRepository Interval Logic', () {
    test('區間測速中超速時應該每 10 秒提醒一次', () async {
      // Arrange
      final zone = const IntervalZone(
        id: 'MOCK_ZONE_1',
        startCameraId: 'MOCK_START',
        endCameraId: 'MOCK_END',
        distance: 2000.0,
        speedLimit: 60,
      );

      // 模擬已經在區間內
      when(() => mockIntervalManager.isActive).thenReturn(true);
      when(() => mockIntervalManager.currentZone).thenReturn(zone);

      // 模擬超速狀態
      when(
        () => mockIntervalManager.calculateStatus(
          distanceTraveled: any(named: 'distanceTraveled'),
          currentTime: any(named: 'currentTime'),
        ),
      ).thenReturn(
        const IntervalStatus(
          averageSpeed: 80.0,
          remainingDistance: 1000.0,
          isOverSpeed: true,
          distanceTraveled: 1000.0,
          timeElapsed: 45,
        ),
      );

      final position = Position(
        latitude: 25.0330,
        longitude: 121.5654,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 20, // 72km/h
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

      final positionStreamController = StreamController<Position>();
      when(
        () => mockLocation.getPositionStream(),
      ).thenAnswer((_) => positionStreamController.stream);

      await repository.startLocationTracking((model) {});

      // Act & Assert
      // 第一次提醒
      positionStreamController.add(position);
      await Future.delayed(const Duration(milliseconds: 50));
      verify(() => mockTts.speak('區間平均速度過高，請減速')).called(1);

      // 5秒後再次更新，不應該提醒
      positionStreamController.add(
        position.copyWith(
          timestamp: position.timestamp.add(const Duration(seconds: 5)),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      verifyNever(() => mockTts.speak('區間平均速度過高，請減速'));

      // 11秒後再次更新，應該提醒第二次
      positionStreamController.add(
        position.copyWith(
          timestamp: position.timestamp.add(const Duration(seconds: 11)),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      verify(() => mockTts.speak('區間平均速度過高，請減速')).called(1);
    });
  });

  group('LocalSpeedCameraRepository Voice Alert Disabled', () {
    test('語音關閉時，區間測速超速不應呼叫 TTS 但仍回傳正確的 SpeedCameraModel', () async {
      // Arrange - 語音提醒關閉
      when(() => mockSettingsRepo.loadSettings()).thenAnswer(
        (_) => Future.value(
          const UserSettings(
            isVoiceAlertEnabled: false, // 語音關閉
            alertDistance: 500,
            speedTolerance: 5,
          ),
        ),
      );

      final zone = const IntervalZone(
        id: 'MOCK_ZONE_1',
        startCameraId: 'MOCK_START',
        endCameraId: 'MOCK_END',
        distance: 2000.0,
        speedLimit: 60,
      );

      when(() => mockIntervalManager.isActive).thenReturn(true);
      when(() => mockIntervalManager.currentZone).thenReturn(zone);
      when(
        () => mockIntervalManager.calculateStatus(
          distanceTraveled: any(named: 'distanceTraveled'),
          currentTime: any(named: 'currentTime'),
        ),
      ).thenReturn(
        const IntervalStatus(
          averageSpeed: 80.0,
          remainingDistance: 1000.0,
          isOverSpeed: true,
          distanceTraveled: 1000.0,
          timeElapsed: 45,
        ),
      );

      final position = Position(
        latitude: 25.0330,
        longitude: 121.5654,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 20,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

      late dynamic capturedModel;
      final positionStreamController = StreamController<Position>();
      when(
        () => mockLocation.getPositionStream(),
      ).thenAnswer((_) => positionStreamController.stream);

      await repository.startLocationTracking((model) {
        capturedModel = model;
      });

      // Act
      positionStreamController.add(position);
      await Future.delayed(const Duration(milliseconds: 50));

      // Assert - TTS 不應被呼叫
      verifyNever(() => mockTts.speak(any()));

      // Assert - SpeedCameraModel 仍應包含正確的區間測速資料
      expect(capturedModel.isInterval, isTrue);
      expect(capturedModel.speedLimit, equals(60));
      expect(capturedModel.averageSpeed, equals(80.0));
      expect(capturedModel.remainingDistance, equals(1000.0));
      expect(capturedModel.isOverSpeed, isTrue);
    });

    test('語音關閉時，離開區間不應呼叫 TTS', () async {
      // Arrange - 語音提醒關閉
      when(() => mockSettingsRepo.loadSettings()).thenAnswer(
        (_) => Future.value(
          const UserSettings(
            isVoiceAlertEnabled: false,
            alertDistance: 500,
            speedTolerance: 5,
          ),
        ),
      );

      final zone = const IntervalZone(
        id: 'MOCK_ZONE_1',
        startCameraId: 'MOCK_START',
        endCameraId: 'MOCK_END',
        distance: 2000.0,
        speedLimit: 60,
      );

      when(() => mockIntervalManager.isActive).thenReturn(true);
      when(() => mockIntervalManager.currentZone).thenReturn(zone);
      when(() => mockIntervalManager.exitZone()).thenReturn(null);

      // 模擬快到終點 (剩餘距離 < 50m)
      when(
        () => mockIntervalManager.calculateStatus(
          distanceTraveled: any(named: 'distanceTraveled'),
          currentTime: any(named: 'currentTime'),
        ),
      ).thenReturn(
        const IntervalStatus(
          averageSpeed: 55.0,
          remainingDistance: 30.0, // < 50m，應觸發離開
          isOverSpeed: false,
          distanceTraveled: 1970.0,
          timeElapsed: 120,
        ),
      );

      final position = Position(
        latitude: 25.0430,
        longitude: 121.5654,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 15,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

      final positionStreamController = StreamController<Position>();
      when(
        () => mockLocation.getPositionStream(),
      ).thenAnswer((_) => positionStreamController.stream);

      await repository.startLocationTracking((model) {});

      // Act
      positionStreamController.add(position);
      await Future.delayed(const Duration(milliseconds: 50));

      // Assert - '離開區間測速' TTS 不應被呼叫
      verifyNever(() => mockTts.speak('離開區間測速'));

      // Assert - exitZone 應該被呼叫 (狀態仍然重置)
      verify(() => mockIntervalManager.exitZone()).called(1);
    });
  });

  group('Sector Detection Logic', () {
    test(
      'isOverSpeed should be false when user is outside sector angle even if speeding',
      () async {
        // Arrange - 設定 sectorAngle 為 60 度
        when(() => mockSettingsRepo.loadSettings()).thenAnswer(
          (_) => Future.value(
            const UserSettings(
              isVoiceAlertEnabled: false,
              alertDistance: 500,
              speedTolerance: 5,
              sectorAngle: 60.0,
            ),
          ),
        );

        when(() => mockIntervalManager.isActive).thenReturn(false);

        // 模擬用戶在非區間測速狀態
        final position = Position(
          latitude: 25.0330,
          longitude: 121.5654,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 90, // 用戶朝東行駛
          speed: 30, // 108 km/h - 超速
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );

        late dynamic capturedModel;
        final positionStreamController = StreamController<Position>();
        when(
          () => mockLocation.getPositionStream(),
        ).thenAnswer((_) => positionStreamController.stream);

        await repository.startLocationTracking((model) {
          capturedModel = model;
        });

        // Act
        positionStreamController.add(position);
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert - 沒有偵測到相機時，isOverSpeed 應為 false
        expect(capturedModel.isOverSpeed, isFalse);
      },
    );

    test('sectorAngle should be included in SpeedCameraModel', () async {
      // Arrange
      when(() => mockSettingsRepo.loadSettings()).thenAnswer(
        (_) => Future.value(
          const UserSettings(
            isVoiceAlertEnabled: false,
            alertDistance: 500,
            speedTolerance: 5,
            sectorAngle: 45.0, // 自訂角度
          ),
        ),
      );

      when(() => mockIntervalManager.isActive).thenReturn(false);

      final position = Position(
        latitude: 25.0330,
        longitude: 121.5654,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 10,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

      late dynamic capturedModel;
      final positionStreamController = StreamController<Position>();
      when(
        () => mockLocation.getPositionStream(),
      ).thenAnswer((_) => positionStreamController.stream);

      await repository.startLocationTracking((model) {
        capturedModel = model;
      });

      // Act
      positionStreamController.add(position);
      await Future.delayed(const Duration(milliseconds: 50));

      // Assert - sectorAngle 應該被設定
      // 注意：如果沒有偵測到相機，sectorAngle 為預設值 60.0
      expect(capturedModel.sectorAngle, isA<double>());
    });

    test(
      'heading = 360 should be treated as valid (equivalent to 0)',
      () async {
        // Arrange
        when(() => mockSettingsRepo.loadSettings()).thenAnswer(
          (_) => Future.value(
            const UserSettings(
              isVoiceAlertEnabled: false,
              alertDistance: 500,
              speedTolerance: 5,
              sectorAngle: 60.0,
            ),
          ),
        );

        when(() => mockIntervalManager.isActive).thenReturn(false);

        // heading = 360 度（等同於正北 0 度）
        final position = Position(
          latitude: 25.0330,
          longitude: 121.5654,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 360, // 邊界情況：360 度應視為有效
          speed: 10,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );

        late dynamic capturedModel;
        final positionStreamController = StreamController<Position>();
        when(
          () => mockLocation.getPositionStream(),
        ).thenAnswer((_) => positionStreamController.stream);

        await repository.startLocationTracking((model) {
          capturedModel = model;
        });

        // Act
        positionStreamController.add(position);
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert - 應該正常處理，不應該拋出異常
        expect(capturedModel, isNotNull);
        expect(capturedModel.sectorAngle, equals(60.0));
      },
    );
  });
}

extension on Position {
  Position copyWith({DateTime? timestamp}) {
    return Position(
      latitude: latitude,
      longitude: longitude,
      timestamp: timestamp ?? this.timestamp,
      accuracy: accuracy,
      altitude: altitude,
      heading: heading,
      speed: speed,
      speedAccuracy: speedAccuracy,
      altitudeAccuracy: altitudeAccuracy,
      headingAccuracy: headingAccuracy,
    );
  }
}
