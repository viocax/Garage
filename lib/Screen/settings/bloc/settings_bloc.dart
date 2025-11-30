import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_event.dart';
import 'settings_state.dart';
import 'package:flutter/foundation.dart';
import 'package:garage/core/models/speed_unit.dart';

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
      case ChangeSpeedUnit():
        _onChangeSpeedUnit(event, emit);
      case ExportData():
        _onExportData(emit);
      case ClearData():
        _onClearData(emit);
      case ToggleVoiceAlert():
        _onToggleVoiceAlert(emit);
      case ChangeVoiceVolume():
        _onChangeVoiceVolume(event, emit);
      case ChangeVoiceSpeechRate():
        _onChangeVoiceSpeechRate(event, emit);
    }
  }

  void _onLoadSettings(Emitter<SettingsState> emit) {
    // Simulate loading settings with default values
    emit(
      const SettingsLoaded(
        speedUnit: SpeedUnit.kmh,
        isVoiceAlertEnabled: true,
        voiceVolume: 1.0,
        voiceSpeechRate: 0.5,
      ),
    );
  }

  void _onChangeSpeedUnit(ChangeSpeedUnit event, Emitter<SettingsState> emit) {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      emit(currentState.copyWith(speedUnit: event.unit));
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

  void _onToggleVoiceAlert(Emitter<SettingsState> emit) {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      emit(
        currentState.copyWith(
          isVoiceAlertEnabled: !currentState.isVoiceAlertEnabled,
        ),
      );
    }
  }

  void _onChangeVoiceVolume(
    ChangeVoiceVolume event,
    Emitter<SettingsState> emit,
  ) {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      emit(currentState.copyWith(voiceVolume: event.volume));
    }
  }

  void _onChangeVoiceSpeechRate(
    ChangeVoiceSpeechRate event,
    Emitter<SettingsState> emit,
  ) {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      emit(currentState.copyWith(voiceSpeechRate: event.rate));
    }
  }
}
