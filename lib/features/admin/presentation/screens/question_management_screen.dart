import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:gsecsurvey/features/home/data/models/question_model.dart';
import 'package:gsecsurvey/features/admin/presentation/widgets/cards/expandable_question_card.dart';
import 'package:gsecsurvey/shared/data/services/firestore_service.dart';
import 'package:gsecsurvey/shared/presentation/widgets/common_widgets.dart';
import 'package:gsecsurvey/shared/presentation/widgets/swipe_to_delete_wrapper.dart';
import 'package:gsecsurvey/app/config/routes.dart';
import 'package:gsecsurvey/shared/presentation/widgets/responsive_wrapper.dart';

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
  bool _isAddingNewQuestion = false;
  Question? _newQuestion;
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
        // Reset new question state when reloading
        _isAddingNewQuestion = false;
        _newQuestion = null;
        _expandedQuestionId = null;
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
    // Create a new empty question
    final newQuestion = Question(
      id: '', // Will be filled in by the user
      name: '',
      type: '', // No default type - user must select
      options: [],
      rotationDetails: null,
    );

    setState(() {
      _isAddingNewQuestion = true;
      _newQuestion = newQuestion;
      _expandedQuestionId = 'new_question';
    });

    // Wait for the card to be added and expanded before scrolling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Wait longer for the expansion animation to complete
      Future.delayed(const Duration(milliseconds: 400), () {
        if (_scrollController.hasClients) {
          // Force a rebuild to get the updated scroll extent
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
              );
            }
          });
        }
      });
    });
  }

  void _onQuestionExpanded(String questionId) {
    setState(() {
      _expandedQuestionId = questionId;
    });
  }

  void _onQuestionCollapsed() {
    setState(() {
      _expandedQuestionId = null;
      // If we were adding a new question, reset the state
      if (_isAddingNewQuestion) {
        _isAddingNewQuestion = false;
        _newQuestion = null;
      }
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
            : _questions.isEmpty && !_isAddingNewQuestion
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

    // Calculate total items: preview button + existing questions + new question (if adding)
    final totalItems = 1 + _questions.length + (_isAddingNewQuestion ? 1 : 0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: totalItems,
        itemBuilder: (context, index) {
          if (index == 0) {
            // Preview Survey Button as first item
            return ResponsiveWrapper(
              child: Padding(
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
              ),
            );
          } else if (index <= _questions.length) {
            // Existing questions (index - 1 because button takes index 0)
            final question = _questions[index - 1];
            return ResponsiveWrapper(
              child: SwipeToDeleteWrapper(
                dismissibleKey: Key(question.id),
                deleteDialogTitle: 'Delete Question',
                deleteDialogContent:
                    'Are you sure you want to delete the question "${question.name}"? This action cannot be undone.',
                shouldDisableDismissal: () => _expandedQuestionId != null,
                onDelete: () async {
                  await FirestoreService.deleteQuestion(question);
                },
                onDeleteSuccess: _loadQuestions,
                successMessage: 'Question deleted successfully',
                child: ExpandableQuestionCard(
                  question: question,
                  onSave: _loadQuestions,
                  isExpanded: _expandedQuestionId == question.id,
                  onExpanded: () => _onQuestionExpanded(question.id),
                  onCollapsed: _onQuestionCollapsed,
                ),
              ),
            );
          } else {
            // New question card (last item when adding)
            return ResponsiveWrapper(
              child: ExpandableQuestionCard(
                question: _newQuestion!,
                onSave: _loadQuestions,
                isExpanded: _expandedQuestionId == 'new_question',
                onExpanded: () => _onQuestionExpanded('new_question'),
                onCollapsed: _onQuestionCollapsed,
                isNewQuestion: true,
              ),
            );
          }
        },
      ),
    );
  }
}
