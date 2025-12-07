import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/core/repositories/user_settings_repository.dart';
import 'speed_detection_settings_event.dart';
import 'speed_detection_settings_state.dart';
import 'package:garage/core/models/speed_unit.dart';
import 'package:garage/core/models/user_settings.dart';
import 'package:garage/core/mixins/app_lifecycle_mixin.dart';
import 'package:garage/core/core.dart';

class SpeedDetectionSettingsBloc
    extends Bloc<SpeedDetectionSettingsEvent, SpeedDetectionSettingsState>
    with AppLifecycleMixin<SpeedDetectionSettingsEvent, SpeedDetectionSettingsState> {

  final UserSettingsRepository userSettingRepo = getIt.repo.userSettings;
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
      case PlayTestVoice():
        await _onPlayTestVoice(emit);
      case ChangeVoiceEngine():
        _onChangeVoiceEngine(event, emit);
      case ChangeAlertDistance():
        _onChangeAlertDistance(event, emit);
      case CheckLocationPermission():
        await _onCheckLocationPermission(emit);
      case RequestLocationPermission():
        await _onRequestLocationPermission(emit);
    }
  }

  Future<void> _onLoadSettings(Emitter<SpeedDetectionSettingsState> emit) async {
    try {
      final settings = await userSettingRepo.loadSettings();
      // 权限检查失败时当作没有权限
      final hasPermission = await repository.checkPermission().catchError((_) => false);

      emit(
        SpeedDetectionSettingsLoaded(
          speedUnit: settings.speedUnit,
          isVoiceAlertEnabled: settings.isVoiceAlertEnabled,
          voiceVolume: settings.voiceVolume,
          voiceSpeechRate: settings.voiceSpeechRate,
          voiceEngine: settings.voiceEngine,
          alertDistance: settings.alertDistance, // State 會自動驗證範圍
          hasLocationPermission: hasPermission,
        ),
      );
    } catch (e) {
      // 加载失败时使用默认值
      emit(
        SpeedDetectionSettingsLoaded(
          speedUnit: SpeedUnit.kmh,
          isVoiceAlertEnabled: true,
          voiceVolume: 0.8,
          voiceSpeechRate: 0.5,
          voiceEngine: null,
          alertDistance: 500,
          hasLocationPermission: false,
        ),
      );
    }
  }

  void _onChangeSpeedUnit(
    ChangeSpeedUnit event,
    Emitter<SpeedDetectionSettingsState> emit,
  ) {
    final currentState = state;
    if (currentState is SpeedDetectionSettingsLoaded) {
      emit(currentState.copyWith(speedUnit: event.unit));

      // 异步更新缓存
      _updateRepositoryCache((settings) =>
        settings.copyWith(speedUnit: event.unit)
      );
    }
  }

  void _onToggleVoiceAlert(Emitter<SpeedDetectionSettingsState> emit) {
    final currentState = state;
    if (currentState is SpeedDetectionSettingsLoaded) {
      final newValue = !currentState.isVoiceAlertEnabled;
      emit(
        currentState.copyWith(
          isVoiceAlertEnabled: newValue,
        ),
      );

      // 异步更新缓存
      _updateRepositoryCache((settings) =>
        settings.copyWith(isVoiceAlertEnabled: newValue)
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

      // 异步更新缓存
      _updateRepositoryCache((settings) =>
        settings.copyWith(voiceVolume: event.volume)
      );
    }
  }

  void _onChangeVoiceSpeechRate(
    ChangeVoiceSpeechRate event,
    Emitter<SpeedDetectionSettingsState> emit,
  ) {
    final currentState = state;
    if (currentState is SpeedDetectionSettingsLoaded) {
      emit(currentState.copyWith(voiceSpeechRate: event.rate));

      // 异步更新缓存
      _updateRepositoryCache((settings) =>
        settings.copyWith(voiceSpeechRate: event.rate)
      );
    }
  }

  Future<void> _onPlayTestVoice(
    Emitter<SpeedDetectionSettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is SpeedDetectionSettingsLoaded) {
      // TODO: 实现语音播放功能
      // 这里需要调用 TTS 服务播放测试音频
      // 可以播放类似 "测速提示测试" 的文本
      print('Playing test voice with engine: ${currentState.voiceEngine}');
    }
  }

  void _onChangeVoiceEngine(
    ChangeVoiceEngine event,
    Emitter<SpeedDetectionSettingsState> emit,
  ) {
    final currentState = state;
    if (currentState is SpeedDetectionSettingsLoaded) {
      emit(currentState.copyWith(voiceEngine: event.engineId));

      // 异步更新缓存
      _updateRepositoryCache((settings) =>
        settings.copyWith(voiceEngine: event.engineId)
      );
    }
  }

  void _onChangeAlertDistance(
    ChangeAlertDistance event,
    Emitter<SpeedDetectionSettingsState> emit,
  ) {
    final currentState = state;
    if (currentState is SpeedDetectionSettingsLoaded) {
      emit(currentState.copyWith(alertDistance: event.distance)); // State 會自動驗證範圍

      // 异步更新缓存
      _updateRepositoryCache((settings) =>
        settings.copyWith(alertDistance: event.distance)
      );
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

  /// 更新 Repository 缓存（不保存到持久化存储）
  Future<void> _updateRepositoryCache(
    UserSettings Function(UserSettings) updater,
  ) async {
    try {
      final settings = await userSettingRepo.loadSettings();
      await userSettingRepo.updateSettings(updater(settings));
    } catch (e) {
      // 静默失败，不影响 UI
    }
  }

  /// 保存当前设置到持久化存储
  Future<void> _saveCurrentSettings() async {
    final currentState = state;
    if (currentState is SpeedDetectionSettingsLoaded) {
      try {
        // 获取完整的 UserSettings
        final fullSettings = await userSettingRepo.loadSettings();

        // 只更新测速相关字段
        final updatedSettings = fullSettings.copyWith(
          speedUnit: currentState.speedUnit,
          isVoiceAlertEnabled: currentState.isVoiceAlertEnabled,
          voiceVolume: currentState.voiceVolume,
          voiceSpeechRate: currentState.voiceSpeechRate,
          voiceEngine: currentState.voiceEngine,
          alertDistance: currentState.alertDistance,
        );

        // 持久化保存
        await userSettingRepo.saveSettings(updatedSettings);
      } catch (e) {
        // 保存失败记录日志（不阻塞 close）
        print('Failed to save settings: $e');
      }
    }
  }

  @override
  void onAppResumed() {
    // App 回到前景時重新檢查權限
    add(const CheckLocationPermission());
  }

  @override
  Future<void> close() async {
    // 保存设置到持久化存储
    await _saveCurrentSettings();

    // 调用 super.close（包含 AppLifecycleMixin 的清理）
    return super.close();
  }
}