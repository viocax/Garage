import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/core/core.dart';
import 'package:garage/core/models/speed_unit.dart';
import 'package:garage/core/repositories/user_settings_repository.dart';
import 'speed_event.dart';
import 'speed_state.dart';

class SpeedBloc extends Bloc<SpeedEvent, SpeedState> {
  final ISpeedCameraRepository repository = getIt.repo.speedCamera;
  final UserSettingsRepository userSettingsRepository = getIt.repo.userSettings;

  SpeedBloc()
    : super(
        const SpeedData(
          speed: 0.0,
          animationDuration: Duration(milliseconds: 5300),
          unit: SpeedUnit.kmh,
        ),
      ) {
    on<UpdateSpeed>(_onUpdateSpeed);
    on<StartDetection>(_onStartDetection);
    on<StopDetection>(_onStopDetection);
    on<SpeedLoading>(_onSpeedLoading);

    // 初次載入設定
    add(const SpeedLoading());
  }

  Future<void> _onSpeedLoading(
    SpeedLoading event,
    Emitter<SpeedState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SpeedData) return;
    try {
      final settings = await userSettingsRepository.loadSettings();
      emit(currentState.copyWith(
        unit: settings.speedUnit,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        unit: SpeedUnit.kmh,
      ));
    }
  }

  Future<void> _onUpdateSpeed(
    UpdateSpeed event,
    Emitter<SpeedState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SpeedData) return;
    final settings = await userSettingsRepository.loadSettings();
    final unit = settings.speedUnit;
    double newSpeed = event.currentSpeed * 3.6; // m/s to km/h
    if (unit == SpeedUnit.mph) {
      newSpeed = newSpeed.mile;
    }
    
    emit(currentState.copyWith(
      speed: newSpeed,
      unit: unit,
      animationDuration: event.speedCameraModel.calculateDuration(),
      isOverSpeed: event.speedCameraModel.isOverSpeed
    ));
  }

  Future<void> _onStartDetection(
    StartDetection event,
    Emitter<SpeedState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SpeedData) return;

    try {
      await repository.startLocationTracking((speedCameraModel) {
        if (speedCameraModel != null) {
          add(UpdateSpeed(speedCameraModel));
        } else {
          add(const StopDetection());
        }
      });
      // 更新狀態為偵測中
      emit(currentState.copyWith(isDetecting: true));
    } catch (e) {
      // 3. 處理錯誤
      debugPrint('SpeedBloc: 啟動偵測失敗 - $e');
      emit(currentState.copyWith(isDetecting: false));
    }
  }

  Future<void> _onStopDetection(
    StopDetection event,
    Emitter<SpeedState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SpeedData) return;

    debugPrint('SpeedBloc: 停止偵測');

    try {
      await repository.stopLocationTracking();
      emit(
        currentState.copyWith(speed: 0, isOverSpeed: false, isDetecting: false),
      );
    } catch (e) {
      debugPrint('SpeedBloc: 停止定位失敗 - $e');
    }
  }


  @override
  Future<void> close() {
    return super.close();
  }
}
