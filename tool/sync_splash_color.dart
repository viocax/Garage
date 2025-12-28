#!/usr/bin/env dart
/// Syncs splash screen color from AppTheme.dashboardBg to native platforms.
///
/// Usage: dart run tool/sync_splash_color.dart
///
/// This script reads the dashboardBg color from lib/theme/app_theme.dart
/// and updates:
/// - iOS: LaunchScreen.storyboard background color
/// - Android: launch_background.xml, styles.xml (all variants)

import 'dart:io';

void main() async {
  print('🎨 Syncing splash screen color from AppTheme...\n');

  // 1. Read color from AppTheme
  final color = await _readColorFromAppTheme();
  if (color == null) {
    print('❌ Failed to read dashboardBg color from AppTheme');
    exit(1);
  }

  print('📖 Found dashboardBg: #${color.toRadixString(16).padLeft(6, '0').toUpperCase()}');

  // 2. Update iOS
  await _updateiOS(color);

  // 3. Update Android
  await _updateAndroid(color);

  print('\n✅ Splash color sync complete!');
}

/// Reads dashboardBg color from AppTheme.dart
Future<int?> _readColorFromAppTheme() async {
  final file = File('lib/theme/app_theme.dart');
  if (!await file.exists()) {
    print('❌ AppTheme file not found: ${file.path}');
    return null;
  }

  final content = await file.readAsString();

  // Try pattern 1: Color(0xFF0A0A0A)
  final hexRegex = RegExp(r'dashboardBg\s*=\s*Color\(\s*0x([0-9A-Fa-f]{8})\s*\)');
  final hexMatch = hexRegex.firstMatch(content);
  if (hexMatch != null) {
    final hexColor = hexMatch.group(1)!;
    return int.parse(hexColor.substring(2), radix: 16); // Remove FF alpha prefix
  }

  // Try pattern 2: Color.fromRGBO(r, g, b, opacity)
  final rgboRegex = RegExp(r'dashboardBg\s*=\s*Color\.fromRGBO\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,');
  final rgboMatch = rgboRegex.firstMatch(content);
  if (rgboMatch != null) {
    final r = int.parse(rgboMatch.group(1)!);
    final g = int.parse(rgboMatch.group(2)!);
    final b = int.parse(rgboMatch.group(3)!);
    return (r << 16) | (g << 8) | b;
  }

  // Try pattern 3: Colors.xxx (named colors)
  final namedRegex = RegExp(r'dashboardBg\s*=\s*Colors\.(\w+)');
  final namedMatch = namedRegex.firstMatch(content);
  if (namedMatch != null) {
    final colorName = namedMatch.group(1)!.toLowerCase();
    final namedColor = _namedColors[colorName];
    if (namedColor != null) {
      return namedColor;
    }
    print('⚠️  Unknown named color: Colors.$colorName');
  }

  print('❌ Could not find dashboardBg color definition');
  print('   Supported formats:');
  print('   - Color(0xFF0A0A0A)');
  print('   - Color.fromRGBO(r, g, b, opacity)');
  print('   - Colors.xxx (common named colors)');
  return null;
}

/// Common Flutter named colors
const _namedColors = <String, int>{
  'black': 0x000000,
  'white': 0xFFFFFF,
  'red': 0xF44336,
  'pink': 0xE91E63,
  'purple': 0x9C27B0,
  'deepPurple': 0x673AB7,
  'indigo': 0x3F51B5,
  'blue': 0x2196F3,
  'lightBlue': 0x03A9F4,
  'cyan': 0x00BCD4,
  'teal': 0x009688,
  'green': 0x4CAF50,
  'lightGreen': 0x8BC34A,
  'lime': 0xCDDC39,
  'yellow': 0xFFEB3B,
  'amber': 0xFFC107,
  'orange': 0xFF9800,
  'deepOrange': 0xFF5722,
  'brown': 0x795548,
  'grey': 0x9E9E9E,
  'blueGrey': 0x607D8B,
  'transparent': 0x000000,
};

/// Updates iOS LaunchScreen.storyboard
Future<void> _updateiOS(int color) async {
  final file = File('ios/Runner/Base.lproj/LaunchScreen.storyboard');
  if (!await file.exists()) {
    print('⚠️  iOS LaunchScreen.storyboard not found, skipping...');
    return;
  }

  final r = ((color >> 16) & 0xFF) / 255.0;
  final g = ((color >> 8) & 0xFF) / 255.0;
  final b = (color & 0xFF) / 255.0;

  var content = await file.readAsString();

  // Update background color in storyboard
  final colorRegex = RegExp(
    r'<color key="backgroundColor"[^/]*/?>',
    multiLine: true,
  );

  final newColor =
      '<color key="backgroundColor" red="$r" green="$g" blue="$b" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>';

  content = content.replaceAll(colorRegex, newColor);

  await file.writeAsString(content);
  print('✅ Updated iOS LaunchScreen.storyboard');
}

/// Updates Android splash screen files
Future<void> _updateAndroid(int color) async {
  final hexColor = '#${color.toRadixString(16).padLeft(6, '0').toUpperCase()}';

  // Update colors.xml (create if needed)
  await _updateAndroidColors(hexColor);

  // Update launch_background.xml files
  await _updateAndroidLaunchBackground('android/app/src/main/res/drawable/launch_background.xml');
  await _updateAndroidLaunchBackground('android/app/src/main/res/drawable-v21/launch_background.xml');

  // Update styles.xml files
  await _updateAndroidStyles('android/app/src/main/res/values/styles.xml', hexColor, isNight: false);
  await _updateAndroidStyles('android/app/src/main/res/values-night/styles.xml', hexColor, isNight: true);

  // Update Android 12+ styles
  await _updateAndroid12Styles('android/app/src/main/res/values-v31/styles.xml', hexColor, isNight: false);
  await _updateAndroid12Styles('android/app/src/main/res/values-night-v31/styles.xml', hexColor, isNight: true);
}

/// Creates/updates Android colors.xml
Future<void> _updateAndroidColors(String hexColor) async {
  final file = File('android/app/src/main/res/values/colors.xml');

  final content = '''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Synced from AppTheme.dashboardBg -->
    <color name="splash_background">$hexColor</color>
</resources>
''';

  await file.writeAsString(content);
  print('✅ Updated Android colors.xml');
}

/// Updates Android launch_background.xml
Future<void> _updateAndroidLaunchBackground(String path) async {
  final file = File(path);

  final content = '''<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@color/splash_background" />
</layer-list>
''';

  await file.writeAsString(content);
  print('✅ Updated $path');
}

/// Updates Android styles.xml
Future<void> _updateAndroidStyles(String path, String hexColor, {required bool isNight}) async {
  final file = File(path);
  final parentTheme = isNight ? 'Theme.Black.NoTitleBar' : 'Theme.Black.NoTitleBar';

  final content = '''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="LaunchTheme" parent="@android:style/$parentTheme">
        <item name="android:windowBackground">@drawable/launch_background</item>
    </style>
    <style name="NormalTheme" parent="@android:style/$parentTheme">
        <item name="android:windowBackground">@color/splash_background</item>
    </style>
</resources>
''';

  await file.writeAsString(content);
  print('✅ Updated $path');
}

/// Updates Android 12+ styles.xml
Future<void> _updateAndroid12Styles(String path, String hexColor, {required bool isNight}) async {
  final file = File(path);
  if (!await file.exists()) {
    // Create directory if needed
    await file.parent.create(recursive: true);
  }

  final parentTheme = isNight ? 'Theme.Black.NoTitleBar' : 'Theme.Light.NoTitleBar';

  final content = '''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="LaunchTheme" parent="@android:style/$parentTheme">
        <item name="android:windowSplashScreenBackground">$hexColor</item>
    </style>
    <style name="NormalTheme" parent="@android:style/$parentTheme">
        <item name="android:windowBackground">@color/splash_background</item>
    </style>
</resources>
''';

  await file.writeAsString(content);
  print('✅ Updated $path');
}
