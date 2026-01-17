import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/models/speed_unit.dart';
import 'package:garage/screen/speed/speedCamera/widgets/interval_info_widget.dart';
import 'package:garage/theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createWidgetUnderTest(Widget child) {
    return EasyLocalization(
      supportedLocales: const [Locale('zh', 'TW'), Locale('en', 'US')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      child: Builder(
        builder: (context) {
          return MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: child,
            ),
          );
        },
      ),
    );
  }

  group('IntervalInfoWidget', () {
    testWidgets('應該顯示基本的區間測速資訊', (WidgetTester tester) async {
      // 由於 Widget 測試中 EasyLocalization 初始化較複雜，這裡我們驗證內容是否正確顯示
      // 我們不直接測試翻譯後的字串，而是測試傳入的數值
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IntervalInfoWidget(
              averageSpeed: 65.5,
              remainingDistance: 1200.0,
              speedLimit: 60,
              unit: SpeedUnit.kmh,
              isOverSpeed: true,
            ),
          ),
        ),
      );

      // 驗證平均速度顯示 (round 到 66)
      expect(find.text('66'), findsOneWidget);
      expect(find.text('km/h'), findsOneWidget);

      // 驗證速限顯示
      expect(find.text('60'), findsOneWidget);

      // 驗證剩餘距離顯示 (1.2km)
      expect(find.text('1.2km'), findsOneWidget);
    });

    testWidgets('超速時應顯示 AppTheme.dashboardAccentRed 背景', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IntervalInfoWidget(
              averageSpeed: 70.0,
              remainingDistance: 500.0,
              speedLimit: 60,
              unit: SpeedUnit.kmh,
              isOverSpeed: true,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(
        decoration.color, 
        equals(AppTheme.dashboardAccentRed.withOpacity(0.3)),
      );
    });

    testWidgets('未超速時應顯示黑色透明背景', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IntervalInfoWidget(
              averageSpeed: 50.0,
              remainingDistance: 500.0,
              speedLimit: 60,
              unit: SpeedUnit.kmh,
              isOverSpeed: false,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(AppTheme.blackTransparent30));
    });
  });
}