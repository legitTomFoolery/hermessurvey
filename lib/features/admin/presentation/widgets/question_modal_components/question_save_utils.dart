import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gsecsurvey/features/home/data/models/question_model.dart';
import 'package:gsecsurvey/shared/utils/helpers/admin_utils.dart';
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
    print('🚨 DEBUG: QuestionSaveUtils.saveQuestion() called');
    print(
        '🚨 DEBUG: rotationDetailsController.text: "${rotationDetailsController.text}"');
    print(
        '🚨 DEBUG: rotationDetailsController.hashCode: ${rotationDetailsController.hashCode}');
    print('🚨 DEBUG: typeController.text: "${typeController.text}"');

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
    print('💾 DEBUG: Processing rotation details');
    print('💾 DEBUG: Type: ${typeController.text}');
    print(
        '💾 DEBUG: Rotation details controller text: "${rotationDetailsController.text}"');
    print('💾 DEBUG: isNewQuestion: $isNewQuestion');
    if (!isNewQuestion) {
      print(
          '💾 DEBUG: Original question rotation details: ${originalQuestion?.rotationDetails}');
    }

    if (typeController.text == 'rotation' &&
        rotationDetailsController.text.isNotEmpty) {
      try {
        print('💾 DEBUG: Parsing rotation details from controller text');
        // FIXED: Better parsing logic that handles multiple rotations correctly
        final text = rotationDetailsController.text.trim();
        print('💾 DEBUG: Trimmed text: "$text"');

        if (text.startsWith('{') && text.endsWith('}')) {
          final content = text.substring(1, text.length - 1);
          print('💾 DEBUG: Content after removing braces: "$content"');

          rotationDetails = {};

          // FIXED: Use a more robust parsing approach
          // Split by "], " to separate key-value pairs properly
          final pairs = <String>[];
          var currentPair = '';
          var bracketCount = 0;
          var inQuotes = false;

          for (int i = 0; i < content.length; i++) {
            final char = content[i];
            currentPair += char;

            if (char == '"' && (i == 0 || content[i - 1] != '\\')) {
              inQuotes = !inQuotes;
            } else if (!inQuotes) {
              if (char == '[') {
                bracketCount++;
              } else if (char == ']') {
                bracketCount--;
                // If we've closed all brackets and the next chars are ", " then we have a complete pair
                if (bracketCount == 0 &&
                    i + 2 < content.length &&
                    content.substring(i + 1, i + 3) == ', ') {
                  pairs.add(currentPair.substring(
                      0, currentPair.length - 1)); // Remove the ']'
                  currentPair = '';
                  i += 2; // Skip the ", "
                }
              }
            }
          }

          // Add the last pair
          if (currentPair.isNotEmpty) {
            pairs.add(currentPair);
          }

          print('💾 DEBUG: Split pairs: $pairs');

          for (var pair in pairs) {
            print('💾 DEBUG: Processing pair: "$pair"');

            // Find the first colon that's not inside quotes
            var colonIndex = -1;
            var inQuotes = false;
            for (int i = 0; i < pair.length; i++) {
              if (pair[i] == '"' && (i == 0 || pair[i - 1] != '\\')) {
                inQuotes = !inQuotes;
              } else if (!inQuotes && pair[i] == ':') {
                colonIndex = i;
                break;
              }
            }

            if (colonIndex != -1) {
              var key =
                  pair.substring(0, colonIndex).trim().replaceAll('"', '');
              var valueStr = pair.substring(colonIndex + 1).trim();

              print('💾 DEBUG: Key: "$key", ValueStr: "$valueStr"');

              // Parse the array value
              if (valueStr.startsWith('[') && valueStr.endsWith(']')) {
                final listContent = valueStr.substring(1, valueStr.length - 1);
                print('💾 DEBUG: List content: "$listContent"');

                final items = <String>[];
                if (listContent.isNotEmpty) {
                  // Split by comma but respect quotes
                  var currentItem = '';
                  var inQuotes = false;

                  for (int i = 0; i < listContent.length; i++) {
                    final char = listContent[i];

                    if (char == '"' && (i == 0 || listContent[i - 1] != '\\')) {
                      inQuotes = !inQuotes;
                    } else if (!inQuotes && char == ',') {
                      if (currentItem.trim().isNotEmpty) {
                        items.add(currentItem.trim().replaceAll('"', ''));
                      }
                      currentItem = '';
                    } else {
                      currentItem += char;
                    }
                  }

                  // Add the last item
                  if (currentItem.trim().isNotEmpty) {
                    items.add(currentItem.trim().replaceAll('"', ''));
                  }
                }

                print('💾 DEBUG: Parsed items: $items');
                rotationDetails[key] = items;
                print(
                    '💾 DEBUG: Added to rotationDetails - Key: "$key", Items: $items');
              } else {
                print(
                    '💾 DEBUG: ValueStr does not start/end with brackets: "$valueStr"');
              }
            } else {
              print(
                  '💾 DEBUG: Could not find colon separator in pair: "$pair"');
            }
          }

          print('💾 DEBUG: Final parsed rotationDetails: $rotationDetails');
        } else {
          print('💾 DEBUG: Text does not start with { or end with }');
        }
      } catch (e) {
        print('💾 DEBUG: Error parsing rotation details: $e');
        print('💾 DEBUG: Stack trace: ${StackTrace.current}');
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
      print('💾 DEBUG: Using existing rotation details from original question');
      // Keep existing rotation details if not changed
      rotationDetails = originalQuestion.rotationDetails;
      print('💾 DEBUG: Existing rotation details: $rotationDetails');
    } else {
      print('💾 DEBUG: No rotation details to process');
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

      // Close the modal first
      Navigator.of(context).pop();

      // Then call the success callback and show snackbar
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
