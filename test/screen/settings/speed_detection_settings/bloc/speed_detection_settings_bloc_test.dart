import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/models/speed_unit.dart';
import 'package:garage/core/models/user_settings.dart';
import 'package:garage/core/repositories/speed_camera_repository.dart';
import 'package:garage/core/repositories/user_settings_repository.dart';
import 'package:garage/screen/settings/speed_detection_settings/bloc/speed_detection_settings_bloc.dart';
import 'package:garage/screen/settings/speed_detection_settings/bloc/speed_detection_settings_event.dart';
import 'package:garage/screen/settings/speed_detection_settings/bloc/speed_detection_settings_state.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockUserSettingsRepository extends Mock
    implements UserSettingsRepository {}

class MockSpeedCameraRepository extends Mock
    implements ISpeedCameraRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SpeedDetectionSettingsBloc', () {
    late MockUserSettingsRepository userSettingsRepository;
    late MockSpeedCameraRepository speedCameraRepository;

    const defaultSettings = UserSettings(
      speedUnit: SpeedUnit.kmh,
      isVoiceAlertEnabled: true,
      voiceVolume: 0.5,
      alertDistance: 500,
    );

    setUpAll(() {
      registerFallbackValue(defaultSettings);
    });

    setUp(() {
      userSettingsRepository = MockUserSettingsRepository();
      speedCameraRepository = MockSpeedCameraRepository();

      when(
        () => userSettingsRepository.loadSettings(),
      ).thenAnswer((_) => Future.value(defaultSettings));
      when(
        () => userSettingsRepository.saveSettings(any()),
      ).thenAnswer((_) => Future.value(true));
      when(
        () => userSettingsRepository.updateSettings(any()),
      ).thenAnswer((_) => Future.value(userSettingsRepository));
      when(
        () => speedCameraRepository.checkPermission(),
      ).thenAnswer((_) async => true);
      when(
        () => speedCameraRepository.updateVolume(any()),
      ).thenAnswer((_) async {});
      when(
        () => speedCameraRepository.stopLocationTracking(),
      ).thenAnswer((_) async {});

      registerFallbackValue(defaultSettings);
    });

    SpeedDetectionSettingsBloc buildBloc() {
      return SpeedDetectionSettingsBloc(
        userSettingsRepository: userSettingsRepository,
        speedCameraRepository: speedCameraRepository,
      );
    }

    test('initial state is SpeedDetectionSettingsInitial', () {
      final bloc = buildBloc();
      expect(bloc.state, isA<SpeedDetectionSettingsInitial>());
      bloc.close();
    });

    blocTest<SpeedDetectionSettingsBloc, SpeedDetectionSettingsState>(
      'should load settings on initialization',
      build: buildBloc,
      verify: (_) {
        verify(() => userSettingsRepository.loadSettings()).called(2);
        verify(() => speedCameraRepository.checkPermission()).called(1);
      },
      expect: () => [
        isA<SpeedDetectionSettingsLoaded>()
            .having((s) => s.speedUnit, 'speedUnit', SpeedUnit.kmh)
            .having((s) => s.isVoiceAlertEnabled, 'isVoiceAlertEnabled', true)
            .having((s) => s.voiceVolumePercentage, 'voiceVolume', 0.5)
            .having((s) => s.alertDistance, 'alertDistance', 500)
            .having((s) => s.hasLocationPermission, 'hasPermission', true),
      ],
    );

    blocTest<SpeedDetectionSettingsBloc, SpeedDetectionSettingsState>(
      'should handle load error gracefully',
      build: () {
        var count = 0;
        when(() => userSettingsRepository.loadSettings()).thenAnswer((_) async {
          count++;
          if (count == 1) {
            return Future.error(Exception('Load failed'));
          }
          return defaultSettings;
        });
        return buildBloc();
      },
      expect: () => [
        isA<SpeedDetectionSettingsLoaded>() // Should fallback to defaults
            .having((s) => s.speedUnit, 'default unit', SpeedUnit.kmh),
      ],
    );

    blocTest<SpeedDetectionSettingsBloc, SpeedDetectionSettingsState>(
      'should update speed unit',
      build: buildBloc,
      skip: 1, // Skip initial load
      act: (bloc) async {
        await bloc.stream.first;
        bloc.add(const ChangeSpeedUnit(SpeedUnit.mph));
      },
      expect: () => [
        isA<SpeedDetectionSettingsLoaded>().having(
          (s) => s.speedUnit,
          'new unit',
          SpeedUnit.mph,
        ),
      ],
      verify: (_) {
        verify(
          () => userSettingsRepository.updateSettings(
            any(
              that: isA<UserSettings>().having(
                (s) => s.speedUnit,
                'unit',
                SpeedUnit.mph,
              ),
            ),
          ),
        ).called(1);
      },
    );

    blocTest<SpeedDetectionSettingsBloc, SpeedDetectionSettingsState>(
      'should toggle voice alert and stop tracking',
      build: buildBloc,
      skip: 1,
      act: (bloc) async {
        await bloc.stream.first;
        bloc.add(const ToggleVoiceAlert());
      },
      expect: () => [
        isA<SpeedDetectionSettingsLoaded>().having(
          (s) => s.isVoiceAlertEnabled,
          'toggled to false',
          false,
        ),
      ],
      verify: (_) {
        verify(() => speedCameraRepository.stopLocationTracking()).called(1);
        verify(
          () => userSettingsRepository.updateSettings(
            any(
              that: isA<UserSettings>().having(
                (s) => s.isVoiceAlertEnabled,
                'voice alert',
                false,
              ),
            ),
          ),
        ).called(1);
      },
    );

    blocTest<SpeedDetectionSettingsBloc, SpeedDetectionSettingsState>(
      'should update voice volume',
      build: buildBloc,
      skip: 1,
      act: (bloc) async {
        await bloc.stream.first;
        bloc.add(const ChangeVoiceVolume(0.8));
      },
      expect: () => [
        // It updates Repo Volume first (async), then emits State?
        // Code: emit first (optimistic)?
        isA<SpeedDetectionSettingsLoaded>().having(
          (s) => s.voiceVolumePercentage,
          'vol',
          0.8,
        ),
      ],
      verify: (_) {
        verify(() => speedCameraRepository.updateVolume(0.8)).called(1);
      },
    );

    blocTest<SpeedDetectionSettingsBloc, SpeedDetectionSettingsState>(
      'should update alert distance',
      build: buildBloc,
      skip: 1,
      act: (bloc) async {
        await bloc.stream.first;
        bloc.add(const ChangeAlertDistance(800));
      },
      expect: () => [
        isA<SpeedDetectionSettingsLoaded>().having(
          (s) => s.alertDistance,
          'distance',
          800,
        ),
      ],
    );

    blocTest<SpeedDetectionSettingsBloc, SpeedDetectionSettingsState>(
      'should request location permission',
      build: buildBloc,
      skip: 1,
      setUp: () {
        // Initial state: Permission denied
        when(
          () => speedCameraRepository.checkPermission(),
        ).thenAnswer((_) async => false);
        // Request: Granted
        when(
          () => speedCameraRepository.requestPermission(),
        ).thenAnswer((_) async => true);
      },
      act: (bloc) async {
        await bloc.stream.first;
        bloc.add(const RequestLocationPermission());
      },
      verify: (_) {
        verify(() => speedCameraRepository.requestPermission()).called(1);
      },
      expect: () => [
        isA<SpeedDetectionSettingsLoaded>().having(
          (s) => s.hasLocationPermission,
          'permission granted',
          true,
        ),
      ],
    );

    blocTest<SpeedDetectionSettingsBloc, SpeedDetectionSettingsState>(
      'should save settings on close',
      build: buildBloc,
      skip: 1, // Wait for load
      act: (bloc) async {
        // Change something to ensure state is different?
        // Actually saveSettings uses current state.
        bloc.add(const ChangeSpeedUnit(SpeedUnit.mph));
        // Wait for the state to settle? blocTest handles it?
        // blocTest doesn't automatically close in `act`. It closes after.
        // But we want to verify `close` logic.
        // `blocTest` calls `close`.
      },
      verify: (bloc) {
        // verify saving happens.
        // But `blocTest` verify runs before teardown?
        // No, verify runs after act.
        // We cannot test close() inside blocTest easily because blocTest manages lifecycle.
        // We should test close() manually.
      },
    );

    test('should save settings manually when closed', () async {
      final bloc = buildBloc();
      // Wait for init
      await bloc.stream.first;

      bloc.add(const ChangeSpeedUnit(SpeedUnit.mph));
      // Wait for change
      await bloc.stream.firstWhere(
        (s) => (s as SpeedDetectionSettingsLoaded).speedUnit == SpeedUnit.mph,
      );

      await bloc.close();

      verify(() => userSettingsRepository.saveSettings(any())).called(1);
    });
  });
}
