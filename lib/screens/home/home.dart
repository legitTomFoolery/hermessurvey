import 'dart:async';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gsecsurvey/core/environment_config.dart';
import 'package:gsecsurvey/screens/home/question_card.dart';
import 'package:gsecsurvey/services/question_store.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../logic/cubit/auth_cubit.dart';
import '../../routing/routes.dart';
import '../../widgets/account_not_exists_popup.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Map<String, String> responses = {};
  bool isOnline = false;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isInitialized = false;
  final _envConfig = EnvironmentConfig();

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeQuestions();
      _isInitialized = true;
    }
  }

  void _initializeQuestions() {
    final questionStore = Provider.of<QuestionStore>(context, listen: false);
    questionStore.reset();
    questionStore.fetchQuestionsOnce();
  }

  void _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    _updateConnectionStatus(connectivityResult);
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    if (!mounted) return;
    setState(() {
      isOnline = result != ConnectivityResult.none;
    });
  }

  Future<void> _checkAccountAndProceed() async {
    final authCubit = context.read<AuthCubit>();
    bool accountExists = await authCubit.checkUserAccountExists();

    if (!accountExists) {
      if (!mounted) return;
      // Capture the BuildContext with AuthCubit access
      final currentContext = context;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AccountNotExistsPopup(
          onLogout: () => currentContext.read<AuthCubit>().signOut(),
        ),
      );
    } else {
      _uploadResponses();
    }
  }

  void _uploadResponses() async {
    if (_allQuestionsAnswered()) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        String userEmail = user.email!;

        DocumentReference userDoc = FirebaseFirestore.instance
            .collection(_envConfig.getCollectionName('userSubmissions'))
            .doc(userEmail);

        FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(userDoc);

          if (snapshot.exists) {
            int currentCount = snapshot.get('submissionCount') as int;
            transaction.update(userDoc, {'submissionCount': currentCount + 1});
          } else {
            transaction.set(userDoc, {'submissionCount': 1});
          }
        }).then((value) {
          FirebaseFirestore.instance
              .collection(_envConfig.getCollectionName('surveyResponses'))
              .add({
            'responses': responses,
            'timestamp': FieldValue.serverTimestamp(),
          }).then((value) {
            setState(() {
              responses.clear();
            });
            if (!mounted) return;
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/submission_result',
              (Route<dynamic> route) => false,
            );
          }).catchError((error) {
            // Failed to upload responses: $error
          });
        }).catchError((error) {
          // Failed to update submission count: $error
        });
      } else {
        // No user logged in or email not available
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is UserSignedOut) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.loginScreen,
            (Route<dynamic> route) => false,
          );
        }
      },
      child: GestureDetector(
        onTap: () {
          // Dismiss keyboard and unfocus any text fields when tapping outside
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: theme.colorScheme.tertiary,
          appBar: AppBar(
            backgroundColor: theme.colorScheme.primary,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: Container(),
            title: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 200,
                ),
                child: Text(
                  'Feedback Evaluation Tool',
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 22,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            centerTitle: true,
            actions: [
              SizedBox(
                width: 48,
                child: IconButton(
                  icon: Icon(
                    Icons.logout,
                    color: theme.colorScheme.onPrimary,
                    size: 20,
                  ),
                  onPressed: () => context.read<AuthCubit>().signOut(),
                ),
              ),
            ],
          ),
          body: Consumer<QuestionStore>(
            builder: (context, questionStore, child) {
              return Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ListView.builder(
                        key: const PageStorageKey('question_list'),
                        itemCount: questionStore.questions.length,
                        itemBuilder: (context, index) {
                          final question = questionStore.questions[index];
                          return QuestionCard(
                            key: ValueKey(question.id),
                            question: question,
                            onResponse: _updateResponse,
                            initialResponse: responses[question.id],
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
              );
            },
          ),
        ),
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
        onPressed: allAnswered && isOnline ? _checkAccountAndProceed : null,
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

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
