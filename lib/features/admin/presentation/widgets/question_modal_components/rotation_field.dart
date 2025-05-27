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
    try {
      if (widget.rotationDetailsController.text.isNotEmpty) {
        final text = widget.rotationDetailsController.text.trim();
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
                final listContent = valueStr.substring(1, valueStr.length - 1);
                final items = listContent
                    .split(',')
                    .map((item) => item.trim().replaceAll('"', ''))
                    .where((item) => item.isNotEmpty)
                    .toList()
                    .cast<String>();

                // Sort attendings alphabetically
                items.sort();
                _rotations[key] = items;
              }
            }
          }
        }
      } else if (!widget.isNewQuestion &&
          widget.rotationDetailsFromQuestion != null) {
        _rotations =
            Map<String, List<String>>.from(widget.rotationDetailsFromQuestion);
        // Sort attendings for each rotation
        _rotations.forEach((key, value) {
          value.sort();
        });
      }
    } catch (e) {
      // If parsing fails, start with empty map
      _rotations = {};
    }
  }

  void _updateRotationDetails() {
    final buffer = StringBuffer('{');
    int i = 0;
    _rotations.forEach((rotation, attendings) {
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
    widget.rotationDetailsController.text = buffer.toString();
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
      _updateRotationDetails();
    });
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
        _updateRotationDetails();
      });
    }
  }

  void _updateAttendingsList(String rotationName, List<String> attendings) {
    setState(() {
      // Sort attendings alphabetically
      attendings.sort();
      _rotations[rotationName] = attendings;
      _updateRotationDetails();
    });
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
