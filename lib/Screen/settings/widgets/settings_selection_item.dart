import 'package:flutter/material.dart';
import 'package:garage/theme/app_theme.dart';

/// 設置頁面的選擇項目，顯示當前選擇的值
class SettingsSelectionItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final String currentValue;
  final String? subtitle;
  final VoidCallback? onTap;

  const SettingsSelectionItem({
    super.key,
    required this.title,
    required this.icon,
    required this.currentValue,
    this.subtitle,
    this.onTap,
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
      child: Theme(
        data: theme.copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: ListTile(
          leading: Icon(icon, color: theme.colorScheme.primary),
          title: Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                currentValue,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.systemGray,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppTheme.systemGray),
            ],
          ),
          onTap: onTap ?? () {},
        ),
      ),
    );
  }
}
