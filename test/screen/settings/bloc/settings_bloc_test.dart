import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/config/ad_constants.dart';
import 'package:garage/core/repositories/ad_repository.dart';
import 'package:garage/core/repositories/app_info_repository.dart';
import 'package:garage/core/repositories/speed_camera_repository.dart';
import 'package:garage/screen/settings/bloc/settings_bloc.dart';
import 'package:garage/screen/settings/bloc/settings_event.dart';
import 'package:garage/screen/settings/bloc/settings_state.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:mocktail/mocktail.dart';

// Mock Classes
class MockSpeedCameraRepository extends Mock
    implements ISpeedCameraRepository {}

class MockAdRepository extends Mock implements AdRepository {}

class MockInAppReview extends Mock implements InAppReview {}

class MockAppInfoRepository extends Mock implements AppInfoRepository {}

void main() {
  // 註冊 fallback values
  setUpAll(() {
    registerFallbackValue(const Duration(seconds: 1));
  });

  group('SettingsBloc', () {
    late MockSpeedCameraRepository mockSpeedCameraRepository;
    late MockAdRepository mockAdRepository;
    late MockInAppReview mockInAppReview;
    late MockAppInfoRepository mockAppInfoRepository;

    setUp(() {
      mockSpeedCameraRepository = MockSpeedCameraRepository();
      mockAdRepository = MockAdRepository();
      mockInAppReview = MockInAppReview();
      mockAppInfoRepository = MockAppInfoRepository();

      // 設置默認行為
      when(() => mockSpeedCameraRepository.isTracking).thenReturn(false);
      when(() => mockAdRepository.isAdFree).thenReturn(false);
      when(
        () => mockAppInfoRepository.getFullVersionString(),
      ).thenAnswer((_) async => 'Garage v0.0.1');
    });

    SettingsBloc buildBloc() {
      return SettingsBloc(
        speedCameraRepository: mockSpeedCameraRepository,
        adRepository: mockAdRepository,
        inAppReview: mockInAppReview,
        appInfoRepository: mockAppInfoRepository,
      );
    }

    group('初始化', () {
      blocTest<SettingsBloc, SettingsState>(
        '應該在建構時自動載入設定狀態和App版本',
        build: buildBloc,
        expect: () => [
          isA<SettingsState>()
              .having((s) => s.isPro, 'isPro', false)
              .having((s) => s.action, 'action', SettingsAction.none)
              .having((s) => s.appVersion, 'appVersion', 'Garage v0.0.1'),
        ],
      );

      test('初始狀態應該正確', () {
        final bloc = buildBloc();
        expect(bloc.state.isPro, false);
        expect(bloc.state.action, SettingsAction.none);
        expect(bloc.state.errorMessage, null);
        bloc.close();
      });
    });

    group('ClickSpeedSetting - 點擊速度設定', () {
      blocTest<SettingsBloc, SettingsState>(
        '當未追蹤時，應該直接導航到速度設定',
        setUp: () {
          when(() => mockSpeedCameraRepository.isTracking).thenReturn(false);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const ClickSpeedSetting()),
        skip: 1, // 跳過初始化狀態
        expect: () => [
          isA<SettingsState>().having(
            (s) => s.action,
            'action',
            SettingsAction.goToSpeedSetting,
          ),
        ],
      );

      blocTest<SettingsBloc, SettingsState>(
        '當正在追蹤時，應該顯示停止追蹤警示',
        setUp: () {
          when(() => mockSpeedCameraRepository.isTracking).thenReturn(true);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const ClickSpeedSetting()),
        skip: 1,
        expect: () => [
          isA<SettingsState>().having(
            (s) => s.action,
            'action',
            SettingsAction.showStopTrackingAlert,
          ),
        ],
      );
    });

    group('StopTracking - 停止追蹤', () {
      blocTest<SettingsBloc, SettingsState>(
        '應該成功停止追蹤並導航到速度設定',
        setUp: () {
          when(
            () => mockSpeedCameraRepository.stopLocationTracking(),
          ).thenAnswer((_) async => {});
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const StopTracking()),
        skip: 1,
        expect: () => [
          isA<SettingsState>().having(
            (s) => s.action,
            'action',
            SettingsAction.goToSpeedSetting,
          ),
        ],
        verify: (_) {
          verify(
            () => mockSpeedCameraRepository.stopLocationTracking(),
          ).called(1);
        },
      );

      blocTest<SettingsBloc, SettingsState>(
        '停止追蹤失敗時應該顯示錯誤訊息',
        setUp: () {
          when(
            () => mockSpeedCameraRepository.stopLocationTracking(),
          ).thenThrow(Exception('停止追蹤失敗'));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const StopTracking()),
        skip: 1,
        expect: () => [
          isA<SettingsState>().having(
            (s) => s.errorMessage,
            'errorMessage',
            contains('停止追蹤失敗'),
          ),
        ],
      );
    });

    group('WatchAdForTicket - 觀看廣告獲得票券', () {
      blocTest<SettingsBloc, SettingsState>(
        '如果是免廣告用戶，不應該顯示廣告',
        setUp: () {
          when(() => mockAdRepository.isAdFree).thenReturn(true);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const WatchAdForTicket()),
        skip: 1,
        expect: () => [],
        verify: (_) {
          verifyNever(
            () => mockAdRepository.showRewardedAd(
              onReward: any(named: 'onReward'),
            ),
          );
        },
      );

      blocTest<SettingsBloc, SettingsState>(
        '應該顯示獎勵廣告並在完成後給予票券',
        setUp: () {
          when(() => mockAdRepository.isAdFree).thenReturn(false);
          when(
            () => mockAdRepository.showRewardedAd(
              onReward: any(named: 'onReward'),
            ),
          ).thenAnswer((invocation) async {
            final onReward = invocation.namedArguments[#onReward] as Function();
            await onReward();
          });
          when(
            () => mockAdRepository.grantAdTicket(1),
          ).thenAnswer((_) async => {});
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const WatchAdForTicket()),
        skip: 1,
        wait: const Duration(milliseconds: 100),
        verify: (bloc) {
          verify(
            () => mockAdRepository.showRewardedAd(
              onReward: any(named: 'onReward'),
            ),
          ).called(1);
          verify(() => mockAdRepository.grantAdTicket(1)).called(1);
        },
      );
    });

    group('WatchAdForBannerRemoval - 觀看廣告移除橫幅', () {
      blocTest<SettingsBloc, SettingsState>(
        '如果是免廣告用戶，不應該顯示廣告',
        setUp: () {
          when(() => mockAdRepository.isAdFree).thenReturn(true);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const WatchAdForBannerRemoval()),
        skip: 1,
        expect: () => [],
        verify: (_) {
          verifyNever(
            () => mockAdRepository.showRewardedAd(
              onReward: any(named: 'onReward'),
            ),
          );
        },
      );

      blocTest<SettingsBloc, SettingsState>(
        '應該顯示獎勵廣告並在完成後移除橫幅',
        setUp: () {
          when(() => mockAdRepository.isAdFree).thenReturn(false);
          when(
            () => mockAdRepository.showRewardedAd(
              onReward: any(named: 'onReward'),
            ),
          ).thenAnswer((invocation) async {
            final onReward = invocation.namedArguments[#onReward] as Function();
            await onReward();
          });
          when(
            () => mockAdRepository.grantBannerAdFree(any()),
          ).thenAnswer((_) async => {});
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const WatchAdForBannerRemoval()),
        skip: 1,
        wait: const Duration(milliseconds: 100),
        verify: (bloc) {
          verify(
            () => mockAdRepository.showRewardedAd(
              onReward: any(named: 'onReward'),
            ),
          ).called(1);
          verify(
            () => mockAdRepository.grantBannerAdFree(
              AdConstants.bannerAdFreeDuration,
            ),
          ).called(1);
        },
      );
    });

    group('RateApp - 評分應用', () {
      blocTest<SettingsBloc, SettingsState>(
        '應該能夠開啟商店評分頁面',
        setUp: () {
          when(
            () => mockInAppReview.isAvailable(),
          ).thenAnswer((_) async => true);
          when(
            () => mockInAppReview.openStoreListing(),
          ).thenAnswer((_) async => {});
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const RateApp()),
        skip: 1,
        wait: const Duration(milliseconds: 100),
        verify: (bloc) {
          verify(() => mockInAppReview.isAvailable()).called(1);
          verify(() => mockInAppReview.openStoreListing()).called(1);
        },
      );

      blocTest<SettingsBloc, SettingsState>(
        '當評分功能不可用時應該顯示錯誤',
        setUp: () {
          when(
            () => mockInAppReview.isAvailable(),
          ).thenAnswer((_) async => false);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const RateApp()),
        skip: 1,
        wait: const Duration(milliseconds: 100),
        expect: () => [
          isA<SettingsState>().having(
            (s) => s.errorMessage,
            'errorMessage',
            contains('無法開啟應用程式商店'),
          ),
        ],
      );

      blocTest<SettingsBloc, SettingsState>(
        '評分時發生錯誤應該顯示錯誤訊息',
        setUp: () {
          when(
            () => mockInAppReview.isAvailable(),
          ).thenThrow(Exception('評分失敗'));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const RateApp()),
        skip: 1,
        wait: const Duration(milliseconds: 100),
        expect: () => [
          isA<SettingsState>().having(
            (s) => s.errorMessage,
            'errorMessage',
            contains('發生錯誤'),
          ),
        ],
      );
    });

    group('ResetSettingsAction - 重置動作', () {
      blocTest<SettingsBloc, SettingsState>(
        '應該將 action 重置為 none',
        build: buildBloc,
        seed: () => const SettingsState(
          action: SettingsAction.goToSpeedSetting,
          appVersion: 'Garage v0.0.1',
        ),
        act: (bloc) => bloc.add(const ResetSettingsAction()),
        expect: () => [
          // LoadSettingsStatus 的結果和 seed 相同，Bloc 不會 emit 重複的狀態
          // 只有 ResetSettingsAction 會產生新的 emit
          isA<SettingsState>()
              .having((s) => s.action, 'action', SettingsAction.none)
              .having((s) => s.appVersion, 'appVersion', 'Garage v0.0.1'),
        ],
      );
    });
  });
}
