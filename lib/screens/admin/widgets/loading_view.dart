import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

/// A simple loading view with a centered circular progress indicator
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;

    return Center(
      child: CircularProgressIndicator(
        color: theme.colorScheme.primary,
      ),
    );
  }
}
