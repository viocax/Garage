import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: Text(
                '設定',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: theme.scaffoldBackgroundColor,
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader(context, '一般'),
                _buildSettingsItem(
                  context,
                  '愛車資訊',
                  Icons.directions_car_outlined,
                ),
                _buildSettingsItem(context, '主題設定', Icons.palette_outlined),

                _buildSectionHeader(context, '測速提醒'),
                _buildSettingsItem(context, '警示距離', Icons.add_road),
                _buildSettingsItem(context, '警示音效', Icons.volume_up_outlined),

                _buildSectionHeader(context, '資料'),
                _buildSettingsItem(context, '匯出資料', Icons.upload_file_outlined),
                _buildSettingsItem(
                  context,
                  '清除資料',
                  Icons.delete_outline,
                  isDestructive: true,
                ),

                const SizedBox(height: 40),
                Center(
                  child: Text(
                    'Garage v1.0.0',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    String title,
    IconData icon, {
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
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
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
}
