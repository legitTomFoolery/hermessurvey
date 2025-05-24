import 'package:flutter/material.dart';
import 'package:gsecsurvey/models/question.dart';
import 'package:gsecsurvey/screens/admin/utils/admin_utils.dart';
import 'package:gsecsurvey/screens/admin/widgets/loading_view.dart';
import 'package:gsecsurvey/screens/admin/widgets/error_view.dart';
import 'package:gsecsurvey/screens/admin/widgets/question_modal.dart';
import 'package:gsecsurvey/services/firestore_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _isLoading = false;
  List<Question> _questions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showQuestionModal(context, null);
        },
        child: const Icon(Icons.add),
      ),
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
        itemCount: _questions.length,
        itemBuilder: (context, index) {
          final question = _questions[index];
          return Dismissible(
            key: Key(question.id),
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
            child: Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: ListTile(
                title: Text(question.name),
                subtitle: Text('Type: ${question.type} | ID: ${question.id}'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    showQuestionModal(context, question);
                  },
                ),
              ),
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
