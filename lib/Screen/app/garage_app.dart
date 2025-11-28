import 'package:flutter/material.dart';
import 'package:garage/router/app_router.dart';
import 'package:garage/theme/app_theme.dart';

class GarageApp extends StatelessWidget {
  const GarageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '愛車管家',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.createRouter(),
    );
  }
}
