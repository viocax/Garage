import 'package:flutter/material.dart';
import 'package:garage/theme/themed_status_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return ThemedStatusBar(
          theme: StatusBarTheme.system,
          child: Scaffold(
            body: Stack(
              children: [
                // 主要內容 - 始終顯示
                SafeArea(
                  child: CustomScrollView(
                    slivers: [
                      SliverList(
                        delegate: SliverChildListDelegate([
                          // 一般設定
                          const SettingsSectionHeader(title: '一般'),
                          SettingsItem(
                            title: '測速設置',
                            icon: Icons.radar_outlined,
                            onTap: () {
                              if (state is SettingsLoaded) {
                                context.goNamed(
                                  AppPath.speedDetectionSettings.name,
                                );
                              }
                            },
                          ),

                          // 資料管理
                          const SettingsSectionHeader(title: '資料'),
                          SettingsItem(
                            title: '匯出資料',
                            icon: Icons.upload_file_outlined,
                            onTap: () {
                              if (state is SettingsLoaded) {
                                context.read<SettingsBloc>().add(
                                  const ExportData(),
                                );
                              }
                            },
                          ),
                          SettingsItem(
                            title: '清除資料',
                            icon: Icons.delete_outline,
                            isDestructive: true,
                            onTap: state is SettingsLoaded
                                ? () {
                                    context.read<SettingsBloc>().add(
                                      const ClearData(),
                                    );
                                  }
                                : null,
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
                        ]),
                      ),
                    ],
                  ),
                ),

                // Loading HUD - 只在未載入時顯示
                if (state is SettingsInitial)
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
}
