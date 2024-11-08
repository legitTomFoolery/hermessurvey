import 'package:flutter/material.dart';
import 'package:gsecsurvey/screens/home/home.dart'; // Ensure you import Home
import 'package:adaptive_theme/adaptive_theme.dart';

class SubmissionResultScreen extends StatelessWidget {
  const SubmissionResultScreen({super.key});

  void _submitNewResponse(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Home()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;

    return Scaffold(
      backgroundColor: theme
          .colorScheme.secondary, // Set the background color of the scaffold
      appBar: AppBar(
        title: Text(
          'Feedback Evaluation Tool',
          style: theme.textTheme.displayLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontSize: 22,
          ),
          textAlign: TextAlign.center,
        ),
        automaticallyImplyLeading: false, // Remove the back arrow
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
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
                backgroundColor: theme.colorScheme
                    .primary, // Button background color when enabled
                disabledBackgroundColor: theme.colorScheme
                    .tertiary, // Button background color when disabled
              ),
              child: const Text(
                'Submit New Response',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
