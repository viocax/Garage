import 'package:flutter/material.dart';
import 'package:garage/screen/app/garage_app.dart';
import 'package:garage/core/core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化依賴注入
  await setupServiceLocator();

  runApp(const GarageApp());
}
