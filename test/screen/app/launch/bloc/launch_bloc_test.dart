import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/screen/app/launch/bloc/launch_bloc.dart';
import 'package:garage/screen/app/launch/bloc/launch_state.dart';
import 'package:mocktail/mocktail.dart';

// Mock Classes
class MockTickerProvider extends Mock implements TickerProvider {}

class MockLaunchAnimationHolder extends Mock implements LaunchAnimationHolder {
  final Completer<void> _completer = Completer<void>();

  @override
  Future<void> get animationCompleted => _completer.future;

  void completeAnimation() {
    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }

  void failAnimation(Object error) {
    if (!_completer.isCompleted) {
      _completer.completeError(error);
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LaunchBloc', () {
    late MockTickerProvider mockTickerProvider;
    late MockLaunchAnimationHolder mockAnimationHolder;

    setUp(() {
      mockTickerProvider = MockTickerProvider();
      mockAnimationHolder = MockLaunchAnimationHolder();

      // Mock dispose method
      when(() => mockAnimationHolder.dispose()).thenAnswer((_) {});
    });

    LaunchBloc buildBloc() {
      return LaunchBloc(
        vsync: mockTickerProvider,
        animationHolder: mockAnimationHolder,
      );
    }

    group('初始化', () {
      test('初始狀態應該是 LaunchInitializing', () {
        final bloc = buildBloc();
        expect(bloc.state, isA<LaunchInitializing>());
        bloc.close();
      });

      blocTest<LaunchBloc, LaunchState>(
        '應該在建構時自動發送 StartInitialization 事件並完成動畫',
        build: buildBloc,
        act: (bloc) {
          // 模擬動畫完成
          mockAnimationHolder.completeAnimation();
        },
        wait: const Duration(milliseconds: 100),
        expect: () => [
          isA<LaunchCompleted>(),
        ],
      );
    });

    group('StartInitialization - 初始化事件', () {
      blocTest<LaunchBloc, LaunchState>(
        '應該等待動畫完成後 emit LaunchCompleted',
        build: buildBloc,
        act: (bloc) {
          // 模擬動畫完成
          mockAnimationHolder.completeAnimation();
        },
        wait: const Duration(milliseconds: 100),
        expect: () => [
          isA<LaunchCompleted>(),
        ],
      );
    });

    group('dispose', () {
      test('應該釋放 animationHolder', () async {
        final bloc = buildBloc();
        mockAnimationHolder.completeAnimation();
        await bloc.close();

        verify(() => mockAnimationHolder.dispose()).called(1);
      });
    });
  });

  group('LaunchAnimationHolder', () {
    testWidgets('應該正確創建動畫控制器和動畫值', (WidgetTester tester) async {
      late LaunchAnimationHolder holder;

      await tester.pumpWidget(
        MaterialApp(
          home: const _TestWidget(),
        ),
      );

      // 從 state 獲取 TickerProvider
      final state = tester.state<_TestWidgetState>(
        find.byType(_TestWidget),
      );
      holder = LaunchAnimationHolder(state);

      // 驗證控制器已創建
      expect(holder.mainController, isNotNull);
      expect(holder.speedLinesController, isNotNull);

      // 驗證動畫值已設置
      expect(holder.gridOpacity, isNotNull);
      expect(holder.logoOpacity, isNotNull);
      expect(holder.carOpacity, isNotNull);
      expect(holder.speedLinesOpacity, isNotNull);
      expect(holder.taglineOpacity, isNotNull);

      holder.dispose();
    });

    testWidgets('主控制器完成後應該通知 completer', (WidgetTester tester) async {
      late LaunchAnimationHolder holder;
      bool animationCompleted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: const _TestWidget(),
        ),
      );

      // 從 state 獲取 TickerProvider
      final state = tester.state<_TestWidgetState>(
        find.byType(_TestWidget),
      );
      holder = LaunchAnimationHolder(state);

      // 監聽動畫完成
      holder.animationCompleted.then((_) {
        animationCompleted = true;
      });

      // 手動完成主控制器
      holder.mainController.value = 1.0;
      await tester.pump();

      // 檢查動畫完成標誌
      expect(animationCompleted, true);

      holder.dispose();
    });
  });
}

// 測試輔助 Widget
class _TestWidget extends StatefulWidget {
  const _TestWidget();

  @override
  State<_TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<_TestWidget>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
