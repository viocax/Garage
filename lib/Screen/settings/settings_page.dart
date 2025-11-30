import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/core/models/speed_unit.dart';
import 'package:garage/theme/app_theme.dart';
import 'bloc/settings_bloc.dart';
import 'bloc/settings_event.dart';
import 'bloc/settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc()..add(const LoadSettings()),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, state) {
                  if (state is! SettingsLoaded) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildListDelegate([
                      // 一般設定
                      _buildSectionHeader(context, '一般'),
                      _buildSettingsItem(
                        context,
                        '主題設定',
                        Icons.palette_outlined,
                      ),
                      _buildSelectionItem(
                        context,
                        '速度單位',
                        Icons.speed,
                        state.speedUnit.displayName,
                        onTap: () => _showUnitDialog(
                          context,
                          '選擇速度單位',
                          state.speedUnit,
                          SpeedUnit.values,
                          (unit) => context.read<SettingsBloc>().add(
                            ChangeSpeedUnit(unit),
                          ),
                        ),
                      ),

                      // 測速提醒
                      _buildSectionHeader(context, '測速提醒'),
                      _buildToggleItem(
                        context,
                        '語音提示',
                        Icons.record_voice_over_outlined,
                        state.isVoiceAlertEnabled,
                        onTap: () {
                          context.read<SettingsBloc>().add(
                            const ToggleVoiceAlert(),
                          );
                        },
                      ),
                      if (state.isVoiceAlertEnabled) ...[
                        _buildSliderItem(
                          context,
                          '語音音量',
                          Icons.volume_up,
                          state.voiceVolume,
                          onChanged: (value) {
                            context.read<SettingsBloc>().add(
                              ChangeVoiceVolume(value),
                            );
                          },
                        ),
                        _buildSliderItem(
                          context,
                          '語速',
                          Icons.speed,
                          state.voiceSpeechRate,
                          onChanged: (value) {
                            context.read<SettingsBloc>().add(
                              ChangeVoiceSpeechRate(value),
                            );
                          },
                        ),
                      ],

                      // 隱私與安全
                      _buildSectionHeader(context, '隱私與安全'),
                      _buildSettingsItem(
                        context,
                        '位置權限',
                        Icons.location_on_outlined,
                      ),

                      // 資料管理
                      _buildSectionHeader(context, '資料'),
                      _buildSettingsItem(
                        context,
                        '匯出資料',
                        Icons.upload_file_outlined,
                        onTap: () {
                          context.read<SettingsBloc>().add(const ExportData());
                        },
                      ),
                      _buildSettingsItem(
                        context,
                        '清除資料',
                        Icons.delete_outline,
                        isDestructive: true,
                        onTap: () {
                          context.read<SettingsBloc>().add(const ClearData());
                        },
                      ),

                      // 關於
                      _buildSectionHeader(context, '關於'),
                      _buildSettingsItem(
                        context,
                        '使用條款',
                        Icons.description_outlined,
                      ),
                      _buildSettingsItem(
                        context,
                        '隱私政策',
                        Icons.privacy_tip_outlined,
                      ),
                      _buildSettingsItem(
                        context,
                        '意見回饋',
                        Icons.feedback_outlined,
                      ),
                      _buildSettingsItem(context, '評分 App', Icons.star_outline),

                      const SizedBox(height: 40),
                      Center(
                        child: Text(
                          'Garage v1.0.0',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ]),
                  );
                },
              ),
            ],
          ),
        ),
      ),
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

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    String title,
    IconData icon, {
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: theme.copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: isDestructive
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
          ),
          title: Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDestructive
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: AppTheme.systemGray),
          onTap: onTap ?? () {},
        ),
      ),
    );
  }

  Widget _buildToggleItem(
    BuildContext context,
    String title,
    IconData icon,
    bool value, {
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: theme.copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: ListTile(
          leading: Icon(icon, color: theme.colorScheme.primary),
          title: Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          trailing: Switch(
            value: value,
            onChanged: onTap != null ? (_) => onTap() : null,
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildSelectionItem(
    BuildContext context,
    String title,
    IconData icon,
    String currentValue, {
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: theme.copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: ListTile(
          leading: Icon(icon, color: theme.colorScheme.primary),
          title: Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                currentValue,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.systemGray,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppTheme.systemGray),
            ],
          ),
          onTap: onTap ?? () {},
        ),
      ),
    );
  }

  Widget _buildSliderItem(
    BuildContext context,
    String title,
    IconData icon,
    double value, {
    required ValueChanged<double> onChanged,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(value * 100).toInt()}%',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.systemGray,
                  ),
                ),
              ],
            ),
            Slider(
              value: value,
              onChanged: onChanged,
              activeColor: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
