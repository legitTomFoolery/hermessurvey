import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
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
    final theme = AdaptiveTheme.of(context).theme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          // Collapsed view
          ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(
                Icons.assignment,
                color: Colors.white,
              ),
            ),
            title: Text(
              widget.response.formattedDate,
              style: theme.textTheme.displayLarge?.copyWith(
                color: theme.colorScheme.onSecondary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              widget.response.subtitle,
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
                  Icons.expand_more,
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: theme.colorScheme.surface),
          Text(
            'Response Details',
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSecondary,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Date', widget.response.date),
          _buildDetailRow('Rotation', widget.response.rotation),
          _buildDetailRow('Attending', widget.response.attending),

          const SizedBox(height: 16),
          Text(
            'Survey Responses',
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSecondary,
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
            Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          else
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: _deleteResponse,
                icon: const Icon(Icons.delete),
                label: const Text('Delete Response'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final theme = AdaptiveTheme.of(context).theme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: theme.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.shadow,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not specified' : value,
              style: theme.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w400,
                color: theme.colorScheme.onSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionResponseCard(String questionText, String responseValue) {
    final theme = AdaptiveTheme.of(context).theme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              questionText,
              style: theme.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: theme.colorScheme.onSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiary,
                border: Border.all(
                    color: theme.colorScheme.shadow.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                responseValue.isEmpty ? 'No response' : responseValue,
                style: theme.textTheme.displayLarge?.copyWith(
                  color: responseValue.isEmpty
                      ? theme.colorScheme.shadow
                      : theme.colorScheme.onSecondary,
                  fontStyle: responseValue.isEmpty
                      ? FontStyle.italic
                      : FontStyle.normal,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
