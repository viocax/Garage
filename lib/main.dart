import 'package:flutter/material.dart';
import 'package:garage/screen/app/garage_app.dart';
import 'package:garage/core/core.dart';

import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 設定只能直屏
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // 初始化依賴注入
  await setupServiceLocator();

  runApp(const GarageApp());
}
