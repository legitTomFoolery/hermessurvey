import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
    return Scaffold(
      body: _buildContent(context),
      floatingActionButton: _showFloatingButton
          ? FloatingActionButton(
              onPressed: () {
                showQuestionModal(context, null);
              },
              shape: const CircleBorder(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return const LoadingView();
    }

    if (_questions.isEmpty) {
      return const Center(
        child: Text(
          'No questions found',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadQuestions,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _questions.length,
        itemBuilder: (context, index) {
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
              return await AdminUtils.showConfirmationDialog(
                context: context,
                title: 'Confirm Deletion',
                content:
                    'Are you sure you want to delete this question? This action cannot be undone.',
              );
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
