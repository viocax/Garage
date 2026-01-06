import 'dart:async';
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
  SettingsBloc() : super(const SettingsState()) {
    on<SettingsEvent>(_onEvent);

    add(const LoadSettingsStatus());
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
      case LoadSettingsStatus():
        await _onLoadStatus(emit);
      case ResetSettingsAction():
        emit(state.copyWith(clearAction: true));
    }
  }

  Future<void> _onLoadStatus(Emitter<SettingsState> emit) async {
    emit(state.copyWith(isPro: false));
  }

  Future<void> _onStopTracking(Emitter<SettingsState> emit) async {
    try {
      await _speedCameraRepository.stopLocationTracking();
      emit(state.copyWith(action: SettingsAction.goToSpeedSetting));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  void _onClickSpeedSetting(Emitter<SettingsState> emit) {
    if (_speedCameraRepository.isTracking) {
      emit(state.copyWith(action: SettingsAction.showStopTrackingAlert));
    } else {
      emit(state.copyWith(action: SettingsAction.goToSpeedSetting));
    }
  }

  void _onClearData(Emitter<SettingsState> emit) {
    debugPrint('Clear Data Triggered');
  }

  Future<void> _onWatchAdForTicket(Emitter<SettingsState> emit) async {
    if (_adRepository.isAdFree) return;

    await _adRepository.showRewardedAd(
      onReward: () async {
        await _adRepository.grantAdTicket(1);
        emit(state.copyWith(errorMessage: 'settings.earnedTicketSuccess'.tr()));
      },
    );
  }

  Future<void> _onWatchAdForBannerRemoval(Emitter<SettingsState> emit) async {
    if (_adRepository.isAdFree) return;

    await _adRepository.showRewardedAd(
      onReward: () async {
        await _adRepository.grantBannerAdFree(const Duration(hours: 12));
        emit(state.copyWith(errorMessage: 'settings.removeBannerSuccess'.tr()));
      },
    );
  }

  Future<void> _onSendFeedback(Emitter<SettingsState> emit) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'garagesup812860@gmail.com',
      query: _encodeQueryParameters(<String, String>{
        'subject': 'Garage App Feedback',
      }),
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        emit(state.copyWith(errorMessage: '無法開啟郵件應用程式'));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: '發生錯誤：$e'));
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
