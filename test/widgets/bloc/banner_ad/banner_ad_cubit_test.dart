import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:garage/core/repositories/ad_repository.dart';
import 'package:garage/widgets/bloc/banner_ad/banner_ad_cubit.dart';
import 'package:garage/widgets/bloc/banner_ad/banner_ad_state.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockAdRepository extends Mock implements AdRepository {}

class MockBannerAd extends Mock implements BannerAd {}

class MockAdRequest extends Mock implements AdRequest {}

class MockLoadAdError extends Mock implements LoadAdError {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BannerAdCubit', () {
    late MockAdRepository adRepository;
    late MockBannerAd bannerAd;

    setUp(() {
      adRepository = MockAdRepository();
      bannerAd = MockBannerAd();

      // Default behaviors
      when(() => adRepository.isBannerAdFree).thenReturn(false);
      when(() => adRepository.bannerAdUnitId).thenReturn('test_ad_unit_id');
      when(() => bannerAd.load()).thenAnswer((_) async {});
      when(() => bannerAd.dispose()).thenAnswer((_) async {});
    });

    BannerAdCubit buildCubit() {
      return BannerAdCubit(
        adRepository: adRepository,
        bannerAdFactory:
            ({
              required adUnitId,
              required size,
              required request,
              required listener,
            }) {
              // Store listener behavior if needed, or invoke it manually in tests via capturing?
              // To trigger listener callbacks, we need to capture the listener.
              // Since we can't easily capture via argument matcher in factory call within the cubit...
              // We can attach the listener to the mock or expose a way to trigger it.
              // Or we can manipulate the mock to call the listener?
              // BannerAd doesn't expose listener setter publicly usually?
              // Wait, BannerAd constructor takes listener.
              // The factory is creating the mock.
              // We can't attach the listener to the mock easily unless we create a fake or special mock.

              // Better approach: Captured listener.
              // We can use a side-effect in the factory to expose the listener.
              return bannerAd; // Return the mock
            },
      );
    }

    // Helper to capture listener
    BannerAdListener? capturedListener;

    BannerAdCubit buildCubitWithListenerCapture() {
      return BannerAdCubit(
        adRepository: adRepository,
        bannerAdFactory:
            ({
              required adUnitId,
              required size,
              required request,
              required listener,
            }) {
              capturedListener = listener;
              return bannerAd;
            },
      );
    }

    test('initial state is BannerAdInitial', () {
      expect(buildCubit().state, const BannerAdInitial());
    });

    blocTest<BannerAdCubit, BannerAdState>(
      'should emit BannerAdHidden if ad is free',
      build: () {
        when(() => adRepository.isBannerAdFree).thenReturn(true);
        return buildCubit();
      },
      act: (cubit) => cubit.loadAd(),
      expect: () => [const BannerAdHidden()],
    );

    blocTest<BannerAdCubit, BannerAdState>(
      'should emit BannerAdLoading and define ad when loading',
      build: buildCubit,
      act: (cubit) => cubit.loadAd(),
      verify: (_) {
        verify(() => bannerAd.load()).called(1);
      },
      expect: () => [const BannerAdLoading()],
    );

    test('should emit BannerAdLoaded when ad loads successfully', () async {
      final cubit = buildCubitWithListenerCapture();

      cubit.loadAd();

      await Future.delayed(Duration.zero); // Process loading emission

      // Initial expectations (Loading)
      expect(cubit.state, const BannerAdLoading());

      // Simulate Success
      capturedListener?.onAdLoaded?.call(bannerAd);

      expect(cubit.state, isA<BannerAdLoaded>());
      expect((cubit.state as BannerAdLoaded).ad, bannerAd);

      cubit.close();
    });

    test('should emit BannerAdLoadError when ad fails to load', () async {
      final cubit = buildCubitWithListenerCapture();
      final error = MockLoadAdError();
      when(() => error.message).thenReturn('Failed');

      cubit.loadAd();
      await Future.delayed(Duration.zero);

      // Simulate Failure
      capturedListener?.onAdFailedToLoad?.call(bannerAd, error);

      verify(() => bannerAd.dispose()).called(1); // Should dispose failed ad
      expect(cubit.state, isA<BannerAdLoadError>());
      expect((cubit.state as BannerAdLoadError).message, 'Failed');

      cubit.close();
    });

    test('should dispose ad when cubit is closed if loaded', () async {
      final cubit = buildCubitWithListenerCapture();
      cubit.loadAd();
      capturedListener?.onAdLoaded?.call(bannerAd);

      // Reset dispose verification (from listener success if any? No)
      clearInteractions(bannerAd);

      await cubit.close();

      verify(() => bannerAd.dispose()).called(1);
    });
  });
}
