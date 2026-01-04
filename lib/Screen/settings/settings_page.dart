import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/core/extensions/dialog_extension.dart';
import 'package:garage/router/app_router.dart';
import 'package:garage/theme/app_theme.dart';
import 'package:garage/theme/themed_status_bar.dart';
import 'package:garage/widgets/widgets.dart';

import 'bloc/settings_bloc.dart';
import 'bloc/settings_event.dart';
import 'bloc/settings_state.dart';
import 'widgets/settings_item.dart';
import 'widgets/settings_section_header.dart';
import 'package:garage/screen/premium/premium_page.dart';

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
        if (state.errorMessage != null) {
          // Toast implementation can be added here
        }

        switch (state.action) {
          case SettingsAction.none:
            break;
          case SettingsAction.goToSpeedSetting:
            context.goPath(AppPath.speedDetectionSettings);
            context.read<SettingsBloc>().add(const ResetSettingsAction());
            break;
          case SettingsAction.showStopTrackingAlert:
            context.showAdaptivePermissionAlert(
              title: 'speedDetection.speedRunning'.tr(),
              message: 'speedDetection.speedRunningMsg'.tr(),
              cancelText: 'common.cancel'.tr(),
              confirmText: 'common.confirm'.tr(),
              onConfirm: () {
                context.read<SettingsBloc>().add(const StopTracking());
              },
            );
            context.read<SettingsBloc>().add(const ResetSettingsAction());
            break;
        }
      },
      builder: (context, state) {
        return ThemedStatusBar(
          theme: StatusBarTheme.system,
          child: Scaffold(
            body: Column(
              children: [
                // 主要內容 - 始終顯示
                Expanded(
                  child: SafeArea(
                    bottom: false,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        const _SettingsHeader(),
                        const SizedBox(height: 16),
                        // Garage Pro
                        SettingsSectionHeader(title: 'GARAGE PRO'),
                        SettingsItem(
                          title: 'Garage Pro',
                          icon: state.isPro
                              ? Icons.verified
                              : Icons.star_outline,
                          iconColor: AppTheme.accentColor,
                          subtitle: state.isPro ? 'Pro 功能已全數解鎖' : '解鎖雲端同步與進階統計',
                          trailing: state.isPro
                              ? const Text(
                                  '已啟用',
                                  style: TextStyle(
                                    color: AppTheme.accentColor,
                                    fontSize: 12,
                                  ),
                                )
                              : null,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PremiumPage(),
                              ),
                            );
                          },
                        ),

                        // 一般設定
                        SettingsSectionHeader(title: 'settings.general'.tr()),
                        if (!state.isPro)
                          SettingsItem(
                            title: 'settings.adManagement'.tr(),
                            icon: Icons.card_giftcard,
                            subtitle: 'settings.adManagementDesc'.tr(),
                            onTap: () {
                              _showAdManagementDialog(context);
                            },
                          ),
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
                          onTap: () {
                            context.goPath(AppPath.termsOfService);
                          },
                        ),
                        SettingsItem(
                          title: 'settings.privacyPolicy'.tr(),
                          icon: Icons.privacy_tip_outlined,
                          onTap: () {
                            context.goPath(AppPath.privacyPolicy);
                          },
                        ),
                        SettingsItem(
                          title: 'settings.openSourceLicenses'.tr(),
                          icon: Icons.source_outlined,
                          onTap: () {
                            context.goPath(AppPath.openSourceLicenses);
                          },
                        ),
                        SettingsItem(
                          title: 'settings.feedback'.tr(),
                          icon: Icons.feedback_outlined,
                          onTap: () {
                            context.read<SettingsBloc>().add(
                              const SendFeedback(),
                            );
                          },
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
                ),
                // 固定在底部的廣告
                const SafeArea(top: false, child: BannerAdWidget()),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAdManagementDialog(BuildContext context) {
    final settingsBloc = context.read<SettingsBloc>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => BlocProvider.value(
        value: settingsBloc,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(modalContext).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'settings.adRewards'.tr(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.confirmation_number_outlined),
                  title: Text('settings.earnAdTicket'.tr()),
                  subtitle: Text('settings.earnAdTicketDesc'.tr()),
                  trailing: const Icon(Icons.play_circle_outline),
                  onTap: () {
                    Navigator.pop(modalContext);
                    settingsBloc.add(const WatchAdForTicket());
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.remove_circle_outline),
                  title: Text('settings.removeBanner'.tr()),
                  subtitle: Text('settings.removeBannerDesc'.tr()),
                  trailing: const Icon(Icons.play_circle_outline),
                  onTap: () {
                    Navigator.pop(modalContext);
                    settingsBloc.add(const WatchAdForBannerRemoval());
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.whiteTransparent05,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: state.isPro
                        ? AppTheme.accentColor
                        : AppTheme.whiteTransparent15,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    state.isPro ? Icons.star : Icons.person_outline,
                    size: 40,
                    color: state.isPro
                        ? AppTheme.accentColor
                        : AppTheme.systemGray,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'My Garage',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (state.isPro) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppTheme.accentColor),
                      ),
                      child: const Text(
                        'PRO',
                        style: TextStyle(
                          color: AppTheme.accentColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
