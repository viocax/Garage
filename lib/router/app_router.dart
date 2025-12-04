import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/screen/settings/settings_page.dart';
import 'package:garage/screen/settings/speed_detection_settings_page.dart';
import 'package:garage/core/core.dart';
import 'package:garage/screen/records/records_page.dart';
import 'package:garage/screen/speed/speedCamera/speed_camera_page.dart';
import 'package:go_router/go_router.dart';
import 'package:garage/screen/app/home/garage_home_page.dart';
import 'package:garage/screen/app/launch/launch_page.dart';

/// 應用程式的路由配置
class AppRouter {
  /// Root navigator key - 用於全屏路由
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  /// 路由路徑
  static const String launch = '/';
  static const String home = 'home';
  static const String speedometer = '/speedometer';
  static const String records = '/records';
  static const String settings = '/settings';
  static const String speedDetectionSettings = '$settings/speed-detection';

  /// 建立並返回 GoRouter 實例
  static GoRouter createRouter() {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: launch,
      routes: [
        GoRoute(
          path: launch,
          name: 'launch',
          builder: (context, state) => const LaunchPage(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) {
            return BlocProvider(
              create: (context) => getIt.bloc.home,
              child: GarageHomePage(shell: shell),
            );
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: speedometer,
                  name: 'speedometer',
                  builder: (context, state) => BlocProvider(
                    create: (context) => getIt.bloc.speed,
                    child: const SpeedCameraPage(),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: records,
                  name: 'records',
                  builder: (context, state) => BlocProvider(
                    create: (context) => getIt.bloc.records,
                    child: const RecordsPage(),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: settings,
                  name: 'settings',
                  builder: (context, state) => BlocProvider(
                    create: (context) => getIt.bloc.settings,
                    child: const SettingsPage(),
                  ),
                  routes: [
                    GoRoute(
                      path: 'speed-detection',
                      name: 'speedDetectionSettings',
                      // 使用 root navigator，跳過 shell 直接全屏顯示
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) => BlocProvider(
                        create: (context) => getIt.bloc.settings,
                        child: const SpeedDetectionSettingsPage(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
