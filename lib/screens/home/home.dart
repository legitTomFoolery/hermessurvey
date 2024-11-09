import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:gsecsurvey/screens/home/question_card.dart';
import 'package:gsecsurvey/screens/home/submission_result_screen.dart';
import 'package:gsecsurvey/services/question_store.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map<String, String> responses = {};
  bool isOnline = false;

  @override
  void initState() {
    super.initState();
    Provider.of<QuestionStore>(context, listen: false).fetchQuestionsOnce();
    _checkConnectivity();
  }

  void _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    _updateConnectionStatus(connectivityResult);
    Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    setState(() {
      isOnline = result != ConnectivityResult.none;
    });
  }

  void _uploadResponses() async {
    if (_allQuestionsAnswered()) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        String userEmail =
            user.email!; // Safely use the email as it's non-null here

        // Reference to the user's document in the `userSubmissions` collection
        DocumentReference userDoc = FirebaseFirestore.instance
            .collection('userSubmissions')
            .doc(userEmail);

        FirebaseFirestore.instance.runTransaction((transaction) async {
          // Get the document
          DocumentSnapshot snapshot = await transaction.get(userDoc);

          // Check if document exists
          if (snapshot.exists) {
            // Increment the submission count
            int currentCount = snapshot.get('submissionCount') as int;
            transaction.update(userDoc, {'submissionCount': currentCount + 1});
          } else {
            // Create the document with submissionCount set to 1
            transaction.set(userDoc, {'submissionCount': 1});
          }
        }).then((value) {
          // Continue with your existing code to upload responses
          FirebaseFirestore.instance.collection('surveyResponses').add({
            'responses': responses,
            'timestamp': FieldValue.serverTimestamp(),
          }).then((value) {
            setState(() {
              responses.clear();
            });
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SubmissionResultScreen(),
              ),
            );
          }).catchError((error) {
            print("Failed to upload responses: $error");
          });
        }).catchError((error) {
          print("Failed to update submission count: $error");
        });
      } else {
        // Handle the case where there is no user or email is not available
        print("No user logged in or email not available");
      }
    }
  }

  void _showConnectivityError() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text('You need to be online to submit the responses.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;

    return Scaffold(
      backgroundColor: theme.colorScheme.tertiary,
      appBar: AppBar(
        title: Text(
          'Feedback Evaluation Tool',
          style: theme.textTheme.displayLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Consumer<QuestionStore>(
                builder: (context, questionStore, child) {
                  return ListView.builder(
                    itemCount: questionStore.questions.length,
                    itemBuilder: (context, index) {
                      final question = questionStore.questions[index];
                      return QuestionCard(
                        question: question,
                        onResponse: _updateResponse,
                        initialResponse: responses[question.id],
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Container(
            width: double.infinity,
            color: theme.colorScheme.secondary,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildProgressBar(theme),
                _buildSubmitButton(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(ThemeData theme) {
    final totalQuestions = context
        .read<QuestionStore>()
        .questions
        .where((q) => q.type != 'text')
        .length;
    final answeredQuestions = responses.keys.where((id) {
      final question =
          context.read<QuestionStore>().questions.firstWhere((q) => q.id == id);
      return question.type != 'text';
    }).length;
    final progress =
        totalQuestions > 0 ? answeredQuestions / totalQuestions : 0.0;

    return LinearProgressIndicator(
      value: progress,
      backgroundColor: theme.colorScheme.tertiary,
      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
      minHeight: 5.0,
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    final allAnswered = _allQuestionsAnswered();
    final totalQuestions = context
        .read<QuestionStore>()
        .questions
        .where((q) => q.type != 'text')
        .length;
    final answeredQuestions = responses.keys.where((id) {
      final question =
          context.read<QuestionStore>().questions.firstWhere((q) => q.id == id);
      return question.type != 'text';
    }).length;
    final progress =
        totalQuestions > 0 ? (answeredQuestions / totalQuestions) * 100 : 0;

    String buttonText = allAnswered
        ? 'Submit Responses'
        : '${progress.toStringAsFixed(0)}% Completed';
    if (allAnswered && !isOnline) {
      buttonText = 'No Internet';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: allAnswered && isOnline ? _uploadResponses : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: allAnswered && isOnline
              ? theme.colorScheme.primary
              : theme.colorScheme.tertiary,
          disabledBackgroundColor: theme.colorScheme.tertiary,
        ),
        child: Text(
          buttonText,
          style: TextStyle(color: theme.colorScheme.onPrimary),
        ),
      ),
    );
  }

  bool _allQuestionsAnswered() {
    final totalQuestions = context
        .read<QuestionStore>()
        .questions
        .where((q) => q.type != 'text')
        .length;
    final answeredQuestions = responses.keys.where((id) {
      final question =
          context.read<QuestionStore>().questions.firstWhere((q) => q.id == id);
      return question.type != 'text';
    }).length;
    return totalQuestions > 0 && answeredQuestions == totalQuestions;
  }

  void _updateResponse(String questionId, String response) {
    setState(() {
      responses[questionId] = response;
    });
  }
}
