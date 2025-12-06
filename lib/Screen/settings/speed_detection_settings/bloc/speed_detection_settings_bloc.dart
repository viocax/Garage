import 'package:flutter_bloc/flutter_bloc.dart';
import 'speed_detection_settings_event.dart';
import 'speed_detection_settings_state.dart';
import 'package:garage/core/models/speed_unit.dart';
import 'package:garage/core/mixins/app_lifecycle_mixin.dart';
import 'package:garage/core/core.dart';

class SpeedDetectionSettingsBloc
    extends Bloc<SpeedDetectionSettingsEvent, SpeedDetectionSettingsState>
    with AppLifecycleMixin<SpeedDetectionSettingsEvent, SpeedDetectionSettingsState> {
  final ISpeedCameraRepository repository = getIt.repo.speedCamera;

  SpeedDetectionSettingsBloc() : super(const SpeedDetectionSettingsInitial()) {
    on<SpeedDetectionSettingsEvent>(_onEvent);
    initLifecycleObserver(); // 初始化生命週期監聽
    add(const LoadSpeedDetectionSettings());
  }

  Future<void> _onEvent(
    SpeedDetectionSettingsEvent event,
    Emitter<SpeedDetectionSettingsState> emit,
  ) async {
    switch (event) {
      case LoadSpeedDetectionSettings():
        await _onLoadSettings(emit);
      case ChangeSpeedUnit():
        _onChangeSpeedUnit(event, emit);
      case ToggleVoiceAlert():
        _onToggleVoiceAlert(emit);
      case ChangeVoiceVolume():
        _onChangeVoiceVolume(event, emit);
      case ChangeVoiceSpeechRate():
        _onChangeVoiceSpeechRate(event, emit);
      case CheckLocationPermission():
        await _onCheckLocationPermission(emit);
      case RequestLocationPermission():
        await _onRequestLocationPermission(emit);
    }
  }

  Future<void> _onLoadSettings(Emitter<SpeedDetectionSettingsState> emit) async {
    // Check location permission
    final hasPermission = await repository.checkPermission();

    // Load settings with default values
    // TODO: Unit
    emit(
      SpeedDetectionSettingsLoaded(
        speedUnit: SpeedUnit.kmh,
        isVoiceAlertEnabled: true,
        voiceVolume: 1.0,
        voiceSpeechRate: 0.5,
        hasLocationPermission: hasPermission,
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

  Future<void> _onCheckLocationPermission(
    Emitter<SpeedDetectionSettingsState> emit,
  ) async {
    final hasPermission = await repository.checkPermission();
    final currentState = state;
    if (currentState is SpeedDetectionSettingsLoaded) {
      emit(currentState.copyWith(hasLocationPermission: hasPermission));
    }
  }

  Future<void> _onRequestLocationPermission(
    Emitter<SpeedDetectionSettingsState> emit,
  ) async {
    final hasPermission = await repository.requestPermission();
    final currentState = state;
    if (currentState is SpeedDetectionSettingsLoaded) {
      emit(currentState.copyWith(hasLocationPermission: hasPermission));
    }
  }

  @override
  void onAppResumed() {
    // App 回到前景時重新檢查權限
    add(const CheckLocationPermission());
  }
}
