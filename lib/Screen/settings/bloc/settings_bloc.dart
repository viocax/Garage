import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_event.dart';
import 'settings_state.dart';
import 'package:flutter/foundation.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsInitial()) {
    on<SettingsEvent>(_onEvent);
  }

  Future<void> _onEvent(
    SettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    switch (event) {
      case LoadSettings():
        _onLoadSettings(emit);
      case ToggleSound():
        _onToggleSound(emit);
      case ChangeSpeedUnit():
        _onChangeSpeedUnit(event, emit);
      case ChangeDistanceUnit():
        _onChangeDistanceUnit(event, emit);
      case ChangeMapType():
        _onChangeMapType(event, emit);
      case ToggleSpeedCameras():
        _onToggleSpeedCameras(emit);
      case ToggleAverageSpeed():
        _onToggleAverageSpeed(emit);
      case ToggleDataCollection():
        _onToggleDataCollection(emit);
      case ExportData():
        _onExportData(emit);
      case ClearData():
        _onClearData(emit);
    }
  }

  void _onLoadSettings(Emitter<SettingsState> emit) {
    // Simulate loading settings with default values
    emit(
      const SettingsLoaded(
        isSoundEnabled: true,
        speedUnit: 'km/h',
        distanceUnit: 'km',
        mapType: 'standard',
        showSpeedCameras: true,
        showAverageSpeed: false,
        allowDataCollection: false,
      ),
    );
  }

  void _onToggleSound(Emitter<SettingsState> emit) {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      emit(currentState.copyWith(isSoundEnabled: !currentState.isSoundEnabled));
    }
  }

  void _onChangeSpeedUnit(ChangeSpeedUnit event, Emitter<SettingsState> emit) {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      emit(currentState.copyWith(speedUnit: event.unit));
    }
  }

  void _onChangeDistanceUnit(
    ChangeDistanceUnit event,
    Emitter<SettingsState> emit,
  ) {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      emit(currentState.copyWith(distanceUnit: event.unit));
    }
  }

  void _onChangeMapType(ChangeMapType event, Emitter<SettingsState> emit) {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      emit(currentState.copyWith(mapType: event.type));
    }
  }

  void _onToggleSpeedCameras(Emitter<SettingsState> emit) {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      emit(
        currentState.copyWith(showSpeedCameras: !currentState.showSpeedCameras),
      );
    }
  }

  void _onToggleAverageSpeed(Emitter<SettingsState> emit) {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      emit(
        currentState.copyWith(showAverageSpeed: !currentState.showAverageSpeed),
      );
    }
  }

  void _onToggleDataCollection(Emitter<SettingsState> emit) {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      emit(
        currentState.copyWith(
          allowDataCollection: !currentState.allowDataCollection,
        ),
      );
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
