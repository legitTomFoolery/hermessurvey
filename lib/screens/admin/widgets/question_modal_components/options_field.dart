import 'package:flutter/material.dart';
import 'package:gsecsurvey/screens/admin/widgets/question_modal_components/editable_list_field.dart';

class OptionsField extends StatefulWidget {
  final TextEditingController optionsController;
  final TextEditingController newOptionController;
  final ScrollController scrollController;

  const OptionsField({
    Key? key,
    required this.optionsController,
    required this.newOptionController,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<OptionsField> createState() => _OptionsFieldState();
}

class _OptionsFieldState extends State<OptionsField> {
  @override
  Widget build(BuildContext context) {
    // Get existing options
    final existingOptions = widget.optionsController.text.isEmpty
        ? <String>[]
        : widget.optionsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList()
            .cast<String>();

    return EditableListField(
      items: existingOptions,
      title: 'Options',
      hintText: 'New Option',
      onItemsChanged: (newOptions) {
        setState(() {
          widget.optionsController.text = newOptions.join(', ');
          widget.newOptionController.clear();
        });
      },
      scrollController: widget.scrollController,
    );
  }
}
