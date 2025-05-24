import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gsecsurvey/models/question.dart';
import 'package:gsecsurvey/screens/admin/utils/admin_utils.dart';
import 'package:gsecsurvey/services/firestore_service.dart';

class QuestionModal extends StatefulWidget {
  final Question? question;
  final VoidCallback onSave;

  const QuestionModal({
    Key? key,
    this.question,
    required this.onSave,
  }) : super(key: key);

  @override
  State<QuestionModal> createState() => _QuestionModalState();
}

class _QuestionModalState extends State<QuestionModal> {
  late final bool _isNewQuestion;
  late final TextEditingController _orderController;
  late final TextEditingController _idController;
  late final TextEditingController _nameController;
  late final TextEditingController _typeController;
  late final TextEditingController _optionsController;
  late final TextEditingController _rotationDetailsController;
  final TextEditingController _newOptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isNewQuestion = widget.question == null;

    // Split ID into order and ID parts if editing existing question
    String initialOrder = '';
    String initialId = '';

    if (!_isNewQuestion) {
      final idParts = widget.question!.id.split('-');
      if (idParts.isNotEmpty) {
        initialOrder = idParts.first;
        if (idParts.length > 1) {
          initialId = idParts.sublist(1).join('-');
        }
      }
    }

    // Initialize controllers
    _orderController = TextEditingController(text: initialOrder);
    _idController = TextEditingController(text: initialId);
    _nameController = TextEditingController(
        text: _isNewQuestion ? '' : widget.question!.name);
    _typeController = TextEditingController(
        text: _isNewQuestion ? '' : widget.question!.type);

    // For options (comma-separated string)
    _optionsController = TextEditingController(
        text: _isNewQuestion ? '' : widget.question!.options.join(', '));

    // For rotation details (simplified as text for now)
    _rotationDetailsController = TextEditingController(
        text: _isNewQuestion || widget.question!.rotationDetails == null
            ? ''
            : widget.question!.rotationDetails.toString());
  }

  @override
  void dispose() {
    _orderController.dispose();
    _idController.dispose();
    _nameController.dispose();
    _typeController.dispose();
    _optionsController.dispose();
    _rotationDetailsController.dispose();
    _newOptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 30.0),
            child:
                Text(_isNewQuestion ? 'Create New Question' : 'Edit Question'),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              iconSize: 20,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicFields(),
            _buildTypeSpecificFields(),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: _saveQuestion,
            child: const Text('Save'),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicFields() {
    return Column(
      children: [
        TextFormField(
          controller: _orderController,
          decoration: const InputDecoration(
            labelText: 'Order (number)',
            hintText: 'e.g., 1, 2, 3',
          ),
          keyboardType: TextInputType.number,
        ),
        TextFormField(
          controller: _idController,
          decoration: const InputDecoration(
            labelText: 'ID',
            hintText: 'Unique identifier',
          ),
        ),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Question Text',
            hintText: 'Enter the question text',
          ),
        ),
        DropdownButtonFormField<String>(
          value: _typeController.text.isEmpty ? null : _typeController.text,
          decoration: const InputDecoration(
            labelText: 'Question Type',
          ),
          items: const [
            DropdownMenuItem(value: 'text', child: Text('Text Input')),
            DropdownMenuItem(
                value: 'radio', child: Text('Multiple Choice (Radio)')),
            DropdownMenuItem(value: 'yesNo', child: Text('Yes/No')),
            DropdownMenuItem(value: 'dropdown', child: Text('Dropdown')),
            DropdownMenuItem(value: 'date', child: Text('Date Picker')),
            DropdownMenuItem(value: 'rotation', child: Text('Rotation')),
            DropdownMenuItem(value: 'attending', child: Text('Attending')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _typeController.text = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildTypeSpecificFields() {
    if (_typeController.text == 'radio' || _typeController.text == 'dropdown') {
      return _buildOptionsField();
    } else if (_typeController.text == 'rotation') {
      return _buildRotationField();
    } else if (_typeController.text == 'yesNo') {
      return const Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Text(
          'Note: Yes/No questions automatically use "Yes" and "No" as options.',
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      );
    } else if (_typeController.text == 'attending') {
      return const Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Text(
          'Note: Attending questions get their options from the selected rotation.',
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildOptionsField() {
    return StatefulBuilder(
      builder: (context, setState) {
        // Get existing options
        final existingOptions = _optionsController.text.isEmpty
            ? []
            : _optionsController.text
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();

        // Create a list of widgets for existing options + "New Option" at the end
        final optionWidgets = <Widget>[];

        optionWidgets.add(
          const Padding(
            padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: Text(
              'Options',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );

        // Add existing options with delete buttons
        for (int i = 0; i < existingOptions.length; i++) {
          final optionController =
              TextEditingController(text: existingOptions[i]);

          // Fix cursor position issue by setting selection after controller is initialized
          optionController.selection = TextSelection.fromPosition(
            TextPosition(offset: optionController.text.length),
          );

          optionWidgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: optionController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        // Update the option in the list
                        setState(() {
                          existingOptions[i] = value;
                          _optionsController.text = existingOptions.join(', ');
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        existingOptions.removeAt(i);
                        _optionsController.text = existingOptions.join(', ');
                        _newOptionController.clear();
                      });
                    },
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
          );
        }

        // Add the "New Option" field
        optionWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newOptionController,
                    decoration: const InputDecoration(
                      hintText: 'New Option',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        setState(() {
                          existingOptions.add(value);
                          _optionsController.text = existingOptions.join(', ');
                          _newOptionController.clear();
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
        );

        return Column(children: optionWidgets);
      },
    );
  }

  Widget _buildRotationField() {
    return StatefulBuilder(
      builder: (context, setState) {
        // Parse existing rotation details
        Map<String, List<String>> rotations = {};

        try {
          if (_rotationDetailsController.text.isNotEmpty) {
            final text = _rotationDetailsController.text.trim();
            if (text.startsWith('{') && text.endsWith('}')) {
              final content = text.substring(1, text.length - 1);
              final pairs = content.split('",').map((s) => s.trim());

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
                    final listContent =
                        valueStr.substring(1, valueStr.length - 1);
                    final items = listContent
                        .split(',')
                        .map((item) => item.trim().replaceAll('"', ''))
                        .where((item) => item.isNotEmpty)
                        .toList();

                    rotations[key] = items;
                  }
                }
              }
            }
          } else if (!_isNewQuestion &&
              widget.question!.rotationDetails != null) {
            rotations = Map.from(widget.question!.rotationDetails!);
          }
        } catch (e) {
          // If parsing fails, start with empty map
          rotations = {};
        }

        // Function to update the rotationDetailsController
        void updateRotationDetails() {
          final buffer = StringBuffer('{');
          int i = 0;
          rotations.forEach((rotation, attendings) {
            buffer.write('"$rotation": [');
            for (int j = 0; j < attendings.length; j++) {
              buffer.write('"${attendings[j]}"');
              if (j < attendings.length - 1) buffer.write(', ');
            }
            buffer.write(']');
            if (i < rotations.length - 1) buffer.write(', ');
            i++;
          });
          buffer.write('}');
          _rotationDetailsController.text = buffer.toString();
        }

        // Build UI for rotations
        final rotationWidgets = <Widget>[];

        rotationWidgets.add(
          const Padding(
            padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: Text(
              'Rotations',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );

        // Add existing rotations with expandable sections
        rotations.forEach((rotation, attendings) {
          rotationWidgets.add(
            _buildRotationCard(
                rotation, attendings, rotations, updateRotationDetails),
          );
        });

        // Add "Add Rotation" button
        rotationWidgets.add(
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                final newRotationName = 'New Rotation ${rotations.length + 1}';
                rotations[newRotationName] = [];
                updateRotationDetails();
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Rotation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              foregroundColor: Colors.black87,
            ),
          ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rotationWidgets,
        );
      },
    );
  }

  Widget _buildRotationCard(
    String rotation,
    List<String> attendings,
    Map<String, List<String>> rotations,
    VoidCallback updateRotationDetails,
  ) {
    return StatefulBuilder(
      builder: (context, setInnerState) {
        bool isExpanded = false;
        final rotationController = TextEditingController(text: rotation);

        // Fix cursor position
        rotationController.selection = TextSelection.fromPosition(
          TextPosition(offset: rotationController.text.length),
        );

        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            children: [
              // Rotation header with expand/collapse
              ListTile(
                title: TextFormField(
                  controller: rotationController,
                  enabled: isExpanded,
                  decoration: const InputDecoration(
                    labelText: 'Rotation Name',
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    // Update rotation name
                    if (value.isNotEmpty && value != rotation) {
                      setState(() {
                        final attendingsList = rotations[rotation]!;
                        rotations.remove(rotation);
                        rotations[value] = attendingsList;
                        updateRotationDetails();
                      });
                    }
                  },
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          rotations.remove(rotation);
                          updateRotationDetails();
                        });
                      },
                      iconSize: 20,
                    ),
                    IconButton(
                      icon: Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                      ),
                      onPressed: () {
                        setInnerState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Expanded section with attendings
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Attending Physicians',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // List of attendings
                      ...attendings.asMap().entries.map((entry) {
                        final index = entry.key;
                        final attending = entry.value;
                        final attendingController =
                            TextEditingController(text: attending);

                        // Fix cursor position
                        attendingController.selection =
                            TextSelection.fromPosition(
                          TextPosition(offset: attendingController.text.length),
                        );

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: attendingController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    isDense: true,
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      attendings[index] = value;
                                      updateRotationDetails();
                                    });
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    attendings.removeAt(index);
                                    updateRotationDetails();
                                  });
                                },
                                iconSize: 20,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                      // Add new attending field
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: 'New Attending',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                isDense: true,
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  setState(() {
                                    attendings.add(value);
                                    updateRotationDetails();
                                  });
                                  // Clear the field
                                  setInnerState(() {
                                    (context as Element).markNeedsBuild();
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveQuestion() async {
    // Validate required fields
    if (_orderController.text.isEmpty ||
        _idController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _typeController.text.isEmpty) {
      AdminUtils.showSnackBar(
        context,
        'Order, ID, Question Text, and Type are required',
        isError: true,
      );
      return;
    }

    // Validate order is a number
    final order = int.tryParse(_orderController.text);
    if (order == null) {
      AdminUtils.showSnackBar(
        context,
        'Order must be a valid number',
        isError: true,
      );
      return;
    }

    // Create new document ID
    final newDocId = '${_orderController.text}-${_idController.text}';

    // Check if document with this ID already exists (unless it's the same document)
    if (newDocId != (_isNewQuestion ? '' : widget.question!.id)) {
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
    final options = _optionsController.text
        .split(',')
        .map((option) => option.trim())
        .where((option) => option.isNotEmpty)
        .toList();

    // Handle rotation details for rotation type questions
    Map<String, List<String>>? rotationDetails;
    if (_typeController.text == 'rotation' &&
        _rotationDetailsController.text.isNotEmpty) {
      try {
        // Basic parsing of JSON-like string to Map<String, List<String>>
        final text = _rotationDetailsController.text.trim();
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

                rotationDetails[key] = items;
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
    } else if (!_isNewQuestion &&
        widget.question!.rotationDetails != null &&
        _typeController.text == 'rotation') {
      // Keep existing rotation details if not changed
      rotationDetails = widget.question!.rotationDetails;
    }

    // For yesNo type, set options to Yes and No
    if (_typeController.text == 'yesNo') {
      options.clear();
      options.addAll(['Yes', 'No']);
    }

    // Create question object
    final updatedQuestion = Question(
      id: newDocId,
      name: _nameController.text,
      type: _typeController.text,
      options: options,
      rotationDetails: rotationDetails,
    );

    try {
      // If editing and ID changed, delete old document
      if (!_isNewQuestion && newDocId != widget.question!.id) {
        await FirestoreService.deleteQuestion(widget.question!);
      }

      // Save the question
      await FirestoreService.addQuestion(updatedQuestion);

      if (!context.mounted) return;
      Navigator.of(context).pop();
      widget.onSave();
      AdminUtils.showSnackBar(
        context,
        'Question ${_isNewQuestion ? 'created' : 'updated'} successfully',
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
