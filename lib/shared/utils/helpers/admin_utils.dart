import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:gsecsurvey/features/home/data/models/question_model.dart';
import 'package:gsecsurvey/shared/data/services/firestore_service.dart';

/// Utility functions for admin screens
class AdminUtils {
  /// Shows a snackbar with the given message
  static void showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  /// Shows a confirmation dialog and returns true if confirmed
  static Future<bool> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Delete',
    String cancelText = 'Cancel',
    Color? confirmColor,
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
                    backgroundColor: confirmColor ?? theme.colorScheme.error,
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
        ) ??
        false;
  }

  /// Deletes a question and shows appropriate snackbar messages
  static Future<void> deleteQuestion(
      BuildContext context, Question question) async {
    // Show confirmation dialog
    final shouldDelete = await showConfirmationDialog(
      context: context,
      title: 'Confirm Deletion',
      content:
          'Are you sure you want to delete this question? This action cannot be undone.',
    );

    if (shouldDelete) {
      try {
        await FirestoreService.deleteQuestion(question);
        if (!context.mounted) return;
        showSnackBar(context, 'Question deleted successfully');
      } catch (e) {
        if (!context.mounted) return;
        showSnackBar(context, 'Error deleting question: $e', isError: true);
      }
    }
  }

  /// Sorts questions by their order (number before first '-' in ID)
  static List<Question> sortQuestionsByOrder(List<Question> questions) {
    questions.sort((a, b) {
      final aOrder = int.tryParse(a.id.split('-').first) ?? 0;
      final bOrder = int.tryParse(b.id.split('-').first) ?? 0;
      return aOrder.compareTo(bOrder);
    });
    return questions;
  }
}
