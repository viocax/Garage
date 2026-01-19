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
    ).thenAnswer((_) async => true);

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
