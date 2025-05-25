import 'package:flutter/material.dart';

class RotationCard extends StatefulWidget {
  final String rotation;
  final List<String> attendings;
  final Map<String, List<String>> rotations;
  final VoidCallback updateRotationDetails;
  final ScrollController scrollController;

  const RotationCard({
    Key? key,
    required this.rotation,
    required this.attendings,
    required this.rotations,
    required this.updateRotationDetails,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<RotationCard> createState() => _RotationCardState();
}

class _RotationCardState extends State<RotationCard> {
  bool isExpanded = false;
  late final TextEditingController rotationController;

  @override
  void initState() {
    super.initState();
    rotationController = TextEditingController(text: widget.rotation);

    // Fix cursor position
    rotationController.selection = TextSelection.fromPosition(
      TextPosition(offset: rotationController.text.length),
    );
  }

  @override
  void dispose() {
    rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                if (value.isNotEmpty && value != widget.rotation) {
                  setState(() {
                    final attendingsList = widget.rotations[widget.rotation]!;
                    widget.rotations.remove(widget.rotation);
                    widget.rotations[value] = attendingsList;
                    widget.updateRotationDetails();
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
                      widget.rotations.remove(widget.rotation);
                      widget.updateRotationDetails();
                    });
                  },
                  iconSize: 20,
                ),
                IconButton(
                  icon: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  onPressed: () {
                    setState(() {
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
                  ...widget.attendings.asMap().entries.map((entry) {
                    final index = entry.key;
                    final attending = entry.value;
                    final attendingController =
                        TextEditingController(text: attending);

                    // Fix cursor position
                    attendingController.selection = TextSelection.fromPosition(
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
                                // Only update the list value, don't update the controller
                                widget.attendings[index] = value;
                              },
                              onEditingComplete: () {
                                // Update rotation details only when editing is complete
                                widget.updateRotationDetails();
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () {
                              setState(() {
                                widget.attendings.removeAt(index);
                                widget.updateRotationDetails();
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
                  _buildNewAttendingField(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNewAttendingField() {
    return StatefulBuilder(
      builder: (context, setAttendingState) {
        // Create a controller for the new attending field
        final newAttendingController = TextEditingController();

        // Track if there's text in the new attending field
        bool hasText = false;

        // Listen for changes to show/hide the add button
        newAttendingController.addListener(() {
          final newHasText = newAttendingController.text.isNotEmpty;
          if (hasText != newHasText) {
            setAttendingState(() {
              hasText = newHasText;
            });
          }
        });

        return Row(
          children: [
            Expanded(
              child: TextField(
                controller: newAttendingController,
                decoration: const InputDecoration(
                  hintText: 'New Attending',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  isDense: true,
                ),
                style: const TextStyle(
                  // Match the style of the other text fields
                  fontSize: 14.0,
                ),
                // Removed onTap scrolling behavior to prevent auto-scrolling when typing
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      widget.attendings.add(value);
                      widget.updateRotationDetails();
                    });
                    // Clear the field
                    newAttendingController.clear();

                    // Scroll to the bottom after adding a new attending
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
                  final value = newAttendingController.text;
                  if (value.isNotEmpty) {
                    setState(() {
                      widget.attendings.add(value);
                      widget.updateRotationDetails();
                    });
                    // Clear the field
                    newAttendingController.clear();

                    // Scroll to the bottom after adding a new attending
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
              ),
            // Add a spacer when the button is not shown to maintain layout
            if (!hasText) const SizedBox(width: 40),
          ],
        );
      },
    );
  }
}
