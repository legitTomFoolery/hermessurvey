import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:gsecsurvey/features/home/data/models/question_model.dart';
import 'package:gsecsurvey/features/admin/presentation/widgets/cards/expandable_question_card.dart';
import 'package:gsecsurvey/features/admin/presentation/widgets/modals/question_modal.dart';
import 'package:gsecsurvey/shared/data/services/firestore_service.dart';
import 'package:gsecsurvey/shared/presentation/widgets/common_widgets.dart';
import 'package:gsecsurvey/app/config/routes.dart';

class QuestionManagementScreen extends StatefulWidget {
  const QuestionManagementScreen({super.key});

  @override
  State<QuestionManagementScreen> createState() =>
      _QuestionManagementScreenState();
}

class _QuestionManagementScreenState extends State<QuestionManagementScreen> {
  List<Question> _questions = [];
  bool _isLoading = true;
  String? _expandedQuestionId;
  bool _showFloatingButton = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _setupScrollListener();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_showFloatingButton) {
          setState(() {
            _showFloatingButton = false;
          });
        }
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_showFloatingButton) {
          setState(() {
            _showFloatingButton = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final questionsSnapshot = await FirestoreService.getQuestionsOnce();
      final questions =
          questionsSnapshot.docs.map((doc) => doc.data()).toList();

      // Sort questions by order (extracted from ID)
      questions.sort((a, b) {
        final aOrder = int.tryParse(a.id.split('-').first) ?? 0;
        final bOrder = int.tryParse(b.id.split('-').first) ?? 0;
        return aOrder.compareTo(bOrder);
      });

      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading questions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addNewQuestion() {
    showDialog(
      context: context,
      builder: (context) => QuestionModal(
        onSave: _loadQuestions,
      ),
    );
  }

  void _onQuestionExpanded(String questionId) {
    setState(() {
      _expandedQuestionId = questionId;
    });
  }

  void _onQuestionCollapsed() {
    setState(() {
      _expandedQuestionId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;

    return Scaffold(
      backgroundColor: theme.colorScheme.tertiary,
      body: RefreshIndicator(
        onRefresh: _loadQuestions,
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              )
            : _questions.isEmpty
                ? _buildEmptyState()
                : _buildQuestionsList(),
      ),
      floatingActionButton: _showFloatingButton
          ? CommonWidgets.buildFloatingActionButton(
              context: context,
              onPressed: _addNewQuestion,
              icon: Icons.add,
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    final theme = AdaptiveTheme.of(context).theme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 64,
            color: theme.colorScheme.shadow,
          ),
          const SizedBox(height: 16),
          Text(
            'No questions found',
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: 18,
              color: theme.colorScheme.shadow,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to create your first question',
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: 14,
              color: theme.colorScheme.shadow,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsList() {
    final theme = AdaptiveTheme.of(context).theme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _questions.length + 1, // +1 for the preview button
        itemBuilder: (context, index) {
          if (index == 0) {
            // Preview Survey Button as first item
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: CommonWidgets.buildElevatedButton(
                context: context,
                text: 'Preview Survey',
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.homeScreen);
                },
                backgroundColor: theme.colorScheme.secondary,
                textColor: theme.colorScheme.onSecondary,
              ),
            );
          } else {
            // Questions (index - 1 because button takes index 0)
            final question = _questions[index - 1];
            return ExpandableQuestionCard(
              question: question,
              onSave: _loadQuestions,
              isExpanded: _expandedQuestionId == question.id,
              onExpanded: () => _onQuestionExpanded(question.id),
              onCollapsed: _onQuestionCollapsed,
            );
          }
        },
      ),
    );
  }
}
