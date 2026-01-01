import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/core/core.dart';
import 'package:garage/screen/settings/widgets/settings_section_header.dart';
import 'package:garage/theme/theme.dart';
import 'bloc/cloud_sync_bloc.dart';
import 'bloc/cloud_sync_event.dart';
import 'bloc/cloud_sync_state.dart';

class CloudSyncPage extends StatelessWidget {
  const CloudSyncPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CloudSyncBloc(),
      child: const _CloudSyncBody(),
    );
  }
}

class _CloudSyncBody extends StatelessWidget {
  const _CloudSyncBody();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<CloudSyncBloc, CloudSyncState>(
      listener: (context, state) {
        if (state is CloudSyncLoaded && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return ThemedStatusBar(
          theme: StatusBarTheme.system,
          child: Scaffold(
            body: Stack(
              children: [
                _buildContent(context, state),
                if (state is CloudSyncLoaded && state.isSyncing)
                  _buildLoadingOverlay(context, state.syncMessage),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, CloudSyncState state) {
    if (state is CloudSyncInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is! CloudSyncLoaded) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: Column(
        children: [
          // Header with back button
          _buildHeader(context),
          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                const SettingsSectionHeader(title: '選擇雲端服務'),
                ...state.providers.map((status) => _buildProviderTile(
                      context,
                      status,
                      isSelected: state.selectedProvider == status.provider,
                    )),
                const SizedBox(height: 16),
                if (state.selectedProvider != null) ...[
                  const SettingsSectionHeader(title: '同步操作'),
                  _buildSyncActions(context, state),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back_ios,
              color: theme.colorScheme.primary,
            ),
          ),
          Text(
            '同步雲端',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderTile(
    BuildContext context,
    ProviderStatus status, {
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    final isAvailable = status.isAvailable;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: theme.colorScheme.primary, width: 2)
            : null,
      ),
      child: Theme(
        data: theme.copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: ListTile(
          leading: Icon(
            _getProviderIcon(status.provider),
            color: isAvailable
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          title: Text(
            status.provider.displayName,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isAvailable
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
          subtitle: _buildProviderSubtitle(context, status),
          trailing: isAvailable
              ? (status.isAuthenticated
                  ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                  : Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ))
              : Text(
                  '不支援',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ),
          enabled: isAvailable,
          onTap: isAvailable
              ? () {
                  if (!status.isAuthenticated) {
                    context.read<CloudSyncBloc>().add(
                          AuthenticateProvider(status.provider),
                        );
                  } else {
                    context.read<CloudSyncBloc>().add(
                          SelectProvider(status.provider),
                        );
                  }
                }
              : null,
        ),
      ),
    );
  }

  Widget? _buildProviderSubtitle(BuildContext context, ProviderStatus status) {
    final theme = Theme.of(context);

    if (!status.isAvailable) {
      return null;
    }
    if (status.isAuthenticated && status.lastSyncTime != null) {
      return Text(
        '上次同步：${_formatDateTime(status.lastSyncTime!)}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      );
    }
    if (!status.isAuthenticated) {
      return Text(
        '點擊登入',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      );
    }
    return null;
  }

  Widget _buildSyncActions(BuildContext context, CloudSyncLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildActionTile(
            context,
            icon: Icons.cloud_upload_outlined,
            title: '上傳到雲端',
            subtitle: '將本機資料備份到雲端',
            onTap: () {
              context.read<CloudSyncBloc>().add(const UploadToCloud());
            },
          ),
          const SizedBox(height: 8),
          _buildActionTile(
            context,
            icon: Icons.cloud_download_outlined,
            title: '從雲端還原',
            subtitle: '從雲端下載並覆蓋本機資料',
            isDestructive: true,
            onTap: () {
              _showRestoreConfirmation(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final color =
        isDestructive ? theme.colorScheme.error : theme.colorScheme.primary;

    return Container(
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
          leading: Icon(icon, color: color),
          title: Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(color: color),
          ),
          subtitle: Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: AppTheme.systemGray,
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  void _showRestoreConfirmation(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('確認還原'),
        content: const Text('從雲端還原將會覆蓋所有本機資料，此操作無法復原。確定要繼續嗎？'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CloudSyncBloc>().add(const DownloadFromCloud());
            },
            child: const Text('還原'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay(BuildContext context, String? message) {
    final theme = Theme.of(context);

    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getProviderIcon(CloudProvider provider) {
    switch (provider) {
      case CloudProvider.iCloud:
        return CupertinoIcons.cloud;
      case CloudProvider.googleDrive:
        return Icons.add_to_drive_outlined;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
