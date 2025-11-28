import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/screen/settings/settings_page.dart';
import 'package:garage/core/core.dart';
import 'package:garage/screen/records/records_page.dart';
import 'package:garage/screen/speed/speedCamera/speed_camera_page.dart';
import 'package:go_router/go_router.dart';
import 'package:garage/screen/app/home/garage_home_page.dart';
import 'package:garage/screen/app/launch/launch_page.dart';

/// 應用程式的路由配置
class AppRouter {
  /// 路由路徑
  static const String launch = '/';
  static const String home = 'home';
  static const String speedometer = '/speedometer';
  static const String records = '/records';
  static const String settings = '/settings';

  /// 建立並返回 GoRouter 實例
  static GoRouter createRouter() {
    return GoRouter(
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
                    create: (context) => getIt.bloc.car3d,
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
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
