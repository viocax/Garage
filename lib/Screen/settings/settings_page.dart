import 'package:flutter/material.dart';
import 'package:garage/core/extensions/dialog_extension.dart';
import 'package:garage/theme/themed_status_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/router/app_router.dart';
import 'bloc/settings_bloc.dart';
import 'bloc/settings_state.dart';
import 'bloc/settings_event.dart';
import 'widgets/settings_section_header.dart';
import 'widgets/settings_item.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc(),
      child: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    final theme = Theme.of(context);
    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: (context, state) {
        switch (state) {
          case SettingsNormal():
            break;
          case GoToSpeedSetting():
            context.goPath(AppPath.speedDetectionSettings);
            break;
          case RemindUserStopTrackingAlert():
            context.showAdaptivePermissionAlert(
              title: '目前正開啟測速中',
              message: '調整設定需要關閉測速',
              cancelText: '取消',
              confirmText: '確定',
              onConfirm: () {
                context.read<SettingsBloc>().add(const StopTracking());
              },
            );
            break;
          case SettingsError():
            // TODO: show toast
            break;
        }
      },
      builder: (context, state) {
        return ThemedStatusBar(
          theme: StatusBarTheme.system,
          child: Scaffold(
            body: Stack(
              children: [
                // 主要內容 - 始終顯示
                SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      // 一般設定
                      const SettingsSectionHeader(title: '一般'),
                      SettingsItem(
                        title: '車輛管理',
                        icon: Icons.directions_car_outlined,
                        onTap: () {
                          context.goPath(AppPath.vehicleManagement);
                        },
                      ),
                      SettingsItem(
                        title: '測速設置',
                        icon: Icons.radar_outlined,
                        onTap: () {
                          context.read<SettingsBloc>().add(
                            const ClickSpeedSetting(),
                          );
                        },
                      ),

                      // 資料管理
                      const SettingsSectionHeader(title: '資料'),
                      SettingsItem(
                        title: '匯出資料',
                        icon: Icons.upload_file_outlined,
                        onTap: () {
                          context.read<SettingsBloc>().add(const ExportData());
                        },
                      ),
                      SettingsItem(
                        title: '清除資料',
                        icon: Icons.delete_outline,
                        isDestructive: true,
                        onTap: () {
                          context.read<SettingsBloc>().add(const ClearData());
                        },
                      ),

                      // 關於
                      const SettingsSectionHeader(title: '關於'),
                      const SettingsItem(
                        title: '使用條款',
                        icon: Icons.description_outlined,
                      ),
                      const SettingsItem(
                        title: '隱私政策',
                        icon: Icons.privacy_tip_outlined,
                      ),
                      const SettingsItem(
                        title: '意見回饋',
                        icon: Icons.feedback_outlined,
                      ),
                      const SettingsItem(
                        title: '評分 App',
                        icon: Icons.star_outline,
                      ),

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
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
