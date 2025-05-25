import 'package:flutter/material.dart';
import 'package:gsecsurvey/screens/admin/widgets/question_modal_components/rotation_card.dart';

class RotationField extends StatefulWidget {
  final TextEditingController rotationDetailsController;
  final ScrollController scrollController;
  final bool isNewQuestion;
  final dynamic rotationDetailsFromQuestion;

  const RotationField({
    Key? key,
    required this.rotationDetailsController,
    required this.scrollController,
    required this.isNewQuestion,
    this.rotationDetailsFromQuestion,
  }) : super(key: key);

  @override
  State<RotationField> createState() => _RotationFieldState();
}

class _RotationFieldState extends State<RotationField> {
  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        // Parse existing rotation details
        Map<String, List<String>> rotations = {};

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
                    final listContent =
                        valueStr.substring(1, valueStr.length - 1);
                    final items = listContent
                        .split(',')
                        .map((item) => item.trim().replaceAll('"', ''))
                        .where((item) => item.isNotEmpty)
                        .toList()
                        .cast<String>();

                    rotations[key] = items;
                  }
                }
              }
            }
          } else if (!widget.isNewQuestion &&
              widget.rotationDetailsFromQuestion != null) {
            rotations = Map<String, List<String>>.from(
                widget.rotationDetailsFromQuestion);
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
          widget.rotationDetailsController.text = buffer.toString();
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
            RotationCard(
              rotation: rotation,
              attendings: attendings,
              rotations: rotations,
              updateRotationDetails: updateRotationDetails,
              scrollController: widget.scrollController,
            ),
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
}
