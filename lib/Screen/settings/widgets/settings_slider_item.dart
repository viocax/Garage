import 'package:flutter/material.dart';
import 'package:garage/theme/app_theme.dart';

/// 設置頁面的滑桿項目，用於調整數值
class SettingsSliderItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final double value;
  final ValueChanged<double> onChanged;

  const SettingsSliderItem({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(value * 100).toInt()}%',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.systemGray,
                  ),
                ),
              ],
            ),
            Slider(
              value: value,
              onChanged: onChanged,
              activeColor: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
