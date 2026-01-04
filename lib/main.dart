import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garage/core/core.dart';
import 'package:garage/screen/app/garage_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化多語系
  await EasyLocalization.ensureInitialized();

  // 設定只能直屏
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // 初始化依賴注入
  await setupServiceLocator();

  // 載入使用者設定
  await getIt.repo.userSettings.loadSettings();

  // 初始化年度訂閱服務
  await getIt.service.subscription.initialize();

  // 初始化廣告服務
  await getIt.service.ad.initialize();
  getIt.repo.appOpenAd.loadAd();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('zh', 'TW'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('zh', 'TW'),
      child: const GarageApp(),
    ),
  );
}
