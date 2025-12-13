import 'package:flutter/material.dart';

/// 設置頁面的開關項目，帶有 Switch 控件
class SettingsToggleItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;
  final bool value;
  final VoidCallback? onTap;

  const SettingsToggleItem({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
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
          trailing: Switch(
            value: value,
            onChanged: onTap != null ? (_) => onTap!() : null,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
