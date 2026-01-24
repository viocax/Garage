import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:garage/core/models/speed_camera_model.dart';
import 'package:garage/core/models/user_settings.dart';
import 'package:garage/core/repositories/local_speed_camera_repository.dart';
import 'package:garage/core/service/location/location_service.dart';
import 'package:garage/core/service/tts/tts_service.dart';
import 'package:garage/core/repositories/user_settings_repository.dart';
import 'package:geolocator/geolocator.dart';

class MockLocationService extends Mock implements LocationService {}

class MockTtsService extends Mock implements TtsService {}

class MockUserSettingsRepository extends Mock
    implements UserSettingsRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockLocationService mockLocation;
  late MockTtsService mockTts;
  late MockUserSettingsRepository mockSettingsRepo;
  late LocalSpeedCameraRepository repository;
  late StreamController<Position> positionController;

  setUp(() {
    mockLocation = MockLocationService();
    mockTts = MockTtsService();
    mockSettingsRepo = MockUserSettingsRepository();
    positionController = StreamController<Position>.broadcast();

    when(
      () =>
          mockLocation.requestPermission(background: any(named: 'background')),
    ).thenAnswer((_) async => PermissionCase.enable);
    when(
      () => mockLocation.getPositionStream(),
    ).thenAnswer((_) => positionController.stream);
    when(() => mockSettingsRepo.loadSettings()).thenAnswer(
      (_) => Future.value(
        const UserSettings(isVoiceAlertEnabled: true, alertDistance: 500),
      ),
    );

    // Stub TTS speak
    when(() => mockTts.speak(any())).thenAnswer((_) async {});

    repository = LocalSpeedCameraRepository(
      locationService: mockLocation,
      ttsService: mockTts,
      userSettingsRepo: mockSettingsRepo,
    );
  });

  tearDown(() {
    positionController.close();
  });

  test('區間測速整合測試：進入 -> 更新 -> 離開', () async {
    // 1. 初始化資料（載入 Mock 數據）
    await repository.syncFromRemote();

    final results = <SpeedCameraModel?>[];
    await repository.startLocationTracking((model) {
      results.add(model);
    });

    // 2. 模擬靠近起點 (MOCK_START: 25.0330, 121.5654)
    // 距離約 440m 處觸發進入
    final startTime = DateTime(2026, 1, 1, 12, 0, 0);
    positionController.add(
      Position(
        latitude: 25.0290, // 約南邊 440m (0.004度)
        longitude: 121.5654,
        timestamp: startTime,
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 16.67, // 60km/h
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 100));
    verify(() => mockTts.speak(any(that: contains('進入區間測速')))).called(1);

    // 3. 模擬在區間內行駛 1km (耗時 60s)
    // 預期平均速度 60km/h
    positionController.add(
      Position(
        latitude: 25.0380,
        longitude: 121.5654,
        timestamp: startTime.add(const Duration(seconds: 60)),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 16.67,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 100));
    final midState = results.last;
    expect(midState?.isInterval, isTrue);
    expect(midState?.averageSpeed, closeTo(60.0, 5.0)); // 允許經緯度計算誤差

    // 4. 模擬超速 (行駛 1km 僅耗時 30s)
    // 累積距離 2km, 總耗時 90s -> 80km/h
    positionController.add(
      Position(
        latitude: 25.0430, // 到達終點 MOCK_END
        longitude: 121.5654,
        timestamp: startTime.add(const Duration(seconds: 90)),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 22.22, // 80km/h
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 100));
    final endState = results.last;
    expect(endState?.isInterval, isTrue);
    expect(endState?.averageSpeed, greaterThan(60.0));

    // 驗證離開提醒
    verify(() => mockTts.speak('離開區間測速')).called(1);
  });
}
