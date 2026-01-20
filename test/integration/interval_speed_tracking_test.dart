import 'dart:async';
import 'package:garage/core/models/tts_speaking_token.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:garage/core/models/user_settings.dart';
import 'package:garage/core/repositories/local_speed_camera_repository.dart';
import 'package:garage/core/repositories/user_settings_repository.dart';
import 'package:garage/core/service/location/location_service.dart';
import 'package:garage/core/service/location/interval_manager.dart';
import 'package:garage/core/service/tts/tts_service.dart';
import 'package:garage/screen/speed/speedCamera/bloc/speed_bloc.dart';
import 'package:garage/screen/speed/speedCamera/bloc/speed_event.dart';
import 'package:garage/screen/speed/speedCamera/bloc/speed_state.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockLocationService extends Mock implements LocationService {}

class MockTtsService extends Mock implements TtsService {}

class MockUserSettingsRepository extends Mock
    implements UserSettingsRepository {}

// Helper to create Position
Position createPosition({
  required double lat,
  required double lon,
  double speedKmh = 50,
  double heading = 0, // North
  DateTime? time,
}) {
  return Position(
    latitude: lat,
    longitude: lon,
    timestamp: time ?? DateTime.now(),
    accuracy: 10,
    altitude: 10,
    heading: heading,
    speed: speedKmh / 3.6, // m/s
    speedAccuracy: 0,
    altitudeAccuracy: 0,
    headingAccuracy: 0,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(
      TTSSpeakingToken(
        currentSpeed: 0,
        speedLimit: 0,
        distance: 0,
        lastReportTime: DateTime.now(),
      ),
    );
    registerFallbackValue(
      Position(
        longitude: 0,
        latitude: 0,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      ),
    );
    registerFallbackValue(LocationPolicy.best);
  });

  late MockLocationService mockLocationService;
  late MockTtsService mockTtsService;
  late MockUserSettingsRepository mockUserSettingsRepo;
  late LocalSpeedCameraRepository speedCameraRepository;
  late StreamController<Position> positionStreamController;
  late SpeedBloc speedBloc; // The real Bloc

  setUp(() {
    mockLocationService = MockLocationService();
    mockTtsService = MockTtsService();
    mockUserSettingsRepo = MockUserSettingsRepository();
    positionStreamController = StreamController<Position>();

    // Mock Location Service
    when(
      () => mockLocationService.getPositionStream(),
    ).thenAnswer((_) => positionStreamController.stream);
    when(
      () => mockLocationService.requestPermission(
        background: any(named: 'background'),
      ),
    ).thenAnswer((_) async => true);
    when(
      () => mockLocationService.checkPermission(),
    ).thenAnswer((_) async => true);
    when(() => mockLocationService.updatePolicy(any())).thenAnswer((_) => {});

    // Mock TTS
    when(() => mockTtsService.speak(any())).thenAnswer((_) async {});
    when(() => mockTtsService.speakOverSpeed(any())).thenAnswer((_) async {});
    when(() => mockTtsService.setVolume(any())).thenAnswer((_) async {});

    // Mock User Settings
    when(() => mockUserSettingsRepo.loadSettings()).thenAnswer(
      (_) async => const UserSettings(
        isVoiceAlertEnabled: true,
        alertDistance: 500, // 500m alert distance
        speedTolerance: 10,
      ),
    );

    // Instantiate Repository (Integration Point 1)
    // We use the real IntervalManager inside the real Repository
    speedCameraRepository = LocalSpeedCameraRepository(
      locationService: mockLocationService,
      ttsService: mockTtsService,
      userSettingsRepo: mockUserSettingsRepo,
      intervalManager: IntervalManager(),
    );

    // Instantiate Bloc (Integration Point 2)
    speedBloc = SpeedBloc(
      speedCameraRepository: speedCameraRepository,
      userSettingsRepo: mockUserSettingsRepo,
    );
  });

  tearDown(() {
    positionStreamController.close();
    speedBloc.close();
  });

  group('Interval Speed Check Integration Test', () {
    test('完整模擬：進入區間 -> 行駛(正常) -> 行駛(超速) -> 離開區間', () async {
      await speedCameraRepository.syncFromRemote(force: true); // 載入 Mock Data
      await speedCameraRepository.syncFromRemote(force: true); // 載入 Mock Data

      // 等待 Bloc 初始化完成
      await Future.delayed(const Duration(milliseconds: 100));

      speedBloc.add(const StartDetection());
      await Future.delayed(const Duration(milliseconds: 100));

      expect((speedBloc.state as SpeedData).isDetecting, true);

      // 2. 接近區間起點 (25.0330, 121.5654)
      // 使用者在 (25.0300, 121.5654)，距離起點約 330m (緯度差 0.003 * 111km)
      // 0.003 * 111000 = 333m. 在 500m alertDistance 內。

      final startTime = DateTime.now();

      // Step 2.1: 觸發 Warning (接近起點)
      positionStreamController.add(
        createPosition(lat: 25.0300, lon: 121.5654, time: startTime),
      );

      await Future.delayed(const Duration(milliseconds: 100));

      // 驗證 Bloc 狀態：顯示距離和速限
      // 330m <= 500m (Alert Distance), 且觸發了 500m 閾值
      // 所以會觸發進入區間邏輯
      verify(() => mockTtsService.speak('進入區間測速，速限 60')).called(1);

      SpeedData state = speedBloc.state as SpeedData;
      expect(state.model.isInterval, false); // 尚未進入，只是接近
      expect(state.model.speedLimit, 60);

      // 3. 到達區間起點
      // 使用者到達 (25.0330, 121.5654)
      final enterTime = startTime.add(const Duration(seconds: 25));
      positionStreamController.add(
        createPosition(lat: 25.0330, lon: 121.5654, time: enterTime),
      );

      await Future.delayed(const Duration(milliseconds: 100));

      // 驗證: 狀態維持
      state = speedBloc.state as SpeedData;
      expect(state.model.isInterval, true);
      // Avg Speed: 333m / 25s = 13.32 m/s = 48 km/h
      expect(state.model.averageSpeed, closeTo(48, 5));

      // 4. 行駛中 - 正常速度 (移動 500m, 花費 35秒 => 51km/h)
      // 0.0045度 lat approx 500m
      final midTime1 = enterTime.add(const Duration(seconds: 35));
      positionStreamController.add(
        createPosition(
          lat: 25.0375,
          lon: 121.5654,
          speedKmh: 60,
          time: midTime1,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 100));

      state = speedBloc.state as SpeedData;
      expect(state.model.isInterval, true);
      // 平均速度應該接近 50
      // 833m / 60s = 13.88 m/s = 50 km/h
      expect(state.model.averageSpeed, closeTo(50, 5));

      // 5. 行駛中 - 加速 (再移動 500m, 為了測試超速提醒，這次只花 15秒 => 120km/h)
      // 總移動 1000m, 總時間 45s. Avg = 1000/45 = 22.2 m/s = 80 km/h.
      final midTime2 = midTime1.add(const Duration(seconds: 15));
      positionStreamController.add(
        createPosition(
          lat: 25.0420, // approx +500m from prev
          lon: 121.5654,
          speedKmh: 120,
          time: midTime2,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 100));

      state = speedBloc.state as SpeedData;
      // 總平均速度: 1333m / 75s = 17.77 m/s = 64 km/h
      expect(state.model.averageSpeed, closeTo(64, 5));
      expect(state.model.isOverSpeed, true);

      // 驗證 TTS 警告
      verify(() => mockTtsService.speak('區間平均速度過高，請減速')).called(1);

      // 6. 離開區間 (到達終點 25.0430)
      // 到達終點
      final exitTime = midTime2.add(const Duration(seconds: 5));
      positionStreamController.add(
        createPosition(lat: 25.0430, lon: 121.5654, time: exitTime),
      );

      await Future.delayed(const Duration(milliseconds: 100));

      state = speedBloc.state as SpeedData;

      // 驗證離開
      verify(() => mockTtsService.speak('離開區間測速')).called(1);

      // Note: For the *current* frame (exit frame), isInterval might still be true because
      // the model is updated BEFORE exit check resets the manager.
      // But the NEXT frame should be false.

      // Let's send one more frame to verify state reset
      positionStreamController.add(
        createPosition(
          lat: 25.0440,
          lon: 121.5654,
          time: exitTime.add(const Duration(seconds: 1)),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 100));
      state = speedBloc.state as SpeedData;
      expect(state.model.isInterval, false); // 切換回一般模式
    });
  });
}
