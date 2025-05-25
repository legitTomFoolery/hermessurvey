import 'package:flutter/material.dart';
import 'package:gsecsurvey/models/question.dart';
import 'package:gsecsurvey/screens/admin/widgets/question_modal_components/index.dart';

class ExpandableQuestionCard extends StatefulWidget {
  final Question question;
  final VoidCallback onSave;

  const ExpandableQuestionCard({
    Key? key,
    required this.question,
    required this.onSave,
  }) : super(key: key);

  @override
  State<ExpandableQuestionCard> createState() => _ExpandableQuestionCardState();
}

class _ExpandableQuestionCardState extends State<ExpandableQuestionCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  late final TextEditingController _orderController;
  late final TextEditingController _idController;
  late final TextEditingController _nameController;
  late final TextEditingController _typeController;
  late final TextEditingController _optionsController;
  late final TextEditingController _rotationDetailsController;
  final TextEditingController _newOptionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

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

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _initializeControllers();
  }

  void _initializeControllers() {
    // Split ID into order and ID parts
    final idParts = widget.question.id.split('-');
    String initialOrder = '';
    String initialId = '';

    if (idParts.isNotEmpty) {
      initialOrder = idParts.first;
      if (idParts.length > 1) {
        initialId = idParts.sublist(1).join('-');
      }
    }

    // Initialize controllers
    _orderController = TextEditingController(text: initialOrder);
    _idController = TextEditingController(text: initialId);
    _nameController = TextEditingController(text: widget.question.name);
    _typeController = TextEditingController(text: widget.question.type);

    // For options (comma-separated string)
    _optionsController =
        TextEditingController(text: widget.question.options.join(', '));

    // For rotation details (formatted for proper parsing)
    _rotationDetailsController = TextEditingController(
        text: widget.question.rotationDetails == null
            ? ''
            : _formatRotationDetails(widget.question.rotationDetails!));
  }

  @override
  void dispose() {
    _animationController.dispose();
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

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
        // Reset controllers to original values when collapsing
        _initializeControllers();
      }
    });
  }

  void _saveQuestion() {
    QuestionSaveUtils.saveQuestion(
      context: context,
      isNewQuestion: false,
      originalQuestion: widget.question,
      orderController: _orderController,
      idController: _idController,
      nameController: _nameController,
      typeController: _typeController,
      optionsController: _optionsController,
      rotationDetailsController: _rotationDetailsController,
      onSaveSuccess: () {
        _toggleExpanded(); // Close the card after saving
        widget.onSave();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Collapsed view
          ListTile(
            title: Text(widget.question.name),
            subtitle: Text(
                'Type: ${widget.question.type} | ID: ${widget.question.id}'),
            trailing: IconButton(
              icon: AnimatedRotation(
                turns: _isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 300),
                child: const Icon(Icons.edit),
              ),
              onPressed: _toggleExpanded,
            ),
          ),

          // Expanded view
          SizeTransition(
            sizeFactor: _expandAnimation,
            child:
                _isExpanded ? _buildExpandedContent() : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
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
          const SizedBox(height: 16),
          _buildTypeSpecificFields(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _toggleExpanded,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _saveQuestion,
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
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
        rotationDetailsController: _rotationDetailsController,
        scrollController: _scrollController,
        isNewQuestion: false,
        rotationDetailsFromQuestion: widget.question.rotationDetails,
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
}
