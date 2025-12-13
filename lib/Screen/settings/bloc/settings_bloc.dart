import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/core/core.dart';
import 'settings_event.dart';
import 'settings_state.dart';
import 'package:flutter/foundation.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final ISpeedCameraRepository _speedCameraRepository = getIt.repo.speedCamera;

  SettingsBloc() : super(const SettingsNormal()) {
    on<SettingsEvent>(_onEvent);
  }

  Future<void> _onEvent(
    SettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    switch (event) {
      case ExportData():
        _onExportData(emit);
      case ClearData():
        _onClearData(emit);
      case ClickSpeedSetting():
        _onClickSpeedSetting(emit);
      case StopTracking():
        await _onStopTracking(emit);
    }
  }
  Future<void> _onStopTracking(Emitter<SettingsState> emit) async {
    try {
      await _speedCameraRepository.stopLocationTracking();
      emit(const GoToSpeedSetting());
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }
  void _onClickSpeedSetting(Emitter<SettingsState> emit) {
    if (_speedCameraRepository.isTracking) {
      emit(const RemindUserStopTrackingAlert());
    } else {
      emit(const GoToSpeedSetting());
    }
  }

  void _onExportData(Emitter<SettingsState> emit) {
    // TODO: Implement export data logic
    debugPrint('Export Data Triggered');
  }

  void _onClearData(Emitter<SettingsState> emit) {
    // TODO: Implement clear data logic
    debugPrint('Clear Data Triggered');
  }
}
