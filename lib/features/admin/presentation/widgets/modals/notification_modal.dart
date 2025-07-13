import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

import 'package:gsecsurvey/shared/data/services/notification_service.dart';
import 'package:gsecsurvey/shared/presentation/widgets/app_text_form_field.dart';

class NotificationModal extends StatefulWidget {
  const NotificationModal({super.key});

  @override
  State<NotificationModal> createState() => _NotificationModalState();
}

class _NotificationModalState extends State<NotificationModal> {
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;
  DateTime? _lastNotificationTime;

  static const String defaultMessage =
      "GSEC Survey - This is a reminder to complete your feedback using the feedback evaluation tool.";

  @override
  void initState() {
    super.initState();
    _loadLastNotificationTime();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadLastNotificationTime() async {
    try {
      final lastTime = await NotificationService.getLastNotificationTime();
      setState(() {
        _lastNotificationTime = lastTime;
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading last notification time: $e');
      }
    }
  }

  Future<void> _sendNotification() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final message = _messageController.text.trim().isEmpty
          ? defaultMessage
          : _messageController.text.trim();

      final success = await NotificationService.sendCustomNotification(
        title: 'GSEC Survey',
        body: message,
      );

      if (mounted) {
        final theme = AdaptiveTheme.of(context).theme;
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Notification sent successfully!'),
              backgroundColor: theme.colorScheme.inversePrimary,
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  const Text('Failed to send notification. Please try again.'),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final theme = AdaptiveTheme.of(context).theme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatLastNotificationTime() {
    if (_lastNotificationTime == null) {
      return 'No notifications sent yet';
    }

    final now = DateTime.now();
    final difference = now.difference(_lastNotificationTime!);

    if (difference.inDays > 0) {
      return 'Last sent ${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return 'Last sent ${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return 'Last sent ${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Last sent just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;

    return AlertDialog(
      title: const Text('Send Custom Notification'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Last notification info
              Text(
                _formatLastNotificationTime(),
                style: TextStyle(
                    fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),

              // Web platform warning
              if (kIsWeb)
                Text(
                  'Web Platform: Push notifications are intended for mobile devices. This will not send push notifications to users.',
                  style: TextStyle(
                      fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                ),
              if (kIsWeb) const SizedBox(height: 12),

              // Message input using AppTextFormField for DRY methodology
              AppTextFormField(
                controller: _messageController,
                hint: 'Enter custom message or leave blank for default',
                validator: (value) =>
                    null, // No validation needed for this field
              ),
              const SizedBox(height: 8),

              // Helper text showing default message
              Text(
                'Default: $defaultMessage',
                style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
      actions: [
        // Send button (matching export modal style)
        TextButton.icon(
          onPressed: _isLoading ? null : _sendNotification,
          style: TextButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          icon: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.onPrimary,
                    ),
                  ),
                )
              : Icon(Icons.send, color: theme.colorScheme.onPrimary),
          label: Text(
            _isLoading ? 'Sending...' : 'Send',
            style: TextStyle(color: theme.colorScheme.onPrimary),
          ),
        ),
        // Cancel button (matching export modal style)
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurfaceVariant,
          ),
          child: Text(
            'Cancel',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
