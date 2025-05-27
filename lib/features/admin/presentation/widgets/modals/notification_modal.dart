import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

import 'package:gsecsurvey/app/config/app_constants.dart';
import 'package:gsecsurvey/shared/data/services/notification_service.dart';

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
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification sent successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to send notification. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
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

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: theme.colorScheme.surface,
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.notifications_active,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Send Custom Notification',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.defaultPadding),

              // Last notification info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _formatLastNotificationTime(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Web platform warning
              if (kIsWeb)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_outlined,
                        size: 20,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Web Platform: Push notifications work best on mobile devices. This will store the notification but may not send push notifications to users.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (kIsWeb) const SizedBox(height: 16),

              // Message input
              Text(
                'Notification Message',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: defaultMessage,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 16),

              // Action buttons with proper order and styling
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 12,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _sendNotification,
                    icon: _isLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.onTertiary,
                              ),
                            ),
                          )
                        : const Icon(Icons.send),
                    label: Text(_isLoading ? 'Sending...' : 'Send'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.tertiary,
                      foregroundColor: theme.colorScheme.onTertiary,
                    ),
                  ),
                  TextButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.outline,
                    ),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
