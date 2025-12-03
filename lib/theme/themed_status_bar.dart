import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum StatusBarTheme { light, dark, system }

/// A wrapper widget for AnnotatedRegion that automatically handles
/// SystemUiOverlayStyle based on the specified theme mode.
class ThemedStatusBar extends StatelessWidget {
  final Widget child;
  final StatusBarTheme theme;

  const ThemedStatusBar({
    super.key,
    required this.child,
    this.theme = StatusBarTheme.system,
  });

  @override
  Widget build(BuildContext context) {
    final SystemUiOverlayStyle style;

    switch (theme) {
      case StatusBarTheme.light:
        style = SystemUiOverlayStyle.light;
        break;
      case StatusBarTheme.dark:
        style = SystemUiOverlayStyle.dark;
        break;
      case StatusBarTheme.system:
        // Follow system/app theme
        final brightness = Theme.of(context).brightness;
        style = brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark;
        break;
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: style.copyWith(statusBarColor: Colors.transparent),
      child: child,
    );
  }
}
