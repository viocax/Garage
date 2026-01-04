import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:garage/core/core.dart';
import 'settings_event.dart';
import 'settings_state.dart';
import 'package:garage/core/repositories/ad_repository.dart';
import 'package:flutter/foundation.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final ISpeedCameraRepository _speedCameraRepository = getIt.repo.speedCamera;
  final AdRepository _adRepository = getIt.repo.ad;

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
      case WatchAdForTicket():
        await _onWatchAdForTicket(emit);
      case WatchAdForBannerRemoval():
        await _onWatchAdForBannerRemoval(emit);
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

  Future<void> _onWatchAdForTicket(Emitter<SettingsState> emit) async {
    // 檢查是否已是 VIP
    if (_adRepository.isAdFree) return;

    await _adRepository.showRewardedAd(
      onReward: () async {
        await _adRepository.grantAdTicket(1);
        emit(
          SettingsError('settings.earnedTicketSuccess'.tr()),
        ); // 暫時用 Error state 來顯示 Toast
      },
    );
  }

  Future<void> _onWatchAdForBannerRemoval(Emitter<SettingsState> emit) async {
    // 檢查是否已是 VIP
    if (_adRepository.isAdFree) return;

    await _adRepository.showRewardedAd(
      onReward: () async {
        await _adRepository.grantBannerAdFree(const Duration(hours: 12));
        emit(
          SettingsError('settings.removeBannerSuccess'.tr()),
        ); // 暫時用 Error state 來顯示 Toast
      },
    );
  }
}
