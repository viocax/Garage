import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:garage/core/core.dart';
import 'settings_event.dart';
import 'settings_state.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

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
      case SendFeedback():
        await _onSendFeedback(emit);
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

  void _onClearData(Emitter<SettingsState> emit) {
    // Planned feature: Clear all vehicle and record data
    // Will be implemented when data management UI is ready
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

  Future<void> _onSendFeedback(Emitter<SettingsState> emit) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'drake.garage.app@gmail.com', // 預設一個開發者聯絡信箱
      query: _encodeQueryParameters(<String, String>{
        'subject': 'Garage App Feedback',
      }),
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        emit(const SettingsError('無法開啟郵件應用程式'));
      }
    } catch (e) {
      emit(SettingsError('發生錯誤：$e'));
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }
}
