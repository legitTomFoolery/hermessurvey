import 'package:flutter/material.dart';
import 'package:gsecsurvey/features/home/data/models/question_model.dart';
import 'package:gsecsurvey/features/admin/presentation/widgets/question_modal_components/index.dart';

class QuestionModal extends StatefulWidget {
  final Question? question;
  final VoidCallback onSave;

  const QuestionModal({
    super.key,
    this.question,
    required this.onSave,
  });

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
  final ScrollController _scrollController = ScrollController();

  // Format rotation details to a string that can be parsed by RotationField
  String _formatRotationDetails(Map<String, List<String>> rotationDetails) {
    final buffer = StringBuffer('{');
    int i = 0;
    rotationDetails.forEach((rotation, attendings) {
      buffer.write('"$rotation": [');
      for (int j = 0; j < attendings.length; j++) {
        buffer.write('"${attendings[j]}"');
        if (j < attendings.length - 1) buffer.write(', ');
      }
      buffer.write(']');
      if (i < rotationDetails.length - 1) buffer.write(', ');
      i++;
    });
    buffer.write('}');
    return buffer.toString();
  }

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

    // For rotation details (formatted for proper parsing)
    _rotationDetailsController = TextEditingController(
        text: _isNewQuestion || widget.question!.rotationDetails == null
            ? ''
            : _formatRotationDetails(widget.question!.rotationDetails!));
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
    _scrollController.dispose();
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
      content: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            controller: _scrollController,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top content
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BasicFields(
                          orderController: _orderController,
                          idController: _idController,
                          nameController: _nameController,
                          typeController: _typeController,
                          onTypeChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _typeController.text = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),

                    // Bottom content - this will stay at the bottom when keyboard appears
                    _buildTypeSpecificFields(),
                  ],
                ),
              ),
            ),
          );
        },
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

  Widget _buildTypeSpecificFields() {
    if (_typeController.text == 'radio' || _typeController.text == 'dropdown') {
      return OptionsField(
        optionsController: _optionsController,
        newOptionController: _newOptionController,
        scrollController: _scrollController,
      );
    } else if (_typeController.text == 'rotation') {
      return RotationField(
        key: const ValueKey('rotation_field'),
        rotationDetailsController: _rotationDetailsController,
        scrollController: _scrollController,
        isNewQuestion: _isNewQuestion,
        rotationDetailsFromQuestion:
            _isNewQuestion ? null : widget.question!.rotationDetails,
      );
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

  void _saveQuestion() {
    print('🚀 DEBUG: _saveQuestion called');
    print(
        '🚀 DEBUG: _rotationDetailsController.text: "${_rotationDetailsController.text}"');
    print('🚀 DEBUG: _typeController.text: "${_typeController.text}"');
    print(
        '🚀 DEBUG: _rotationDetailsController.hashCode: ${_rotationDetailsController.hashCode}');

    QuestionSaveUtils.saveQuestion(
      context: context,
      isNewQuestion: _isNewQuestion,
      originalQuestion: widget.question,
      orderController: _orderController,
      idController: _idController,
      nameController: _nameController,
      typeController: _typeController,
      optionsController: _optionsController,
      rotationDetailsController: _rotationDetailsController,
      onSaveSuccess: widget.onSave,
    );
  }
}
