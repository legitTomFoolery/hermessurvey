import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

/// Common dialog utilities to maintain consistency across the app
class CommonDialogs {
  CommonDialogs._();

  /// Standard confirmation dialog for delete operations
  static Future<bool?> showDeleteConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Delete',
    String cancelText = 'Cancel',
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme = AdaptiveTheme.of(dialogContext).theme;
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              child: Text(confirmText),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.outline,
              ),
              child: Text(cancelText),
            ),
          ],
        );
      },
    );
  }

  /// Standard confirmation dialog for general actions
  static Future<bool?> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
    String cancelText = 'Cancel',
    Color? confirmButtonColor,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme = AdaptiveTheme.of(dialogContext).theme;
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    confirmButtonColor ?? theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: Text(confirmText),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.outline,
              ),
              child: Text(cancelText),
            ),
          ],
        );
      },
    );
  }

  /// Notification dialog with custom styling
  static Future<bool?> showNotificationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
    String cancelText = 'Cancel',
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme = AdaptiveTheme.of(dialogContext).theme;
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 8.0),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.tertiary,
                foregroundColor: theme.colorScheme.onTertiary,
              ),
              child: Text(confirmText),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.outline,
              ),
              child: Text(cancelText),
            ),
          ],
        );
      },
    );
  }
}
