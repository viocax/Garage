import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

    return Scaffold(
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
                    _buildSettingsItem(context, '主題設定', Icons.palette_outlined),
                    _buildSelectionItem(
                      context,
                      '速度單位',
                      Icons.speed,
                      state.speedUnit,
                      onTap: () => _showUnitDialog(
                        context,
                        '選擇速度單位',
                        state.speedUnit,
                        ['km/h', 'mph'],
                        (unit) => context.read<SettingsBloc>().add(
                          ChangeSpeedUnit(unit),
                        ),
                      ),
                    ),
                    _buildSelectionItem(
                      context,
                      '距離單位',
                      Icons.straighten,
                      state.distanceUnit,
                      onTap: () => _showUnitDialog(
                        context,
                        '選擇距離單位',
                        state.distanceUnit,
                        ['km', 'mi'],
                        (unit) => context.read<SettingsBloc>().add(
                          ChangeDistanceUnit(unit),
                        ),
                      ),
                    ),

                    // 測速提醒
                    _buildSectionHeader(context, '測速提醒'),
                    _buildToggleItem(
                      context,
                      '警示音效',
                      Icons.volume_up_outlined,
                      state.isSoundEnabled,
                      onTap: () {
                        context.read<SettingsBloc>().add(const ToggleSound());
                      },
                    ),

                    // 顯示設定
                    _buildSectionHeader(context, '顯示設定'),
                    _buildSelectionItem(
                      context,
                      '地圖類型',
                      Icons.map_outlined,
                      _getMapTypeLabel(state.mapType),
                      onTap: () => _showMapTypeDialog(context, state.mapType),
                    ),
                    _buildToggleItem(
                      context,
                      '顯示測速相機',
                      Icons.camera_alt_outlined,
                      state.showSpeedCameras,
                      onTap: () {
                        context.read<SettingsBloc>().add(
                          const ToggleSpeedCameras(),
                        );
                      },
                    ),
                    _buildToggleItem(
                      context,
                      '顯示平均速度',
                      Icons.trending_up,
                      state.showAverageSpeed,
                      onTap: () {
                        context.read<SettingsBloc>().add(
                          const ToggleAverageSpeed(),
                        );
                      },
                    ),

                    // 隱私與安全
                    _buildSectionHeader(context, '隱私與安全'),
                    _buildSettingsItem(
                      context,
                      '位置權限',
                      Icons.location_on_outlined,
                    ),
                    _buildToggleItem(
                      context,
                      '允許資料收集',
                      Icons.analytics_outlined,
                      state.allowDataCollection,
                      onTap: () {
                        context.read<SettingsBloc>().add(
                          const ToggleDataCollection(),
                        );
                      },
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
    );
  }

  String _getMapTypeLabel(String mapType) {
    switch (mapType) {
      case 'standard':
        return '標準';
      case 'satellite':
        return '衛星';
      case 'hybrid':
        return '混合';
      default:
        return '標準';
    }
  }

  void _showMapTypeDialog(BuildContext context, String currentType) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('選擇地圖類型'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogOption(
              dialogContext,
              '標準',
              'standard',
              currentType,
              () {
                context.read<SettingsBloc>().add(
                  const ChangeMapType('standard'),
                );
                Navigator.pop(dialogContext);
              },
            ),
            _buildDialogOption(
              dialogContext,
              '衛星',
              'satellite',
              currentType,
              () {
                context.read<SettingsBloc>().add(
                  const ChangeMapType('satellite'),
                );
                Navigator.pop(dialogContext);
              },
            ),
            _buildDialogOption(dialogContext, '混合', 'hybrid', currentType, () {
              context.read<SettingsBloc>().add(const ChangeMapType('hybrid'));
              Navigator.pop(dialogContext);
            }),
          ],
        ),
      ),
    );
  }

  void _showUnitDialog(
    BuildContext context,
    String title,
    String currentUnit,
    List<String> options,
    Function(String) onSelect,
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
              option,
              option,
              currentUnit,
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
    return ListTile(
      title: Text(label),
      trailing: isSelected ? const Icon(Icons.check, color: AppTheme.systemBlue) : null,
      onTap: onTap,
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
              style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.systemGray),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppTheme.systemGray),
          ],
        ),
        onTap: onTap ?? () {},
      ),
    );
  }
}
