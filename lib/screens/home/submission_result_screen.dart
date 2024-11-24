import 'package:flutter/material.dart';
import 'package:gsecsurvey/screens/home/home.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:provider/provider.dart';
import '../../logic/cubit/auth_cubit.dart';
import '../../routing/routes.dart';

class SubmissionResultScreen extends StatelessWidget {
  const SubmissionResultScreen({super.key});

  void _submitNewResponse(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const Home(),
        maintainState: false,
      ),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      final authCubit = context.read<AuthCubit>();
      await authCubit.signOut();

      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.loginScreen,
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;

    return Scaffold(
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
              onPressed: () => _handleLogout(context),
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
    );
  }
}
