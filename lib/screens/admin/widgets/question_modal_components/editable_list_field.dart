import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';

class EditableListField extends StatefulWidget {
  final List<String> items;
  final String title;
  final String hintText;
  final Function(List<String>) onItemsChanged;
  final ScrollController? scrollController;

  const EditableListField({
    super.key,
    required this.items,
    required this.title,
    required this.hintText,
    required this.onItemsChanged,
    this.scrollController,
  });

  @override
  State<EditableListField> createState() => _EditableListFieldState();
}

class _EditableListFieldState extends State<EditableListField> {
  final TextEditingController _newItemController = TextEditingController();

  @override
  void dispose() {
    _newItemController.dispose();
    super.dispose();
  }

  void _addItem(String value) {
    if (value.isNotEmpty) {
      setState(() {
        final newItems = List<String>.from(widget.items);
        newItems.add(value);
        widget.onItemsChanged(newItems);
        _newItemController.clear();
      });

      // Scroll to the bottom after adding a new item
      if (widget.scrollController != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (widget.scrollController!.hasClients) {
            widget.scrollController!.animateTo(
              widget.scrollController!.position.maxScrollExtent,
              duration: AppConstants.defaultAnimationDuration,
              curve: Curves.easeOut,
            );
          }
        });
      }
    }
  }

  void _removeItem(int index) {
    setState(() {
      final newItems = List<String>.from(widget.items);
      newItems.removeAt(index);
      widget.onItemsChanged(newItems);
    });
  }

  void _updateItem(int index, String value) {
    final newItems = List<String>.from(widget.items);
    newItems[index] = value;
    widget.onItemsChanged(newItems);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(
                top: AppConstants.defaultPadding,
                bottom: AppConstants.defaultSpacing),
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        // List of existing items
        ...widget.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final itemController = TextEditingController(text: item);

          // Fix cursor position
          itemController.selection = TextSelection.fromPosition(
            TextPosition(offset: itemController.text.length),
          );

          return Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.defaultSpacing),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: itemController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      // Update the item in the list
                      _updateItem(index, value);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _removeItem(index),
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          );
        }),

        // Add new item field
        _buildNewItemField(),
      ],
    );
  }

  Widget _buildNewItemField() {
    return StatefulBuilder(
      builder: (context, setNewItemState) {
        // Track if there's text in the new item field
        bool hasText = _newItemController.text.isNotEmpty;

        // Listen for changes to show/hide the add button
        _newItemController.addListener(() {
          final newHasText = _newItemController.text.isNotEmpty;
          if (hasText != newHasText) {
            setNewItemState(() {
              hasText = newHasText;
            });
          }
        });

        return Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newItemController,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  isDense: true,
                ),
                style: const TextStyle(
                  fontSize: 14.0,
                ),
                onSubmitted: _addItem,
              ),
            ),
            // Only show the add button if there's text in the field
            if (hasText)
              IconButton(
                icon: const Icon(Icons.add, color: Colors.green),
                onPressed: () => _addItem(_newItemController.text),
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            // Add a spacer when the button is not shown to maintain layout
            if (!hasText) const SizedBox(width: 40),
          ],
        );
      },
    );
  }
}
