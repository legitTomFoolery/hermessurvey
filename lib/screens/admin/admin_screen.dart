import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:gsecsurvey/models/question.dart';
import 'package:gsecsurvey/screens/admin/utils/admin_utils.dart';
import 'package:gsecsurvey/screens/admin/widgets/loading_view.dart';
import 'package:gsecsurvey/screens/admin/widgets/question_modal.dart';
import 'package:gsecsurvey/screens/admin/widgets/expandable_question_card.dart';
import 'package:gsecsurvey/services/firestore_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _isLoading = false;
  List<Question> _questions = [];
  bool _showFloatingButton = true;
  String? _expandedQuestionId;
  final ScrollController _scrollController = ScrollController();
  bool _showNewQuestionCard = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _setupScrollListener();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      // Hide floating button when scrolling down (user swipes up)
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

  void _addNewQuestion() {
    setState(() {
      _showNewQuestionCard = true;
      _expandedQuestionId = 'new-question';
    });

    // Scroll to bottom after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onNewQuestionSaved() {
    setState(() {
      _showNewQuestionCard = false;
      _expandedQuestionId = null;
    });
    _loadQuestions();
  }

  void _onNewQuestionCancelled() {
    setState(() {
      _showNewQuestionCard = false;
      _expandedQuestionId = null;
    });
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await FirestoreService.getQuestionsOnce();
      setState(() {
        _questions = snapshot.docs.map((doc) => doc.data()).toList();
        // Sort questions by order
        _questions = AdminUtils.sortQuestionsByOrder(_questions);
      });
    } catch (e) {
      if (mounted) {
        AdminUtils.showSnackBar(
          context,
          'Error loading questions: $e',
          isError: true,
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;

    return Scaffold(
      backgroundColor: theme.colorScheme.tertiary,
      body: _buildContent(context),
      floatingActionButton: _showFloatingButton
          ? FloatingActionButton(
              onPressed: _addNewQuestion,
              backgroundColor: theme.colorScheme.primary,
              shape: const CircleBorder(),
              child: Icon(
                Icons.add,
                color: theme.colorScheme.onPrimary,
              ),
            )
          : null,
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;

    if (_isLoading) {
      return const LoadingView();
    }

    if (_questions.isEmpty && !_showNewQuestionCard) {
      return Center(
        child: Text(
          'No questions found',
          style: theme.textTheme.displayLarge?.copyWith(
            fontSize: 18,
            color: theme.colorScheme.shadow,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadQuestions,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _questions.length + (_showNewQuestionCard ? 1 : 0),
          itemBuilder: (context, index) {
            // Show new question card at the end
            if (index == _questions.length && _showNewQuestionCard) {
              return ExpandableQuestionCard(
                question: Question(
                  id: '',
                  name: '',
                  type: 'text',
                  options: [],
                ),
                onSave: _onNewQuestionSaved,
                isExpanded: _expandedQuestionId == 'new-question',
                onExpanded: () => _onQuestionExpanded('new-question'),
                onCollapsed: _onNewQuestionCancelled,
                isNewQuestion: true,
              );
            }

            final question = _questions[index];
            return Dismissible(
              key: Key(question.id),
              // Disable swipe when any card is expanded
              dismissThresholds: _expandedQuestionId != null
                  ? const {
                      DismissDirection.startToEnd: 1.0,
                      DismissDirection.endToStart: 1.0
                    }
                  : const {},
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20.0),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              secondaryBackground: Container(
                color: Colors.red,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20.0),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              confirmDismiss: (direction) async {
                // Don't allow dismiss when any card is expanded
                if (_expandedQuestionId != null) {
                  return false;
                }
                // Return true to allow dismissal - AdminUtils.deleteQuestion will handle confirmation
                return true;
              },
              onDismissed: (direction) async {
                await AdminUtils.deleteQuestion(context, question);
                _loadQuestions();
              },
              child: ExpandableQuestionCard(
                question: question,
                onSave: _loadQuestions,
                isExpanded: _expandedQuestionId == question.id,
                onExpanded: () => _onQuestionExpanded(question.id),
                onCollapsed: _onQuestionCollapsed,
              ),
            );
          },
        ),
      ),
    );
  }

  void showQuestionModal(BuildContext context, Question? question) {
    showDialog(
      context: context,
      builder: (context) => QuestionModal(
        question: question,
        onSave: () {
          _loadQuestions();
        },
      ),
    );
  }
}
