import 'package:flutter/material.dart';
import 'package:garage/theme/app_theme.dart';

/// 設置頁面的基本項目，帶有圖標、標題和箭頭
class SettingsItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;
  final bool isDestructive;
  final VoidCallback? onTap;

  const SettingsItem({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
    this.isDestructive = false,
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
          leading: Icon(
            icon,
            color: isDestructive
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
          ),
          title: Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDestructive
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
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
          trailing: const Icon(Icons.chevron_right, color: AppTheme.systemGray),
          onTap: onTap ?? () {},
        ),
      ),
    );
  }
}
