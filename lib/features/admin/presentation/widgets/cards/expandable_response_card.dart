import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

import 'package:gsecsurvey/app/config/app_constants.dart';
import 'package:gsecsurvey/features/home/data/models/question.dart';
import 'package:gsecsurvey/features/home/data/models/survey_response.dart';

class ExpandableResponseCard extends StatefulWidget {
  final SurveyResponse response;
  final List<Question> questions;
  final VoidCallback onUpdate;
  final bool isExpanded;
  final VoidCallback onExpanded;
  final VoidCallback onCollapsed;

  const ExpandableResponseCard({
    super.key,
    required this.response,
    required this.questions,
    required this.onUpdate,
    this.isExpanded = false,
    required this.onExpanded,
    required this.onCollapsed,
  });

  @override
  State<ExpandableResponseCard> createState() => _ExpandableResponseCardState();
}

class _ExpandableResponseCardState extends State<ExpandableResponseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: AppConstants.defaultAnimationDuration,
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

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;

    return Container(
      margin:
          const EdgeInsets.symmetric(vertical: AppConstants.defaultSpacing / 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
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
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
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
          const SizedBox(
              height: AppConstants.defaultSpacing +
                  AppConstants.defaultSpacing / 2),
          _buildDetailRow('Date', widget.response.date),
          _buildDetailRow('Rotation', widget.response.rotation),
          _buildDetailRow('Attending', widget.response.attending),

          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'Survey Responses',
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSecondary,
            ),
          ),
          const SizedBox(
              height: AppConstants.defaultSpacing +
                  AppConstants.defaultSpacing / 2),

          // Display each question and its response (excluding standard fields)
          ...() {
            final sortedEntries =
                widget.response.questionResponses.entries.toList()
                  ..sort((a, b) {
                    // Custom sort for question IDs like "3-", "400-", "5-"
                    final aNum = int.tryParse(a.key.split('-').first) ?? 0;
                    final bNum = int.tryParse(b.key.split('-').first) ?? 0;
                    return aNum.compareTo(bNum);
                  });

            return sortedEntries.map((entry) {
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
            });
          }(),
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
      margin: const EdgeInsets.symmetric(
        vertical: AppConstants.defaultSpacing / 2,
        horizontal: AppConstants.defaultSpacing,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(AppConstants.defaultSpacing),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
            AppConstants.defaultSpacing + AppConstants.defaultSpacing / 2),
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
            const SizedBox(height: AppConstants.defaultSpacing),
            Text(
              responseValue.isEmpty ? 'No response provided' : responseValue,
              style: theme.textTheme.displayLarge?.copyWith(
                color: responseValue.isEmpty
                    ? theme.colorScheme.shadow
                    : theme.colorScheme.onSecondary,
                fontStyle:
                    responseValue.isEmpty ? FontStyle.italic : FontStyle.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
