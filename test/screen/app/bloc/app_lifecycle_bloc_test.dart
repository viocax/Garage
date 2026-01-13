import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/repositories/app_open_ad_repository.dart';
import 'package:garage/screen/app/bloc/app_lifecycle_bloc.dart';
import 'package:mocktail/mocktail.dart';

// Mock Classes
class MockAppOpenAdRepository extends Mock implements AppOpenAdRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppLifecycleBloc', () {
    late MockAppOpenAdRepository mockAppOpenAdRepository;

    setUp(() {
      mockAppOpenAdRepository = MockAppOpenAdRepository();

      // Mock showAdIfAvailable 方法
      when(() => mockAppOpenAdRepository.showAdIfAvailable())
          .thenAnswer((_) async {});
    });

    AppLifecycleBloc buildBloc() {
      return AppLifecycleBloc(
        appOpenAdRepository: mockAppOpenAdRepository,
      );
    }

    group('初始化', () {
      test('初始狀態應該是 AppLifecycleInitial', () {
        final bloc = buildBloc();
        expect(bloc.state, isA<AppLifecycleInitial>());
        bloc.close();
      });

      testWidgets('應該註冊生命週期觀察者', (WidgetTester tester) async {
        final bloc = buildBloc();

        // 驗證觀察者已註冊（通過觸發生命週期事件來間接驗證）
        final binding = TestWidgetsFlutterBinding.instance;

        // 觸發 resumed 事件
        binding.handleAppLifecycleStateChanged(ui.AppLifecycleState.resumed);
        await tester.pump();

        // 驗證 showAdIfAvailable 被調用
        verify(() => mockAppOpenAdRepository.showAdIfAvailable()).called(1);

        await bloc.close();
      });
    });

    group('生命週期事件處理', () {
      test('resumed 時應該顯示廣告', () {
        final bloc = buildBloc();

        // 模擬 App Resumed 通知
        bloc.didChangeAppLifecycleState(ui.AppLifecycleState.resumed);

        // 驗證 showAdIfAvailable 被調用
        verify(() => mockAppOpenAdRepository.showAdIfAvailable()).called(1);

        bloc.close();
      });

      test('paused 時不應該有副作用', () {
        final bloc = buildBloc();

        // 模擬 App Paused 通知
        bloc.didChangeAppLifecycleState(ui.AppLifecycleState.paused);

        // 驗證沒有調用 showAdIfAvailable
        verifyNever(() => mockAppOpenAdRepository.showAdIfAvailable());

        bloc.close();
      });

      test('inactive 時不應該有副作用', () {
        final bloc = buildBloc();

        // 模擬 App Inactive 通知
        bloc.didChangeAppLifecycleState(ui.AppLifecycleState.inactive);

        // 驗證沒有調用 showAdIfAvailable
        verifyNever(() => mockAppOpenAdRepository.showAdIfAvailable());

        bloc.close();
      });

      test('detached 時不應該有副作用', () {
        final bloc = buildBloc();

        // 模擬 App Detached 通知
        bloc.didChangeAppLifecycleState(ui.AppLifecycleState.detached);

        // 驗證沒有調用 showAdIfAvailable
        verifyNever(() => mockAppOpenAdRepository.showAdIfAvailable());

        bloc.close();
      });

      test('hidden 時不應該有副作用', () {
        final bloc = buildBloc();

        // 模擬 App Hidden 通知
        bloc.didChangeAppLifecycleState(ui.AppLifecycleState.hidden);

        // 驗證沒有調用 showAdIfAvailable
        verifyNever(() => mockAppOpenAdRepository.showAdIfAvailable());

        bloc.close();
      });

      test('多次 resumed 應該多次顯示廣告', () {
        final bloc = buildBloc();

        // 觸發多次 resumed 事件
        bloc.didChangeAppLifecycleState(ui.AppLifecycleState.resumed);
        bloc.didChangeAppLifecycleState(ui.AppLifecycleState.paused);
        bloc.didChangeAppLifecycleState(ui.AppLifecycleState.resumed);

        // 驗證 showAdIfAvailable 被調用 2 次
        verify(() => mockAppOpenAdRepository.showAdIfAvailable()).called(2);

        bloc.close();
      });
    });

    group('dispose', () {
      testWidgets('應該移除生命週期觀察者', (WidgetTester tester) async {
        final bloc = buildBloc();
        final binding = TestWidgetsFlutterBinding.instance;

        // 關閉 bloc
        await bloc.close();

        // 重置 mock
        reset(mockAppOpenAdRepository);
        when(() => mockAppOpenAdRepository.showAdIfAvailable())
            .thenAnswer((_) async {});

        // 觸發 resumed 事件（bloc 已關閉，不應該響應）
        binding.handleAppLifecycleStateChanged(ui.AppLifecycleState.resumed);
        await tester.pump();

        // 驗證 showAdIfAvailable 沒有被調用
        verifyNever(() => mockAppOpenAdRepository.showAdIfAvailable());
      });
    });
  });
}

