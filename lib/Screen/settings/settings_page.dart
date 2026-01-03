import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/core/extensions/dialog_extension.dart';
import 'package:garage/router/app_router.dart';
import 'package:garage/theme/themed_status_bar.dart';

import 'bloc/settings_bloc.dart';
import 'bloc/settings_event.dart';
import 'bloc/settings_state.dart';
import 'widgets/settings_item.dart';
import 'widgets/settings_section_header.dart';

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
              title: 'speedDetection.speedRunning'.tr(),
              message: 'speedDetection.speedRunningMsg'.tr(),
              cancelText: 'common.cancel'.tr(),
              confirmText: 'common.confirm'.tr(),
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
                      SettingsSectionHeader(title: 'settings.general'.tr()),
                      SettingsItem(
                        title: 'settings.vehicleManagement'.tr(),
                        icon: Icons.directions_car_outlined,
                        onTap: () {
                          context.goPath(AppPath.vehicleManagement);
                        },
                      ),
                      SettingsItem(
                        title: 'settings.speedDetection'.tr(),
                        icon: Icons.radar_outlined,
                        onTap: () {
                          context.read<SettingsBloc>().add(
                            const ClickSpeedSetting(),
                          );
                        },
                      ),

                      // 資料管理
                      SettingsSectionHeader(title: 'settings.data'.tr()),
                      SettingsItem(
                        title: 'settings.cloudSync'.tr(),
                        icon: Icons.cloud_sync_outlined,
                        onTap: () {
                          context.goPath(AppPath.cloudSync);
                        },
                      ),
                      SettingsItem(
                        title: 'settings.clearData'.tr(),
                        icon: Icons.delete_outline,
                        isDestructive: true,
                        onTap: () {
                          context.read<SettingsBloc>().add(const ClearData());
                        },
                      ),

                      // 關於
                      SettingsSectionHeader(title: 'settings.about'.tr()),
                      SettingsItem(
                        title: 'settings.termsOfService'.tr(),
                        icon: Icons.description_outlined,
                      ),
                      SettingsItem(
                        title: 'settings.privacyPolicy'.tr(),
                        icon: Icons.privacy_tip_outlined,
                      ),
                      SettingsItem(
                        title: 'settings.feedback'.tr(),
                        icon: Icons.feedback_outlined,
                      ),
                      SettingsItem(
                        title: 'settings.rateApp'.tr(),
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
