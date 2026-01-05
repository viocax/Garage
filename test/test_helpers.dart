import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// 初始化 EasyLocalization 用於測試
///
/// 在測試的 setUpAll 中調用此函數來初始化本地化
///
/// 範例：
/// ```dart
/// void main() {
///   setUpAll(() async {
///     await initializeLocalization();
///   });
///
///   testLocalized('my test', (tester) async {
///     // 可以在這裡使用 .tr() 方法
///   });
/// }
/// ```
Future<void> initializeLocalization() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock SharedPreferences for EasyLocalization
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/shared_preferences'),
    (MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return <String, dynamic>{}; // Return empty prefs
      }
      return null;
    },
  );

  await EasyLocalization.ensureInitialized();
}

/// 創建一個提供本地化上下文的測試
///
/// 用於需要使用 .tr() 方法的測試
///
/// 範例：
/// ```dart
/// testLocalized('should translate correctly', (tester) async {
///   expect(FuelType.octane92.label, '92');
/// });
/// ```
void testLocalized(
  String description,
  Future<void> Function(WidgetTester) callback, {
  bool skip = false,
}) {
  testWidgets(description, (tester) async {
    final widget = EasyLocalization(
      supportedLocales: const [Locale('zh')],
      path: 'test/assets/translations',
      fallbackLocale: const Locale('zh'),
      useOnlyLangCode: true,
      assetLoader: _TestJsonAssetLoader(),
      child: Builder(
        builder: (context) {
          return MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: const Scaffold(),
          );
        },
      ),
    );

    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    // 等待翻译数据加载
    await tester.pump(const Duration(milliseconds: 100));

    await callback(tester);
  }, skip: skip);
}

/// 測試用的簡單 JSON AssetLoader
class _TestJsonAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async {
    // 直接返回測試翻譯數據
    return {
      'fuelType': {
        'octane92': '92',
        'octane95': '95',
        'octane98': '98',
        'diesel': '柴油',
        'unleadedFormat': '無鉛{}',
      },
      'recordType': {
        'fuel': '加油',
        'maintenance': '保養',
        'other': '其他',
      },
      'addRecord': {
        'invalidFuelAmount': '請輸入有效的加油量',
        'atLeastOneMaintenanceItem': '請至少輸入一個保養項目',
      },
    };
  }
}

/// 包裝 widget 並提供 EasyLocalization 上下文
///
/// 用於 widget 測試，提供完整的本地化環境
Widget wrapWithLocalization(Widget child) {
  return EasyLocalization(
    supportedLocales: const [
      Locale('zh', 'TW'),
      Locale('en', 'US'),
    ],
    path: 'assets/translations',
    fallbackLocale: const Locale('zh', 'TW'),
    child: MaterialApp(
      locale: const Locale('zh', 'TW'),
      supportedLocales: const [
        Locale('zh', 'TW'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [],
      home: Scaffold(body: child),
    ),
  );
}
