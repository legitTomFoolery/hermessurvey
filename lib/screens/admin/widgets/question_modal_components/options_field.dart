import 'package:flutter/material.dart';

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
    return StatefulBuilder(
      builder: (context, setState) {
        // Get existing options
        final existingOptions = widget.optionsController.text.isEmpty
            ? <String>[]
            : widget.optionsController.text
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList()
                .cast<String>();

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
                        // Only update the option in the list, don't update the controller text
                        // This prevents cursor jumping
                        existingOptions[i] = value;
                      },
                      onEditingComplete: () {
                        // Update the main options controller only when editing is complete
                        setState(() {
                          widget.optionsController.text =
                              existingOptions.join(', ');
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        existingOptions.removeAt(i);
                        widget.optionsController.text =
                            existingOptions.join(', ');
                        widget.newOptionController.clear();
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

        // Add the "New Option" field with Add button
        optionWidgets.add(
          _buildNewOptionField(existingOptions, setState),
        );

        return Column(children: optionWidgets);
      },
    );
  }

  Widget _buildNewOptionField(
      List<String> existingOptions, StateSetter setState) {
    return StatefulBuilder(
      builder: (context, setNewOptionState) {
        // Track if there's text in the new option field
        bool hasText = widget.newOptionController.text.isNotEmpty;

        // Listen for changes to show/hide the add button
        widget.newOptionController.addListener(() {
          final newHasText = widget.newOptionController.text.isNotEmpty;
          if (hasText != newHasText) {
            setNewOptionState(() {
              hasText = newHasText;
            });
          }
        });

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.newOptionController,
                  decoration: const InputDecoration(
                    hintText: 'New Option',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    isDense: true,
                  ),
                  style: const TextStyle(
                    // Match the style of the other text fields
                    fontSize: 14.0,
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        existingOptions.add(value);
                        widget.optionsController.text =
                            existingOptions.join(', ');
                        widget.newOptionController.clear();
                      });

                      // Scroll to the bottom after adding a new option
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (widget.scrollController.hasClients) {
                          widget.scrollController.animateTo(
                            widget.scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      });
                    }
                  },
                ),
              ),
              // Only show the add button if there's text in the field
              if (hasText)
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.green),
                  onPressed: () {
                    if (widget.newOptionController.text.isNotEmpty) {
                      setState(() {
                        existingOptions.add(widget.newOptionController.text);
                        widget.optionsController.text =
                            existingOptions.join(', ');
                        widget.newOptionController.clear();
                      });

                      // Scroll to the bottom after adding a new option
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (widget.scrollController.hasClients) {
                          widget.scrollController.animateTo(
                            widget.scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      });
                    }
                  },
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                ),
              // Add a spacer when the button is not shown to maintain layout
              if (!hasText) const SizedBox(width: 40),
            ],
          ),
        );
      },
    );
  }
}
