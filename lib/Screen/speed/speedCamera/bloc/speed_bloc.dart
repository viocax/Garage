import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/core/core.dart';
import 'speed_event.dart';
import 'speed_state.dart';

class SpeedBloc extends Bloc<SpeedEvent, SpeedState>
    with AppLifecycleMixin<SpeedEvent, SpeedState> {
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

    // 初始化生命週期監聽
    initLifecycleObserver();

    // 初次載入設定
    add(const SpeedLoading());
  }

  @override
  void onAppResumed() {
    debugPrint('SpeedBloc: App 回到前景，使用高精度定位');
    repository.setLocationPolicyBest();
  }

  @override
  void onAppPaused() {
    debugPrint('SpeedBloc: App 進入背景，切換至平衡定位模式');
    repository.setLocationPolicyBackground();
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
      if (e.toString().contains('Location permission denied')) {
        emit(
          currentState.copyWith(isDetecting: false, showPermissionAlert: true),
        );
      } else {
        emit(currentState.copyWith(isDetecting: false));
      }
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
