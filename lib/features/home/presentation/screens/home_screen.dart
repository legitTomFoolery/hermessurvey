import 'dart:async';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:gsecsurvey/app/config/environment_config.dart';
import 'package:gsecsurvey/shared/presentation/widgets/common_widgets.dart';
import 'package:gsecsurvey/app/config/app_constants.dart';
import 'package:gsecsurvey/features/home/data/services/question_store.dart';
import 'package:gsecsurvey/features/auth/logic/auth_cubit.dart';
import 'package:gsecsurvey/app/config/routes.dart';
import 'package:gsecsurvey/shared/presentation/widgets/account_not_exists_popup.dart';
import 'package:gsecsurvey/features/home/presentation/widgets/question_card.dart';
import 'package:gsecsurvey/shared/data/services/user_service.dart';
import 'package:gsecsurvey/shared/presentation/widgets/responsive_wrapper.dart';

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
  bool _isAdmin = false;
  final _envConfig = EnvironmentConfig();

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _checkAdminStatus();
  }

  void _checkAdminStatus() async {
    final isAdmin = await UserService.isCurrentUserAdmin();
    if (mounted) {
      setState(() {
        _isAdmin = isAdmin;
      });
    }
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
    // Use post-frame callback to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final questionStore =
            Provider.of<QuestionStore>(context, listen: false);
        // Always reset and fetch when home screen initializes
        // This ensures fresh questions whether coming from login or app resume
        questionStore.reset();
        questionStore.fetchQuestionsOnce();
      }
    });
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
          appBar: CommonWidgets.buildAppBar(
            context: context,
            title: AppConstants.appBarTitle,
            automaticallyImplyLeading: _isAdmin,
            leading: _isAdmin
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                : null,
            actions: [
              CommonWidgets.buildLogoutButton(
                context: context,
                onPressed: () => context.read<AuthCubit>().signOut(),
              ),
            ],
          ),
          body: ResponsiveWrapper(
            child: Consumer<QuestionStore>(
              builder: (context, questionStore, child) {
                // Always show the questions list - no loading spinner
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

    return CommonWidgets.buildProgressBar(
      context: context,
      progress: progress,
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
        ? AppConstants.submitResponses
        : '${progress.toStringAsFixed(0)}${AppConstants.completedSuffix}';
    if (allAnswered && !isOnline) {
      buttonText = AppConstants.noInternet;
    }
    if (_isAdmin) {
      buttonText = 'Preview Mode - Cannot Submit';
    }

    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: AppConstants.defaultSpacing),
      child: CommonWidgets.buildElevatedButton(
        context: context,
        text: buttonText,
        onPressed: allAnswered && isOnline && !_isAdmin
            ? _checkAccountAndProceed
            : null,
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
