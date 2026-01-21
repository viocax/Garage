import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/core/core.dart';
import 'package:garage/screen/settings/widgets/settings_section_header.dart';
import 'package:garage/theme/theme.dart';
import 'package:garage/router/app_router.dart';
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

    return BlocConsumer<CloudSyncBloc, CloudSyncState>(
      listener: (context, state) {
        if (state is CloudSyncLoaded &&
            state.toastMessage != null &&
            !state.isSyncing) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.toastMessage!)),
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
                  _buildLoadingOverlay(context, state.toastMessage),
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
                SettingsSectionHeader(
                  title: 'cloudSync.service'.tr(),
                ),
                _buildProviderTile(
                  context,
                  state.status,
                ),
                const SizedBox(height: 16),
                SettingsSectionHeader(title: 'cloudSync.syncOperations'.tr()),
                _buildSyncActions(context, state),
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
            onPressed: () => context.safePop(),
            icon: Icon(Icons.arrow_back_ios, color: theme.colorScheme.primary),
          ),
          Text(
            'cloudSync.title'.tr(),
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
    ProviderStatus status, 
  ) {
    final theme = Theme.of(context);
    final isAvailable = status.isAvailable;

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
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ))
              : Text(
                  'cloudSync.notSupported'.tr(),
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
                      SignOutProvider(status.provider),
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
        'cloudSync.lastSync'.tr(args: [_formatDateTime(status.lastSyncTime!)]),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      );
    }
    if (!status.isAuthenticated) {
      return Text(
        'cloudSync.tapToLogin'.tr(),
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
            title: 'cloudSync.uploadToCloud'.tr(),
            subtitle: 'cloudSync.uploadDesc'.tr(),
            onTap: () {
              context.read<CloudSyncBloc>().add(const UploadToCloud());
            },
          ),
          const SizedBox(height: 8),
          _buildActionTile(
            context,
            icon: Icons.cloud_download_outlined,
            title: 'cloudSync.restoreFromCloud'.tr(),
            subtitle: 'cloudSync.restoreDesc'.tr(),
            isDestructive: true,
            onTap: () {
              _showRestoreConfirmation(context);
            },
          ),
          const SizedBox(height: 8),
          _buildActionTile(
            context,
            icon: Icons.delete_outline,
            title: 'cloudSync.clearLocalData'.tr(),
            subtitle: 'cloudSync.clearLocalDesc'.tr(),
            isDestructive: true,
            onTap: () {
              _showClearLocalConfirmation(context);
            },
          ),
          const SizedBox(height: 8),
          _buildActionTile(
            context,
            icon: Icons.cloud_off_outlined,
            title: 'cloudSync.deleteCloudBackup'.tr(),
            subtitle: 'cloudSync.deleteCloudDesc'.tr(),
            isDestructive: true,
            onTap: () {
              _showDeleteBackupConfirmation(context);
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
    final color = isDestructive
        ? theme.colorScheme.error
        : theme.colorScheme.primary;

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
          trailing: Icon(Icons.chevron_right, color: AppTheme.systemGray),
          onTap: onTap,
        ),
      ),
    );
  }

  void _showRestoreConfirmation(BuildContext context) async {
    final confirmed = await context.showAdaptiveConfirmDialog(
      title: 'cloudSync.confirmRestore'.tr(),
      message: 'cloudSync.restoreWarning'.tr(),
      cancelText: 'common.cancel'.tr(),
      confirmText: 'cloudSync.restore'.tr(),
      isDestructiveAction: true,
    );

    if (confirmed == true && context.mounted) {
      context.read<CloudSyncBloc>().add(const DownloadFromCloud());
    }
  }

  void _showClearLocalConfirmation(BuildContext context) async {
    final confirmed = await context.showAdaptiveConfirmDialog(
      title: 'cloudSync.confirmClear'.tr(),
      message: 'cloudSync.clearLocalWarning'.tr(),
      cancelText: 'common.cancel'.tr(),
      confirmText: 'cloudSync.clear'.tr(),
      isDestructiveAction: true,
    );

    if (confirmed == true && context.mounted) {
      context.read<CloudSyncBloc>().add(const ClearLocalData());
    }
  }

  void _showDeleteBackupConfirmation(BuildContext context) async {
    final confirmed = await context.showAdaptiveConfirmDialog(
      title: 'cloudSync.confirmDeleteBackup'.tr(),
      message: 'cloudSync.deleteBackupWarning'.tr(),
      cancelText: 'common.cancel'.tr(),
      confirmText: 'cloudSync.delete'.tr(),
      isDestructiveAction: true,
    );

    if (confirmed == true && context.mounted) {
      context.read<CloudSyncBloc>().add(const DeleteCloudBackup());
    }
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
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
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
