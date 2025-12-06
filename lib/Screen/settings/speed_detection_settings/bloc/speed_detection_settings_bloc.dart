import 'package:flutter_bloc/flutter_bloc.dart';
import 'speed_detection_settings_event.dart';
import 'speed_detection_settings_state.dart';
import 'package:garage/core/models/speed_unit.dart';

class SpeedDetectionSettingsBloc
    extends Bloc<SpeedDetectionSettingsEvent, SpeedDetectionSettingsState> {
  SpeedDetectionSettingsBloc()
      : super(const SpeedDetectionSettingsInitial()) {
    on<SpeedDetectionSettingsEvent>(_onEvent);
    add(const LoadSpeedDetectionSettings());
  }

  Future<void> _onEvent(
    SpeedDetectionSettingsEvent event,
    Emitter<SpeedDetectionSettingsState> emit,
  ) async {
    switch (event) {
      case LoadSpeedDetectionSettings():
        _onLoadSettings(emit);
      case ChangeSpeedUnit():
        _onChangeSpeedUnit(event, emit);
      case ToggleVoiceAlert():
        _onToggleVoiceAlert(emit);
      case ChangeVoiceVolume():
        _onChangeVoiceVolume(event, emit);
      case ChangeVoiceSpeechRate():
        _onChangeVoiceSpeechRate(event, emit);
    }
  }

  void _onLoadSettings(Emitter<SpeedDetectionSettingsState> emit) {
    // Simulate loading settings with default values
    emit(
      const SpeedDetectionSettingsLoaded(
        speedUnit: SpeedUnit.kmh,
        isVoiceAlertEnabled: true,
        voiceVolume: 1.0,
        voiceSpeechRate: 0.5,
      ),
    );
  }

  void _onChangeSpeedUnit(
    ChangeSpeedUnit event,
    Emitter<SpeedDetectionSettingsState> emit,
  ) {
    final currentState = state;
    if (currentState is SpeedDetectionSettingsLoaded) {
      emit(currentState.copyWith(speedUnit: event.unit));
    }
  }

  void _onToggleVoiceAlert(Emitter<SpeedDetectionSettingsState> emit) {
    final currentState = state;
    if (currentState is SpeedDetectionSettingsLoaded) {
      emit(
        currentState.copyWith(
          isVoiceAlertEnabled: !currentState.isVoiceAlertEnabled,
        ),
      );
    }
  }

  void _onChangeVoiceVolume(
    ChangeVoiceVolume event,
    Emitter<SpeedDetectionSettingsState> emit,
  ) {
    final currentState = state;
    if (currentState is SpeedDetectionSettingsLoaded) {
      emit(currentState.copyWith(voiceVolume: event.volume));
    }
  }

  void _onChangeVoiceSpeechRate(
    ChangeVoiceSpeechRate event,
    Emitter<SpeedDetectionSettingsState> emit,
  ) {
    final currentState = state;
    if (currentState is SpeedDetectionSettingsLoaded) {
      emit(currentState.copyWith(voiceSpeechRate: event.rate));
    }
  }
}
