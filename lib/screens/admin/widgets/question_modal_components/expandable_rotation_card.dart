import 'package:flutter/material.dart';
import 'package:gsecsurvey/screens/admin/widgets/question_modal_components/editable_list_field.dart';

class ExpandableRotationCard extends StatefulWidget {
  final String rotation;
  final List<String> attendings;
  final bool isExpanded;
  final VoidCallback onExpanded;
  final VoidCallback onCollapsed;
  final Function(String) onRotationNameChanged;
  final Function(List<String>) onAttendingsChanged;
  final VoidCallback onDelete;
  final ScrollController? scrollController;

  const ExpandableRotationCard({
    super.key,
    required this.rotation,
    required this.attendings,
    required this.isExpanded,
    required this.onExpanded,
    required this.onCollapsed,
    required this.onRotationNameChanged,
    required this.onAttendingsChanged,
    required this.onDelete,
    this.scrollController,
  });

  @override
  State<ExpandableRotationCard> createState() => _ExpandableRotationCardState();
}

class _ExpandableRotationCardState extends State<ExpandableRotationCard>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _rotationController;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = TextEditingController(text: widget.rotation);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Set initial animation state
    if (widget.isExpanded) {
      _animationController.value = 1.0;
    }

    // Fix cursor position
    _rotationController.selection = TextSelection.fromPosition(
      TextPosition(offset: _rotationController.text.length),
    );
  }

  @override
  void didUpdateWidget(ExpandableRotationCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle animation state changes when parent updates
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }

    // Update controller text if rotation name changed externally
    if (widget.rotation != oldWidget.rotation) {
      _rotationController.text = widget.rotation;
      _rotationController.selection = TextSelection.fromPosition(
        TextPosition(offset: _rotationController.text.length),
      );
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    if (widget.isExpanded) {
      widget.onCollapsed();
    } else {
      widget.onExpanded();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      color: theme.colorScheme.secondary,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Collapsed view
          ListTile(
            title: Text(
              widget.rotation,
              style: TextStyle(
                color: theme.colorScheme.onSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              '${widget.attendings.length} attending(s)',
              style: TextStyle(
                color: theme.colorScheme.shadow,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red.shade600,
                  ),
                  onPressed: widget.onDelete,
                  iconSize: 20,
                ),
                IconButton(
                  icon: AnimatedRotation(
                    turns: widget.isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.edit,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  onPressed: _toggleExpanded,
                ),
              ],
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rotation name field
          TextFormField(
            controller: _rotationController,
            decoration: const InputDecoration(
              labelText: 'Rotation Name',
              border: OutlineInputBorder(),
            ),
            onChanged: widget.onRotationNameChanged,
          ),
          const SizedBox(height: 16),

          // Attendings list
          EditableListField(
            items: widget.attendings,
            title: 'Attending Physicians',
            hintText: 'New Attending',
            onItemsChanged: widget.onAttendingsChanged,
            scrollController: widget.scrollController,
          ),

          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: _toggleExpanded,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('Done'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
