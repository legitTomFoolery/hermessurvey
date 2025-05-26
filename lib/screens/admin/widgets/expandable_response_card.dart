import 'package:flutter/material.dart';
import 'package:gsecsurvey/models/question.dart';
import 'package:gsecsurvey/models/survey_response.dart';
import 'package:gsecsurvey/screens/admin/utils/admin_utils.dart';
import 'package:gsecsurvey/services/response_admin_service.dart';

class ExpandableResponseCard extends StatefulWidget {
  final SurveyResponse response;
  final List<Question> questions;
  final VoidCallback onUpdate;
  final bool isExpanded;
  final VoidCallback onExpanded;
  final VoidCallback onCollapsed;

  const ExpandableResponseCard({
    Key? key,
    required this.response,
    required this.questions,
    required this.onUpdate,
    this.isExpanded = false,
    required this.onExpanded,
    required this.onCollapsed,
  }) : super(key: key);

  @override
  State<ExpandableResponseCard> createState() => _ExpandableResponseCardState();
}

class _ExpandableResponseCardState extends State<ExpandableResponseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isLoading = false;

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

    // Set initial animation state
    if (widget.isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ExpandableResponseCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle animation state changes when parent updates
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    if (widget.isExpanded) {
      widget.onCollapsed();
      _animationController.reverse();
    } else {
      widget.onExpanded();
      _animationController.forward();
    }
  }

  Future<void> _deleteResponse() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Response'),
        content: Text(
          'Are you sure you want to delete the response from ${widget.response.formattedDate}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success =
          await ResponseAdminService.deleteResponse(widget.response.id);

      if (success) {
        widget.onUpdate();
        if (!mounted) return;
        AdminUtils.showSnackBar(
          context,
          'Response deleted successfully',
        );
      } else {
        if (!mounted) return;
        AdminUtils.showSnackBar(
          context,
          'Failed to delete response',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      AdminUtils.showSnackBar(
        context,
        'Error deleting response: $e',
        isError: true,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Collapsed view
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(
                Icons.assignment,
                color: Colors.white,
              ),
            ),
            title: Text(
              widget.response.formattedDate,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(widget.response.subtitle),
            trailing: IconButton(
              icon: AnimatedRotation(
                turns: widget.isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 300),
                child: const Icon(Icons.expand_more),
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const Text(
            'Response Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Date', widget.response.date),
          _buildDetailRow('Rotation', widget.response.rotation),
          _buildDetailRow('Attending', widget.response.attending),

          const SizedBox(height: 16),
          const Text(
            'Survey Responses',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Display each question and its response (excluding standard fields)
          ...widget.response.questionResponses.entries.map((entry) {
            final questionId = entry.key;
            final responseValue = entry.value;

            // Find the question text
            final question = widget.questions.firstWhere(
              (q) => q.id == questionId,
              orElse: () => Question(
                id: questionId,
                name: 'Question not found',
                type: 'text',
                options: [],
              ),
            );

            return _buildQuestionResponseCard(question.name, responseValue);
          }).toList(),

          const SizedBox(height: 16),

          // Delete button
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: _deleteResponse,
                icon: const Icon(Icons.delete),
                label: const Text('Delete Response'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not specified' : value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionResponseCard(String questionText, String responseValue) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              questionText,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                responseValue.isEmpty ? 'No response' : responseValue,
                style: TextStyle(
                  color: responseValue.isEmpty ? Colors.grey : Colors.black,
                  fontStyle: responseValue.isEmpty
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
