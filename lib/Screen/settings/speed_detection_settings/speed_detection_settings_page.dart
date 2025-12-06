import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/core/models/speed_unit.dart';
import 'package:garage/theme/app_theme.dart';
import 'package:garage/theme/themed_status_bar.dart';
import 'bloc/speed_detection_settings_bloc.dart';
import 'bloc/speed_detection_settings_event.dart';
import 'bloc/speed_detection_settings_state.dart';
import '../widgets/settings_section_header.dart';
import '../widgets/settings_item.dart';
import '../widgets/settings_toggle_item.dart';
import '../widgets/settings_selection_item.dart';
import '../widgets/settings_slider_item.dart';

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

        return ThemedStatusBar(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('測速設置'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: Stack(
              children: [
                // 主要內容 - 始終顯示
                SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      // 位置權限
                      const SettingsSectionHeader(title: '位置服務'),
                      const SettingsItem(
                        title: '位置權限',
                        icon: Icons.location_on_outlined,
                        subtitle: '允許應用程式存取您的位置',
                      ),

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
                          value: state.voiceVolume,
                          onChanged: (value) {
                            context.read<SpeedDetectionSettingsBloc>().add(
                              ChangeVoiceVolume(value),
                            );
                          },
                        ),
                        SettingsSliderItem(
                          title: '語速',
                          icon: Icons.speed,
                          value: state.voiceSpeechRate,
                          onChanged: (value) {
                            context.read<SpeedDetectionSettingsBloc>().add(
                              ChangeVoiceSpeechRate(value),
                            );
                          },
                        ),
                      ],

                      // 速度單位
                      const SettingsSectionHeader(title: '單位設定'),
                      SettingsSelectionItem(
                        title: '速度單位',
                        icon: Icons.speed,
                        currentValue: isLoaded ? state.speedUnit.displayName : '--',
                        subtitle: '選擇速度顯示單位',
                        onTap: isLoaded
                            ? () => _showUnitDialog(
                                  context,
                                  '選擇速度單位',
                                  state.speedUnit,
                                  SpeedUnit.values,
                                  (unit) => context.read<SpeedDetectionSettingsBloc>().add(
                                    ChangeSpeedUnit(unit),
                                  ),
                                )
                            : null,
                      ),
                    ],
                  ),
                ),

                // Loading HUD - 只在未載入時顯示
                if (state is SpeedDetectionSettingsInitial)
                  Container(
                    color: theme.colorScheme.surface.withValues(alpha: 0.3),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUnitDialog(
    BuildContext context,
    String title,
    SpeedUnit currentUnit,
    List<SpeedUnit> options,
    Function(SpeedUnit) onSelect,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((option) {
            return _buildDialogOption(
              dialogContext,
              option.displayName,
              option.value,
              currentUnit.value,
              () {
                onSelect(option);
                Navigator.pop(dialogContext);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDialogOption(
    BuildContext context,
    String label,
    String value,
    String currentValue,
    VoidCallback onTap,
  ) {
    final isSelected = value == currentValue;
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      child: ListTile(
        title: Text(label),
        trailing: isSelected
            ? const Icon(Icons.check, color: AppTheme.systemBlue)
            : null,
        onTap: onTap,
      ),
    );
  }
}
