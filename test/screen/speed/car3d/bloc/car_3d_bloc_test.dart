import 'dart:convert';
import 'dart:typed_data';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/screen/speed/car3d/bloc/car_3d_bloc.dart';
import 'package:garage/screen/speed/car3d/bloc/car_3d_event.dart';
import 'package:garage/screen/speed/car3d/bloc/car_3d_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Car3DBloc', () {
    // 創建測試用的模型數據
    final testModelBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
    final testModelBase64 = base64Encode(testModelBytes);
    final testModelDataUri = 'data:model/gltf-binary;base64,$testModelBase64';

    void setupMockAssetBundle() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (ByteData? message) async {
            if (message == null) return null;
            final String key = utf8.decode(
              message.buffer.asUint8List(
                message.offsetInBytes,
                message.lengthInBytes,
              ),
            );
            if (key == 'assets/models/car.glb') {
              return testModelBytes.buffer.asByteData();
            }
            return null;
          });
    }

    void setupFailingAssetBundle() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (ByteData? message) async {
            return null;
          });
    }

    setUp(() {
      setupMockAssetBundle();
    });

    tearDown(() {
      // 清除 mock
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', null);
    });

    group('初始化', () {
      test('初始狀態應該是 Car3DLoading', () {
        final bloc = Car3DBloc();
        expect(bloc.state, isA<Car3DLoading>());
        bloc.close();
      });
    });

    group('LoadCar3DModel - 加載 3D 模型', () {
      blocTest<Car3DBloc, Car3DState>(
        '應該成功加載模型並轉換為 data URI',
        build: () => Car3DBloc(),
        act: (bloc) => bloc.add(const LoadCar3DModel()),
        expect: () => [
          isA<Car3DLoading>(),
          isA<Car3DReady>().having(
            (state) => state.modelSrc,
            'modelSrc',
            testModelDataUri,
          ),
        ],
      );

      blocTest<Car3DBloc, Car3DState>(
        '加載模型失敗時應該 emit Car3DLoadError',
        setUp: () {
          setupFailingAssetBundle();
        },
        build: () => Car3DBloc(),
        act: (bloc) => bloc.add(const LoadCar3DModel()),
        expect: () => [
          isA<Car3DLoading>(),
          isA<Car3DLoadError>().having(
            (state) => state.error,
            'error',
            contains('Failed to load model'),
          ),
        ],
      );
    });

    group('StartCar3DAnimation - 開始動畫', () {
      blocTest<Car3DBloc, Car3DState>(
        '當模型已準備好時應該開始動畫',
        build: () => Car3DBloc(),
        act: (bloc) async {
          bloc.add(const LoadCar3DModel());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(const StartCar3DAnimation());
        },
        skip: 2, // Skip loading states
        expect: () => [
          isA<Car3DAnimating>().having(
            (state) => state.modelSrc,
            'modelSrc',
            testModelDataUri,
          ),
        ],
      );

      blocTest<Car3DBloc, Car3DState>(
        '當已經在動畫中時不應該有變化',
        build: () => Car3DBloc(),
        seed: () => Car3DAnimating(testModelDataUri),
        act: (bloc) => bloc.add(const StartCar3DAnimation()),
        expect: () => [], // No state change
      );

      blocTest<Car3DBloc, Car3DState>(
        '當模型未加載時不應該開始動畫',
        build: () => Car3DBloc(),
        seed: () => const Car3DLoading(),
        act: (bloc) => bloc.add(const StartCar3DAnimation()),
        expect: () => [], // No state change
      );

      blocTest<Car3DBloc, Car3DState>(
        '當加載失敗時不應該開始動畫',
        build: () => Car3DBloc(),
        seed: () => const Car3DLoadError('Error'),
        act: (bloc) => bloc.add(const StartCar3DAnimation()),
        expect: () => [], // No state change
      );
    });

    group('StopCar3DAnimation - 停止動畫', () {
      blocTest<Car3DBloc, Car3DState>(
        '當在動畫中時應該停止動畫',
        build: () => Car3DBloc(),
        seed: () => Car3DAnimating(testModelDataUri),
        act: (bloc) => bloc.add(const StopCar3DAnimation()),
        expect: () => [
          isA<Car3DReady>().having(
            (state) => state.modelSrc,
            'modelSrc',
            testModelDataUri,
          ),
        ],
      );

      blocTest<Car3DBloc, Car3DState>(
        '當動畫已停止時不應該有變化',
        build: () => Car3DBloc(),
        seed: () => Car3DReady(testModelDataUri),
        act: (bloc) => bloc.add(const StopCar3DAnimation()),
        expect: () => [], // No state change
      );

      blocTest<Car3DBloc, Car3DState>(
        '當模型未加載時不應該有變化',
        build: () => Car3DBloc(),
        seed: () => const Car3DLoading(),
        act: (bloc) => bloc.add(const StopCar3DAnimation()),
        expect: () => [], // No state change
      );

      blocTest<Car3DBloc, Car3DState>(
        '當加載失敗時不應該有變化',
        build: () => Car3DBloc(),
        seed: () => const Car3DLoadError('Error'),
        act: (bloc) => bloc.add(const StopCar3DAnimation()),
        expect: () => [], // No state change
      );
    });

    group('狀態轉換', () {
      blocTest<Car3DBloc, Car3DState>(
        '完整的生命週期：加載 -> 開始動畫 -> 停止動畫',
        build: () => Car3DBloc(),
        act: (bloc) async {
          bloc.add(const LoadCar3DModel());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(const StartCar3DAnimation());
          await Future.delayed(const Duration(milliseconds: 50));
          bloc.add(const StopCar3DAnimation());
        },
        expect: () => [
          isA<Car3DLoading>(),
          isA<Car3DReady>(),
          isA<Car3DAnimating>(),
          isA<Car3DReady>(),
        ],
      );

      blocTest<Car3DBloc, Car3DState>(
        '可以多次開始和停止動畫',
        build: () => Car3DBloc(),
        seed: () => Car3DReady(testModelDataUri),
        act: (bloc) async {
          bloc.add(const StartCar3DAnimation());
          await Future.delayed(const Duration(milliseconds: 50));
          bloc.add(const StopCar3DAnimation());
          await Future.delayed(const Duration(milliseconds: 50));
          bloc.add(const StartCar3DAnimation());
          await Future.delayed(const Duration(milliseconds: 50));
          bloc.add(const StopCar3DAnimation());
        },
        expect: () => [
          isA<Car3DAnimating>(),
          isA<Car3DReady>(),
          isA<Car3DAnimating>(),
          isA<Car3DReady>(),
        ],
      );
    });
  });
}
