import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

import 'package:gsecsurvey/app/config/app_constants.dart';
import 'package:gsecsurvey/shared/presentation/widgets/common_widgets.dart';
import 'package:gsecsurvey/features/home/data/models/question_model.dart';
import 'package:gsecsurvey/shared/utils/typedefs.dart';
import 'question_response_widget.dart';

/// A card widget that displays a question and its response input
class QuestionCard extends StatelessWidget {
  final Question question;
  final QuestionResponseCallback onResponse;
  final String? initialResponse;

  const QuestionCard({
    super.key,
    required this.question,
    required this.onResponse,
    this.initialResponse,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: CommonWidgets.buildCard(
        context: context,
        margin: const EdgeInsets.symmetric(
          vertical: AppConstants.defaultSpacing / 2,
        ),
        child: Column(
          children: [
            QuestionTitle(question: question),
            const SizedBox(height: AppConstants.defaultSpacing / 2),
            QuestionResponseWidget(
              question: question,
              onResponse: onResponse,
              initialResponse: initialResponse,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget that displays the question title
class QuestionTitle extends StatelessWidget {
  final Question question;

  const QuestionTitle({
    super.key,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;

    return Center(
      child: Text(
        question.name,
        style: theme.textTheme.displayLarge?.copyWith(
          color: theme.colorScheme.onSecondary,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
