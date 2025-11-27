import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'car_3d_event.dart';
import 'car_3d_state.dart';

class Car3DBloc extends Bloc<Car3DEvent, Car3DState> {
  Car3DBloc() : super(const Car3DLoading()) {
    on<Car3DEvent>(_onEvent);
  }

  Future<void> _onEvent(
    Car3DEvent event,
    Emitter<Car3DState> emit,
  ) async {
    switch (event) {
      case LoadCar3DModel():
        await _onLoadModel(emit);
      case StartCar3DAnimation():
        _onStartAnimation(emit);
      case StopCar3DAnimation():
        _onStopAnimation(emit);
    }
  }

  Future<void> _onLoadModel(Emitter<Car3DState> emit) async {
    emit(const Car3DLoading());
    try {
      // 加載 3D 模型
      final data = await rootBundle.load('assets/models/car.glb');
      final bytes = data.buffer.asUint8List();

      // 轉換為 base64
      final base64String = base64Encode(bytes);
      final dataUri = 'data:model/gltf-binary;base64,$base64String';

      emit(Car3DReady(dataUri));
    } catch (e) {
      emit(Car3DLoadError('Failed to load model: $e'));
    }
  }

  void _onStartAnimation(Emitter<Car3DState> emit) {
    switch (state) {
      case Car3DReady(:final modelSrc):
        emit(Car3DAnimating(modelSrc));
      case Car3DAnimating():
        // 已經在動畫中，不做任何事
        return;
      case Car3DLoading():
      case Car3DLoadError():
        // 模型未加載，無法開始動畫
        return;
    }
  }

  void _onStopAnimation(Emitter<Car3DState> emit) {
    switch (state) {
      case Car3DAnimating(:final modelSrc):
        emit(Car3DReady(modelSrc));
      case Car3DReady():
      case Car3DLoading():
      case Car3DLoadError():
        // 不在動畫中，無需停止
        return;
    }
  }
}
