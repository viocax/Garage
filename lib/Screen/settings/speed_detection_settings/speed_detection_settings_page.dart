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
              title: const Text('測速設置'),
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
                        const SettingsSectionHeader(title: '位置服務'),
                        SettingsItem(
                          title: '位置權限',
                          icon: Icons.location_on_outlined,
                          subtitle: '允許應用程式存取您的位置',
                          onTap: () => _showPermissionAlert(context),
                        ),
                      ],

                      // 語音提示設定
                      const SettingsSectionHeader(title: '語音提示'),
                      SettingsToggleItem(
                        title: '語音提示',
                        icon: Icons.record_voice_over_outlined,
                        value: isLoaded ? state.isVoiceAlertEnabled : false,
                        subtitle: '開啟測速提醒語音播報',
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
                          title: '語音音量',
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
                      const SettingsSectionHeader(title: '提醒設定'),
                      if (isLoaded)
                        SettingsSliderItem(
                          title: '提前提醒距離',
                          icon: Icons.location_searching,
                          value: state.alertDistance.toDouble(),
                          min: SpeedDetectionSettingsLoaded.minAlertDistance.toDouble(),
                          max: SpeedDetectionSettingsLoaded.maxAlertDistance.toDouble(),
                          divisions: state.alertDistanceDivisions,
                          label: '${state.alertDistance} 公尺',
                          onChanged: (value) {
                            context.read<SpeedDetectionSettingsBloc>().add(
                              ChangeAlertDistance(value.round()),
                            );
                          },
                        ),

                      // 速度單位
                      const SettingsSectionHeader(title: '單位設定'),
                      if (isLoaded)
                        SettingsSegmentedItem<SpeedUnit>(
                          title: '速度單位',
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
      title: '需要位置權限',
      message: '測速功能需要存取您的位置資訊才能正常運作。請前往設定開啟位置權限。',
      cancelText: '稍後再說',
      confirmText: '前往設定',
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
