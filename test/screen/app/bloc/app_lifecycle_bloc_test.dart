import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/repositories/app_open_ad_repository.dart';
import 'package:garage/screen/app/bloc/app_lifecycle_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockAppOpenAdRepository extends Mock implements AppOpenAdRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppLifecycleBloc', () {
    late MockAppOpenAdRepository mockAppOpenAdRepository;

    setUp(() {
      mockAppOpenAdRepository = MockAppOpenAdRepository();
    });

    test('initial state is AppLifecycleInitial', () {
      final bloc = AppLifecycleBloc(
        appOpenAdRepository: mockAppOpenAdRepository,
      );
      expect(bloc.state, isA<AppLifecycleInitial>());
      bloc.close();
    });

    test('should show ad when app is resumed', () {
      final bloc = AppLifecycleBloc(
        appOpenAdRepository: mockAppOpenAdRepository,
      );

      // Simulate App Resumed notification from OS
      bloc.didChangeAppLifecycleState(ui.AppLifecycleState.resumed);

      verify(() => mockAppOpenAdRepository.showAdIfAvailable()).called(1);

      bloc.close();
    });

    test('should NOT show ad when app is paused', () {
      final bloc = AppLifecycleBloc(
        appOpenAdRepository: mockAppOpenAdRepository,
      );

      // Simulate App Paused notification
      bloc.didChangeAppLifecycleState(ui.AppLifecycleState.paused);

      verifyNever(() => mockAppOpenAdRepository.showAdIfAvailable());

      bloc.close();
    });
  });
}
