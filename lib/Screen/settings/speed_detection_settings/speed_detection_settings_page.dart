import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/core/models/speed_unit.dart';
import 'package:garage/core/extensions/dialog_extension.dart';
import 'package:garage/theme/themed_status_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'bloc/speed_detection_settings_bloc.dart';
import 'bloc/speed_detection_settings_event.dart';
import 'bloc/speed_detection_settings_state.dart';
import '../widgets/settings_section_header.dart';
import '../widgets/settings_item.dart';
import '../widgets/settings_toggle_item.dart';
import '../widgets/settings_slider_item.dart';
import '../widgets/settings_segmented_item.dart';

class SpeedDetectionSettingsPage extends StatelessWidget {
  const SpeedDetectionSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SpeedDetectionSettingsBloc(),
      child: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<SpeedDetectionSettingsBloc, SpeedDetectionSettingsState>(
      builder: (context, state) {
        final isLoaded = state is SpeedDetectionSettingsLoaded;
        final hasLocationPermission = isLoaded
            ? state.hasLocationPermission
            : false;

        return ThemedStatusBar(
          child: Scaffold(
            appBar: AppBar(
              title: Text('speedDetection.title'.tr()),
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
            ),
            body: Stack(
              children: [
                // 主要內容 - 始終顯示
                SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      // 位置權限 - 只在沒有權限時顯示
                      if (!hasLocationPermission) ...[
                        SettingsSectionHeader(title: 'speedDetection.locationService'.tr()),
                        SettingsItem(
                          title: 'speedDetection.locationPermission'.tr(),
                          icon: Icons.location_on_outlined,
                          subtitle: 'speedDetection.locationPermissionDesc'.tr(),
                          onTap: () => _showPermissionAlert(context),
                        ),
                      ],

                      // 語音提示設定
                      SettingsSectionHeader(title: 'speedDetection.voiceAlert'.tr()),
                      SettingsToggleItem(
                        title: 'speedDetection.voiceAlert'.tr(),
                        icon: Icons.record_voice_over_outlined,
                        value: isLoaded ? state.isVoiceAlertEnabled : false,
                        subtitle: 'speedDetection.voiceAlertDesc'.tr(),
                        onTap: isLoaded
                            ? () {
                                context.read<SpeedDetectionSettingsBloc>().add(
                                  const ToggleVoiceAlert(),
                                );
                              }
                            : null,
                      ),
                      if (isLoaded && state.isVoiceAlertEnabled) ...[
                        SettingsSliderItem(
                          title: 'speedDetection.voiceVolume'.tr(),
                          icon: Icons.volume_up,
                          value: state.voiceVolumePercentage,
                          onChanged: (value) {
                            context.read<SpeedDetectionSettingsBloc>().add(
                              ChangeVoiceVolume(value),
                            );
                          },
                        ),
                      ],

                      // 提醒設定
                      SettingsSectionHeader(title: 'speedDetection.alertSettings'.tr()),
                      if (isLoaded)
                        SettingsSliderItem(
                          title: 'speedDetection.alertDistance'.tr(),
                          icon: Icons.location_searching,
                          value: state.alertDistance.toDouble(),
                          min: SpeedDetectionSettingsLoaded.minAlertDistance.toDouble(),
                          max: SpeedDetectionSettingsLoaded.maxAlertDistance.toDouble(),
                          divisions: state.alertDistanceDivisions,
                          label: 'speedDetection.metersFormat'.tr(args: [state.alertDistance.toString()]),
                          onChanged: (value) {
                            context.read<SpeedDetectionSettingsBloc>().add(
                              ChangeAlertDistance(value.round()),
                            );
                          },
                        ),

                      // 速度單位
                      SettingsSectionHeader(title: 'speedDetection.unitSettings'.tr()),
                      if (isLoaded)
                        SettingsSegmentedItem<SpeedUnit>(
                          title: 'speedDetection.speedUnit'.tr(),
                          icon: Icons.speed,
                          currentValue: state.speedUnit,
                          options: {
                            for (var unit in SpeedUnit.values)
                              unit: unit.displayName,
                          },
                          onChanged: (unit) {
                            context.read<SpeedDetectionSettingsBloc>().add(
                              ChangeSpeedUnit(unit),
                            );
                          },
                        ),
                    ],
                  ),
                ),

                // Loading HUD - 只在未載入時顯示
                if (state is SpeedDetectionSettingsInitial)
                  Container(
                    color: theme.colorScheme.surface.withValues(alpha: 0.3),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPermissionAlert(BuildContext context) {
    context.showAdaptivePermissionAlert(
      title: 'speedDetection.locationPermissionRequired'.tr(),
      message: 'speedDetection.locationPermissionMessage'.tr(),
      cancelText: 'common.later'.tr(),
      confirmText: 'common.goToSettings'.tr(),
      onConfirm: () async {
        await Geolocator.openAppSettings();
        // 從設定回來後重新檢查權限
        if (context.mounted) {
          context.read<SpeedDetectionSettingsBloc>().add(
            const CheckLocationPermission(),
          );
        }
      },
    );
  }
}
