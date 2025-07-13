import 'package:flutter/material.dart';
import 'package:gsecsurvey/shared/presentation/widgets/common_dialogs.dart';

/// A reusable wrapper widget that provides swipe-to-delete functionality
/// for any child widget. Implements DRY methodology by centralizing
/// the swipe-to-delete logic that was previously duplicated.
class SwipeToDeleteWrapper extends StatelessWidget {
  /// The child widget to wrap with swipe-to-delete functionality
  final Widget child;

  /// Unique key for the Dismissible widget
  final Key dismissibleKey;

  /// Callback function to execute when item is confirmed for deletion
  final Future<void> Function() onDelete;

  /// Title for the delete confirmation dialog
  final String deleteDialogTitle;

  /// Content/message for the delete confirmation dialog
  final String deleteDialogContent;

  /// Optional callback to determine if dismissal should be disabled
  /// (e.g., when an item is expanded). Returns true to disable dismissal.
  final bool Function()? shouldDisableDismissal;

  /// Optional callback for when deletion is successful
  final VoidCallback? onDeleteSuccess;

  /// Optional callback for when deletion fails
  final void Function(String error)? onDeleteError;

  /// Success message to show after successful deletion
  final String? successMessage;

  const SwipeToDeleteWrapper({
    super.key,
    required this.child,
    required this.dismissibleKey,
    required this.onDelete,
    required this.deleteDialogTitle,
    required this.deleteDialogContent,
    this.shouldDisableDismissal,
    this.onDeleteSuccess,
    this.onDeleteError,
    this.successMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: dismissibleKey,
      dismissThresholds: shouldDisableDismissal?.call() == true
          ? const {
              DismissDirection.startToEnd: 1.0,
              DismissDirection.endToStart: 1.0
            }
          : const {},
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        // Disable dismissal if callback returns true
        if (shouldDisableDismissal?.call() == true) {
          return false;
        }

        // Show confirmation dialog
        return await CommonDialogs.showDeleteConfirmationDialog(
          context: context,
          title: deleteDialogTitle,
          content: deleteDialogContent,
        );
      },
      onDismissed: (direction) async {
        final scaffoldMessenger = ScaffoldMessenger.of(context);

        try {
          // Execute the delete operation
          await onDelete();

          // Show success message if provided
          if (successMessage != null) {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text(successMessage!),
                backgroundColor: Colors.green,
              ),
            );
          }

          // Call success callback if provided
          onDeleteSuccess?.call();
        } catch (e) {
          // Show error message
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Error during deletion: $e'),
              backgroundColor: Colors.red,
            ),
          );

          // Call error callback if provided
          onDeleteError?.call(e.toString());
        }
      },
      child: child,
    );
  }
}
