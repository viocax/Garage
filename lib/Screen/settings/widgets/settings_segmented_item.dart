import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 設置項 - 分段選擇器（平台適配）
///
/// iOS: 使用 CupertinoSlidingSegmentedControl
/// Android: 使用 SegmentedButton
class SettingsSegmentedItem<T extends Object> extends StatelessWidget {
  final String title;
  final IconData icon;
  final T currentValue;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  const SettingsSegmentedItem({
    super.key,
    required this.title,
    required this.icon,
    required this.currentValue,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 標題行
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 分段控制器
          SizedBox(
            width: double.infinity,
            child: isIOS ? _buildIOSSegmentedControl() : _buildAndroidSegmentedButton(),
          ),
        ],
      ),
    );
  }

  /// iOS 風格的分段控制器
  Widget _buildIOSSegmentedControl() {
    return CupertinoSlidingSegmentedControl<T>(
      groupValue: currentValue,
      onValueChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
      children: Map.fromEntries(
        options.entries.map(
          (entry) => MapEntry(
            entry.key,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(entry.value),
            ),
          ),
        ),
      ),
    );
  }

  /// Android 風格的分段按鈕
  Widget _buildAndroidSegmentedButton() {
    return SegmentedButton<T>(
      segments: options.entries.map((entry) {
        return ButtonSegment<T>(
          value: entry.key,
          label: Text(entry.value),
        );
      }).toList(),
      selected: {currentValue},
      onSelectionChanged: (Set<T> newSelection) {
        if (newSelection.isNotEmpty) {
          onChanged(newSelection.first);
        }
      },
      showSelectedIcon: false,
    );
  }
}
