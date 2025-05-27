import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

import 'package:gsecsurvey/app/config/app_constants.dart';
import 'package:gsecsurvey/shared/presentation/widgets/common_widgets.dart';
import 'package:gsecsurvey/features/home/data/models/question_model.dart';
import 'package:gsecsurvey/shared/data/services/firestore_service.dart';
import 'package:gsecsurvey/shared/utils/helpers/admin_utils.dart';
import 'package:gsecsurvey/features/admin/presentation/widgets/question_modal_components/index.dart';

class ExpandableQuestionCard extends StatefulWidget {
  final Question question;
  final VoidCallback onSave;
  final bool isExpanded;
  final VoidCallback onExpanded;
  final VoidCallback onCollapsed;
  final bool isNewQuestion;

  const ExpandableQuestionCard({
    super.key,
    required this.question,
    required this.onSave,
    this.isExpanded = false,
    required this.onExpanded,
    required this.onCollapsed,
    this.isNewQuestion = false,
  });

  @override
  State<ExpandableQuestionCard> createState() => _ExpandableQuestionCardState();
}

class _ExpandableQuestionCardState extends State<ExpandableQuestionCard>
    with SingleTickerProviderStateMixin {
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

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: AppConstants.defaultAnimationDuration,
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _initializeControllers();

    // Set initial animation state
    if (widget.isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ExpandableQuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle animation state changes when parent updates
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
        if (!widget.isNewQuestion) {
          _resetControllers();
        }
      }
    }
  }

  void _initializeControllers() {
    // Split ID into order and ID parts
    final idParts = widget.question.id.split('-');
    String initialOrder = '';
    String initialId = '';

    if (idParts.isNotEmpty && widget.question.id.isNotEmpty) {
      initialOrder = idParts.first;
      if (idParts.length > 1) {
        initialId = idParts.sublist(1).join('-');
      }
    }

    // Dispose existing controllers if they exist
    _disposeControllersIfNeeded();

    // Initialize controllers
    _orderController = TextEditingController(text: initialOrder);
    _idController = TextEditingController(text: initialId);
    _nameController = TextEditingController(text: widget.question.name);
    _typeController = TextEditingController(text: widget.question.type);

    // For options (comma-separated string)
    _optionsController =
        TextEditingController(text: widget.question.options.join(', '));

    // For rotation details - pass the raw data to RotationField
    _rotationDetailsController = TextEditingController(text: '');
  }

  void _disposeControllersIfNeeded() {
    // This method is safe to call even if controllers haven't been initialized yet
    try {
      _orderController.dispose();
    } catch (e) {
      // Controller wasn't initialized yet
    }
    try {
      _idController.dispose();
    } catch (e) {
      // Controller wasn't initialized yet
    }
    try {
      _nameController.dispose();
    } catch (e) {
      // Controller wasn't initialized yet
    }
    try {
      _typeController.dispose();
    } catch (e) {
      // Controller wasn't initialized yet
    }
    try {
      _optionsController.dispose();
    } catch (e) {
      // Controller wasn't initialized yet
    }
    try {
      _rotationDetailsController.dispose();
    } catch (e) {
      // Controller wasn't initialized yet
    }
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
    if (widget.isExpanded) {
      // If currently expanded, collapse
      widget.onCollapsed();
      _animationController.reverse();
      // Reset controllers to original values when collapsing (except for new questions)
      if (!widget.isNewQuestion) {
        _resetControllers();
      }
    } else {
      // If currently collapsed, expand
      widget.onExpanded();
      _animationController.forward();
    }
  }

  void _resetControllers() {
    // Reset to original values without reinitializing
    final idParts = widget.question.id.split('-');
    String initialOrder = '';
    String initialId = '';

    if (idParts.isNotEmpty && widget.question.id.isNotEmpty) {
      initialOrder = idParts.first;
      if (idParts.length > 1) {
        initialId = idParts.sublist(1).join('-');
      }
    }

    _orderController.text = initialOrder;
    _idController.text = initialId;
    _nameController.text = widget.question.name;
    _typeController.text = widget.question.type;
    _optionsController.text = widget.question.options.join(', ');
    _rotationDetailsController.text = '';
  }

  void _saveQuestion() async {
    // Custom save logic to avoid Navigator.pop() issue
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
    if (newDocId != widget.question.id) {
      try {
        final docSnapshot = await FirebaseFirestore.instance
            .collection(FirestoreService.ref.path)
            .doc(newDocId)
            .get();

        if (docSnapshot.exists) {
          if (!mounted) return;
          AdminUtils.showSnackBar(
            context,
            'A question with this order-id already exists',
            isError: true,
          );
          return;
        }
      } catch (e) {
        if (!mounted) return;
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
    if (_typeController.text == 'rotation') {
      // For rotation questions, keep the existing rotation details
      // The RotationField component handles the editing internally
      rotationDetails = widget.question.rotationDetails;
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
      // If editing and ID changed, delete old document (but not for new questions)
      if (newDocId != widget.question.id && !widget.isNewQuestion) {
        await FirestoreService.deleteQuestion(widget.question);
      }

      // Save the question
      await FirestoreService.addQuestion(updatedQuestion);

      if (!mounted) return;
      widget.onSave();
      AdminUtils.showSnackBar(
        context,
        widget.isNewQuestion
            ? 'Question created successfully'
            : 'Question updated successfully',
      );
    } catch (e) {
      if (!mounted) return;
      AdminUtils.showSnackBar(
        context,
        'Error saving question: $e',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;

    return Container(
      margin:
          const EdgeInsets.symmetric(vertical: AppConstants.defaultSpacing / 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: widget.isNewQuestion
            ? Border.all(color: theme.colorScheme.primary, width: 2)
            : null,
      ),
      child: Column(
        children: [
          // Collapsed view
          ListTile(
            title: Text(
              widget.isNewQuestion && widget.question.name.isEmpty
                  ? 'New Question'
                  : widget.question.name,
              style: theme.textTheme.displayLarge?.copyWith(
                color: theme.colorScheme.onSecondary,
                fontSize: 16,
                fontStyle: widget.isNewQuestion && widget.question.name.isEmpty
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
            subtitle: widget.isNewQuestion && widget.question.id.isEmpty
                ? Text(
                    'Fill in the details below',
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: theme.colorScheme.shadow,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : Text(
                    'Order: ${widget.question.id.split('-').first}\nID: ${widget.question.id.split('-').sublist(1).join('-')}',
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: theme.colorScheme.shadow,
                      fontSize: 14,
                    ),
                  ),
            trailing: IconButton(
              icon: AnimatedRotation(
                turns: widget.isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  widget.isNewQuestion ? Icons.add : Icons.edit,
                  color: theme.colorScheme.primary,
                ),
              ),
              onPressed: _toggleExpanded,
            ),
          ),

          // Expanded view
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: widget.isExpanded
                ? _buildExpandedContent()
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    final theme = AdaptiveTheme.of(context).theme;

    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
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
          const SizedBox(height: AppConstants.defaultPadding),
          _buildTypeSpecificFields(),
          const SizedBox(height: AppConstants.defaultPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: CommonWidgets.buildTextButton(
                  context: context,
                  text: 'Cancel',
                  onPressed: _toggleExpanded,
                  textStyle: TextStyle(color: theme.colorScheme.shadow),
                ),
              ),
              const SizedBox(width: AppConstants.defaultSpacing),
              Flexible(
                child: CommonWidgets.buildElevatedButton(
                  context: context,
                  text: widget.isNewQuestion ? 'Create' : 'Save',
                  onPressed: _saveQuestion,
                ),
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
        isNewQuestion: widget.isNewQuestion,
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
