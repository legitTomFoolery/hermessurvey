import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gsecsurvey/features/home/data/models/question.dart';
import 'package:gsecsurvey/features/admin/data/services/admin_utils.dart';
import 'package:gsecsurvey/shared/data/services/firestore_service.dart';

class QuestionSaveUtils {
  static Future<void> saveQuestion({
    required BuildContext context,
    required bool isNewQuestion,
    required Question? originalQuestion,
    required TextEditingController orderController,
    required TextEditingController idController,
    required TextEditingController nameController,
    required TextEditingController typeController,
    required TextEditingController optionsController,
    required TextEditingController rotationDetailsController,
    required VoidCallback onSaveSuccess,
  }) async {
    // Validate required fields
    if (orderController.text.isEmpty ||
        idController.text.isEmpty ||
        nameController.text.isEmpty ||
        typeController.text.isEmpty) {
      AdminUtils.showSnackBar(
        context,
        'Order, ID, Question Text, and Type are required',
        isError: true,
      );
      return;
    }

    // Validate order is a number
    final order = int.tryParse(orderController.text);
    if (order == null) {
      AdminUtils.showSnackBar(
        context,
        'Order must be a valid number',
        isError: true,
      );
      return;
    }

    // Create new document ID
    final newDocId = '${orderController.text}-${idController.text}';

    // Check if document with this ID already exists (unless it's the same document)
    if (newDocId != (isNewQuestion ? '' : originalQuestion!.id)) {
      try {
        final docSnapshot = await FirebaseFirestore.instance
            .collection(FirestoreService.ref.path)
            .doc(newDocId)
            .get();

        if (docSnapshot.exists) {
          if (!context.mounted) return;
          AdminUtils.showSnackBar(
            context,
            'A question with this order-id already exists',
            isError: true,
          );
          return;
        }
      } catch (e) {
        if (!context.mounted) return;
        AdminUtils.showSnackBar(
          context,
          'Error checking document existence: $e',
          isError: true,
        );
        return;
      }
    }

    // Parse options from comma-separated string
    final options = optionsController.text
        .split(',')
        .map((option) => option.trim())
        .where((option) => option.isNotEmpty)
        .toList();

    // Handle rotation details for rotation type questions
    Map<String, List<String>>? rotationDetails;
    if (typeController.text == 'rotation' &&
        rotationDetailsController.text.isNotEmpty) {
      try {
        // Basic parsing of JSON-like string to Map<String, List<String>>
        final text = rotationDetailsController.text.trim();
        if (text.startsWith('{') && text.endsWith('}')) {
          final content = text.substring(1, text.length - 1);
          final pairs = content.split('",').map((s) => s.trim());

          rotationDetails = {};
          for (var pair in pairs) {
            // Clean up the pair string
            pair = pair
                .replaceAll('"', '')
                .replaceAll('{', '')
                .replaceAll('}', '');

            // Split into key and value
            final parts = pair.split(':');
            if (parts.length == 2) {
              final key = parts[0].trim();
              final valueStr = parts[1].trim();

              // Parse the array value
              if (valueStr.startsWith('[') && valueStr.endsWith(']')) {
                final listContent = valueStr.substring(1, valueStr.length - 1);
                final items = listContent
                    .split(',')
                    .map((item) => item.trim().replaceAll('"', ''))
                    .where((item) => item.isNotEmpty)
                    .toList();

                rotationDetails[key] = items.cast<String>();
              }
            }
          }
        }
      } catch (e) {
        if (!context.mounted) return;
        AdminUtils.showSnackBar(
          context,
          'Error parsing rotation details: $e',
          isError: true,
        );
        return;
      }
    } else if (!isNewQuestion &&
        originalQuestion!.rotationDetails != null &&
        typeController.text == 'rotation') {
      // Keep existing rotation details if not changed
      rotationDetails = originalQuestion.rotationDetails;
    }

    // For yesNo type, set options to Yes and No
    if (typeController.text == 'yesNo') {
      options.clear();
      options.addAll(['Yes', 'No']);
    }

    // Create question object
    final updatedQuestion = Question(
      id: newDocId,
      name: nameController.text,
      type: typeController.text,
      options: options,
      rotationDetails: rotationDetails,
    );

    try {
      // If editing and ID changed, delete old document
      if (!isNewQuestion && newDocId != originalQuestion!.id) {
        await FirestoreService.deleteQuestion(originalQuestion);
      }

      // Save the question
      await FirestoreService.addQuestion(updatedQuestion);

      if (!context.mounted) return;
      Navigator.of(context).pop();
      onSaveSuccess();
      AdminUtils.showSnackBar(
        context,
        'Question ${isNewQuestion ? 'created' : 'updated'} successfully',
      );
    } catch (e) {
      if (!context.mounted) return;
      AdminUtils.showSnackBar(
        context,
        'Error saving question: $e',
        isError: true,
      );
    }
  }
}
