import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/models/tabbar_type.dart';
import 'package:garage/screen/app/home/bloc/garage_home_bloc.dart';
import 'package:garage/screen/app/home/bloc/garage_home_event.dart';
import 'package:garage/screen/app/home/bloc/garage_home_state.dart';

void main() {
  group('GarageHomeBloc', () {
    late GarageHomeBloc bloc;

    setUp(() {
      bloc = GarageHomeBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('初始狀態應該是 SpeedCameraTab', () {
      expect(bloc.state, isA<GarageHomeInitialState>());
      expect(bloc.state.tabbarType, const SpeedCameraTab());
    });

    blocTest<GarageHomeBloc, GarageHomeState>(
      '切換到 Records tab 應該更新狀態',
      build: () => bloc,
      act: (bloc) => bloc.add(const TabChanged(RecordsTab())),
      expect: () => [
        isA<GarageHomeTabChanged>()
            .having((s) => s.tabbarType, 'tabbarType', const RecordsTab()),
      ],
    );

    blocTest<GarageHomeBloc, GarageHomeState>(
      '切換到 Settings tab 應該更新狀態',
      build: () => bloc,
      act: (bloc) => bloc.add(const TabChanged(SettingsTab())),
      expect: () => [
        isA<GarageHomeTabChanged>()
            .having((s) => s.tabbarType, 'tabbarType', const SettingsTab()),
      ],
    );

    blocTest<GarageHomeBloc, GarageHomeState>(
      '應該能夠連續切換多個 tabs',
      build: () => bloc,
      act: (bloc) {
        bloc.add(const TabChanged(RecordsTab()));
        bloc.add(const TabChanged(SettingsTab()));
        bloc.add(const TabChanged(SpeedCameraTab()));
      },
      expect: () => [
        isA<GarageHomeTabChanged>()
            .having((s) => s.tabbarType, 'tabbarType', const RecordsTab()),
        isA<GarageHomeTabChanged>()
            .having((s) => s.tabbarType, 'tabbarType', const SettingsTab()),
        isA<GarageHomeTabChanged>()
            .having((s) => s.tabbarType, 'tabbarType', const SpeedCameraTab()),
      ],
    );

    blocTest<GarageHomeBloc, GarageHomeState>(
      '切換到相同的 tab 應該被 Equatable 過濾（只發出一次）',
      build: () => bloc,
      act: (bloc) {
        bloc.add(const TabChanged(SpeedCameraTab()));
        bloc.add(const TabChanged(SpeedCameraTab()));
      },
      expect: () => [
        // Equatable 會過濾掉相同的狀態,所以只會發出一次
        isA<GarageHomeTabChanged>()
            .having((s) => s.tabbarType, 'tabbarType', const SpeedCameraTab()),
      ],
    );

    group('狀態保持', () {
      test('TabChanged 事件應該產生新的狀態對象', () {
        bloc.add(const TabChanged(RecordsTab()));
        final firstState = bloc.stream.first;

        bloc.add(const TabChanged(SettingsTab()));
        final secondState = bloc.stream.first;

        expect(firstState, isNot(equals(secondState)));
      });
    });
  });
}
