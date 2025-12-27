import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/core/core.dart';
import 'package:garage/core/models/speed_camera_model.dart';
import 'package:garage/core/models/speed_unit.dart';
import 'package:garage/core/repositories/user_settings_repository.dart';
import 'speed_event.dart';
import 'speed_state.dart';

class SpeedBloc extends Bloc<SpeedEvent, SpeedState> {
  final ISpeedCameraRepository repository = getIt.repo.speedCamera;
  final UserSettingsRepository userSettingsRepository = getIt.repo.userSettings;

  SpeedBloc()
    : super(
        SpeedData(
          model: SpeedCameraModel(
            speedLimit: 0,
            currentSpeed: 0.0,
            distance: 500.0,
            isOverSpeed: false,
            latitude: 0.0,
            longitude: 0.0,
            heading: 0.0,
          ),
          unit: SpeedUnit.kmh,
          alertDistance: 0,
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
      emit(
        currentState.copyWith(
          unit: settings.speedUnit,
          alertDistance: settings.alertDistance,
        ),
      );
    } catch (e) {
      emit(currentState.copyWith(unit: SpeedUnit.kmh, alertDistance: 0));
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
    double newSpeed = event.currentSpeed;
    if (unit == SpeedUnit.mph) {
      newSpeed = newSpeed.mile;
    }

    emit(currentState.copyWith(model: event.speedCameraModel));
  }

  Future<void> _onStartDetection(
    StartDetection event,
    Emitter<SpeedState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SpeedData) return;
    if (currentState.isDetecting) return;

    try {
      await _onSpeedLoading(const SpeedLoading(), emit);
      await repository.startLocationTracking((speedCameraModel) {
        if (speedCameraModel != null) {
          add(UpdateSpeed(speedCameraModel));
        } else {
          add(const StopDetection());
        }
      });
      final allCameras = repository
          .getAll()
          .map(
            (e) => LocationData(latitude: e.latitude, longitude: e.longitude),
          )
          .toList();
      emit(
        currentState.copyWith(isDetecting: true, cameraLocations: allCameras),
      );
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
        currentState.copyWith(
          model: currentState.model.copyWith(
            currentSpeed: 0.0,
            isOverSpeed: false,
          ),
          isDetecting: false,
        ),
      );
    } catch (e) {
      debugPrint('SpeedBloc: 停止定位失敗 - $e');
    }
  }
  @override
  Future<void> close() async {
    await repository.stopLocationTracking();
    super.close();
  }
}
