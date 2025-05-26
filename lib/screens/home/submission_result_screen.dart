import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubit/auth_cubit.dart';
import '../../routing/routes.dart';

class SubmissionResultScreen extends StatelessWidget {
  const SubmissionResultScreen({super.key});

  void _submitNewResponse(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      Routes.homeScreen,
      (Route<dynamic> route) => false,
    );
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
      child: Scaffold(
        backgroundColor: theme.colorScheme.secondary,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.primary,
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
          automaticallyImplyLeading: false,
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
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Your responses have been submitted.',
                style: theme.textTheme.displayLarge?.copyWith(
                  color: theme.colorScheme.onSecondary,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _submitNewResponse(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  disabledBackgroundColor: theme.colorScheme.tertiary,
                ),
                child: Text(
                  'Submit New Response',
                  style: TextStyle(color: theme.colorScheme.onPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
