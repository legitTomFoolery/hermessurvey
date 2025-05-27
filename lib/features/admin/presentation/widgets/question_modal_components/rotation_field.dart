import 'package:flutter/material.dart';
import 'package:gsecsurvey/app/config/app_constants.dart';
import 'package:gsecsurvey/features/admin/presentation/widgets/question_modal_components/expandable_rotation_card.dart';

class RotationField extends StatefulWidget {
  final TextEditingController rotationDetailsController;
  final ScrollController scrollController;
  final bool isNewQuestion;
  final dynamic rotationDetailsFromQuestion;

  const RotationField({
    super.key,
    required this.rotationDetailsController,
    required this.scrollController,
    required this.isNewQuestion,
    this.rotationDetailsFromQuestion,
  });

  @override
  State<RotationField> createState() => _RotationFieldState();
}

class _RotationFieldState extends State<RotationField> {
  Map<String, List<String>> _rotations = {};
  String? _expandedRotationId;

  @override
  void initState() {
    super.initState();
    _parseRotationDetails();
  }

  void _parseRotationDetails() {
    print('🔍 DEBUG: _parseRotationDetails called');
    print(
        '🔍 DEBUG: Controller text: "${widget.rotationDetailsController.text}"');
    print('🔍 DEBUG: isNewQuestion: ${widget.isNewQuestion}');
    print(
        '🔍 DEBUG: rotationDetailsFromQuestion: ${widget.rotationDetailsFromQuestion}');

    try {
      if (widget.rotationDetailsController.text.isNotEmpty) {
        final text = widget.rotationDetailsController.text.trim();
        print('🔍 DEBUG: Trimmed text: "$text"');

        if (text.startsWith('{') && text.endsWith('}')) {
          final content = text.substring(1, text.length - 1);
          print('🔍 DEBUG: Content after removing braces: "$content"');

          final pairs = content.split('",').map((s) => s.trim());
          print('🔍 DEBUG: Split pairs: ${pairs.toList()}');

          for (var pair in pairs) {
            print('🔍 DEBUG: Processing pair: "$pair"');

            // Clean up the pair string
            pair = pair
                .replaceAll('"', '')
                .replaceAll('{', '')
                .replaceAll('}', '');
            print('🔍 DEBUG: Cleaned pair: "$pair"');

            // Split into key and value
            final parts = pair.split(':');
            print('🔍 DEBUG: Split parts: $parts');

            if (parts.length == 2) {
              final key = parts[0].trim();
              final valueStr = parts[1].trim();
              print('🔍 DEBUG: Key: "$key", ValueStr: "$valueStr"');

              // Parse the array value
              if (valueStr.startsWith('[') && valueStr.endsWith(']')) {
                final listContent = valueStr.substring(1, valueStr.length - 1);
                print('🔍 DEBUG: List content: "$listContent"');

                final items = listContent
                    .split(',')
                    .map((item) => item.trim().replaceAll('"', ''))
                    .where((item) => item.isNotEmpty)
                    .toList()
                    .cast<String>();
                print('🔍 DEBUG: Parsed items: $items');

                // Sort attendings alphabetically
                items.sort();
                _rotations[key] = items;
                print(
                    '🔍 DEBUG: Added to rotations - Key: "$key", Items: $items');
              } else {
                print(
                    '🔍 DEBUG: ValueStr does not start/end with brackets: "$valueStr"');
              }
            } else {
              print('🔍 DEBUG: Parts length is not 2: ${parts.length}');
            }
          }
        } else {
          print('🔍 DEBUG: Text does not start with { or end with }');
        }
      } else if (!widget.isNewQuestion &&
          widget.rotationDetailsFromQuestion != null) {
        print('🔍 DEBUG: Using rotationDetailsFromQuestion');
        _rotations =
            Map<String, List<String>>.from(widget.rotationDetailsFromQuestion);
        // Sort attendings for each rotation
        _rotations.forEach((key, value) {
          value.sort();
        });
        print('🔍 DEBUG: Loaded from question: $_rotations');
      } else {
        print('🔍 DEBUG: No rotation details to parse');
      }

      print('🔍 DEBUG: Final _rotations: $_rotations');
    } catch (e) {
      print('🔍 DEBUG: Error parsing rotation details: $e');
      print('🔍 DEBUG: Stack trace: ${StackTrace.current}');
      // If parsing fails, start with empty map
      _rotations = {};
    }

    // Ensure controller is updated with current rotation data
    _updateRotationDetails();
  }

  void _updateRotationDetails() {
    print('🔧 DEBUG: _updateRotationDetails called');
    print('🔧 DEBUG: Current _rotations: $_rotations');
    print(
        '🔧 DEBUG: Controller before update: "${widget.rotationDetailsController.text}"');

    final buffer = StringBuffer('{');
    int i = 0;
    _rotations.forEach((rotation, attendings) {
      print(
          '🔧 DEBUG: Processing rotation "$rotation" with attendings: $attendings');
      buffer.write('"$rotation": [');
      for (int j = 0; j < attendings.length; j++) {
        buffer.write('"${attendings[j]}"');
        if (j < attendings.length - 1) buffer.write(', ');
      }
      buffer.write(']');
      if (i < _rotations.length - 1) buffer.write(', ');
      i++;
    });
    buffer.write('}');

    final generatedJson = buffer.toString();
    print('🔧 DEBUG: Generated JSON: "$generatedJson"');

    widget.rotationDetailsController.text = generatedJson;
    print(
        '🔧 DEBUG: Controller text set to: "${widget.rotationDetailsController.text}"');
    print(
        '🔧 DEBUG: Controller hashCode: ${widget.rotationDetailsController.hashCode}');
  }

  void _onRotationExpanded(String rotationId) {
    setState(() {
      _expandedRotationId = rotationId;
    });
  }

  void _onRotationCollapsed() {
    setState(() {
      _expandedRotationId = null;
    });
  }

  void _addRotation() {
    setState(() {
      // Use ~ character which comes after letters alphabetically to ensure new rotations appear last
      final newRotationName = '~ New Rotation ${_rotations.length + 1}';
      _rotations[newRotationName] = [];
      _expandedRotationId =
          newRotationName; // Auto-expand new rotation for editing
    });
    // Update the controller after setState to ensure persistence
    _updateRotationDetails();
  }

  void _deleteRotation(String rotationName) {
    setState(() {
      _rotations.remove(rotationName);
      if (_expandedRotationId == rotationName) {
        _expandedRotationId = null;
      }
    });
    // Update the controller after setState to ensure persistence
    _updateRotationDetails();
  }

  void _updateRotationName(String oldName, String newName) {
    if (newName.isNotEmpty &&
        newName != oldName &&
        !_rotations.containsKey(newName)) {
      setState(() {
        final attendings = _rotations[oldName]!;
        _rotations.remove(oldName);
        _rotations[newName] = attendings;
        // Update expanded rotation ID to the new name
        if (_expandedRotationId == oldName) {
          _expandedRotationId = newName;
        }
      });
      // Update the controller after setState to ensure persistence
      _updateRotationDetails();
    }
  }

  void _updateAttendingsList(String rotationName, List<String> attendings) {
    setState(() {
      // Sort attendings alphabetically
      attendings.sort();
      _rotations[rotationName] = attendings;
    });
    // Update the controller after setState to ensure persistence
    _updateRotationDetails();
  }

  @override
  Widget build(BuildContext context) {
    // Get sorted rotation entries
    final sortedRotations = _rotations.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          // List of rotation cards (sorted alphabetically)
          ...sortedRotations.asMap().entries.map((mapEntry) {
            final index = mapEntry.key;
            final entry = mapEntry.value;
            final rotationName = entry.key;
            final attendings = entry.value;

            return ExpandableRotationCard(
              key: ValueKey(
                  '$rotationName-$index'), // Use ValueKey with index for better tracking
              rotation: rotationName,
              attendings: attendings,
              isExpanded: _expandedRotationId == rotationName,
              onExpanded: () => _onRotationExpanded(rotationName),
              onCollapsed: _onRotationCollapsed,
              onRotationNameChanged: (newName) =>
                  _updateRotationName(rotationName, newName),
              onAttendingsChanged: (newAttendingsList) =>
                  _updateAttendingsList(rotationName, newAttendingsList),
              onDelete: () => _deleteRotation(rotationName),
              scrollController: widget.scrollController,
            );
          }),

          // Add rotation button
          const SizedBox(height: 8),
          Builder(
            builder: (context) {
              final theme = Theme.of(context);
              return ElevatedButton.icon(
                onPressed: _addRotation,
                icon: const Icon(Icons.add),
                label: const Text('Add Rotation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
