import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:garage/theme/app_theme.dart';

/// 對話框擴展
///
/// 為 BuildContext 添加顯示平台適配對話框的便捷方法
/// 自動根據平台（iOS/Android）顯示對應風格的對話框
extension DialogExtension on BuildContext {
  /// 檢查當前平台是否為 iOS
  bool get _isIOS => Theme.of(this).platform == TargetPlatform.iOS;

  /// 顯示平台適配的權限提示對話框
  ///
  /// iOS: 使用 CupertinoAlertDialog
  /// Android: 使用 Material AlertDialog
  void showAdaptivePermissionAlert({
    required String title,
    required String message,
    required String cancelText,
    required String confirmText,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    if (_isIOS) {
      _showIOSPermissionAlert(
        title: title,
        message: message,
        cancelText: cancelText,
        confirmText: confirmText,
        onConfirm: onConfirm,
        onCancel: onCancel,
      );
    } else {
      _showMaterialPermissionAlert(
        title: title,
        message: message,
        cancelText: cancelText,
        confirmText: confirmText,
        onConfirm: onConfirm,
        onCancel: onCancel,
      );
    }
  }

  /// iOS 風格的權限提示對話框
  void _showIOSPermissionAlert({
    required String title,
    required String message,
    required String cancelText,
    required String confirmText,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    showCupertinoDialog(
      context: this,
      barrierDismissible: false,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(dialogContext);
              onCancel?.call();
            },
            child: Text(cancelText),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(dialogContext);
              onConfirm();
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Material 風格的權限提示對話框
  void _showMaterialPermissionAlert({
    required String title,
    required String message,
    required String cancelText,
    required String confirmText,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onCancel?.call();
            },
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onConfirm();
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// 顯示平台適配的確認對話框
  ///
  /// iOS: 使用 CupertinoAlertDialog
  /// Android: 使用 Material AlertDialog
  Future<bool?> showAdaptiveConfirmDialog({
    required String title,
    String? message,
    String? cancelText,
    String? confirmText,
    bool isDestructiveAction = false,
  }) {
    final effectiveCancelText = cancelText ?? 'common.cancel'.tr();
    final effectiveConfirmText = confirmText ?? 'common.confirm'.tr();
    if (_isIOS) {
      return _showIOSConfirmDialog(
        title: title,
        message: message,
        cancelText: effectiveCancelText,
        confirmText: effectiveConfirmText,
        isDestructiveAction: isDestructiveAction,
      );
    } else {
      return _showMaterialConfirmDialog(
        title: title,
        message: message,
        cancelText: effectiveCancelText,
        confirmText: effectiveConfirmText,
        isDestructiveAction: isDestructiveAction,
      );
    }
  }

  /// iOS 風格的確認對話框
  Future<bool?> _showIOSConfirmDialog({
    required String title,
    String? message,
    required String cancelText,
    required String confirmText,
    required bool isDestructiveAction,
  }) {
    return showCupertinoDialog<bool>(
      context: this,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(title),
        content: message != null ? Text(message) : null,
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: Text(cancelText),
          ),
          CupertinoDialogAction(
            isDefaultAction: !isDestructiveAction,
            isDestructiveAction: isDestructiveAction,
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Material 風格的確認對話框
  Future<bool?> _showMaterialConfirmDialog({
    required String title,
    String? message,
    required String cancelText,
    required String confirmText,
    required bool isDestructiveAction,
  }) {
    return showDialog<bool>(
      context: this,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: message != null ? Text(message) : null,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: Text(
              confirmText,
              style: isDestructiveAction
                  ? const TextStyle(color: AppTheme.systemRed)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
