import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import '../../helpers/extensions.dart';
import '../../routing/routes.dart';

class DoNotHaveAccountText extends StatelessWidget {
  const DoNotHaveAccountText({super.key});

  @override
  Widget build(BuildContext context) {
    // Accessing the current theme data using AdaptiveTheme
    final theme = AdaptiveTheme.of(context).theme;

    return GestureDetector(
      onTap: () {
        context.pushNamed(Routes.signupScreen);
      },
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Don\'t have an account yet?',
              style: TextStyle(
                fontSize: 14, // Adjusted font size
                fontWeight: FontWeight.w400, // Normal weight
                color: theme.textTheme.displayLarge?.color?.withOpacity(0.6) ??
                    Colors.grey, // Lighter text color
              ),
            ),
            TextSpan(
              text: ' Sign Up',
              style: TextStyle(
                fontSize: 14, // Consistent font size
                fontWeight: FontWeight.w600, // Bolder for emphasis
                color: theme.colorScheme
                    .primary, // Secondary color for interactive elements
              ),
            ),
          ],
        ),
      ),
    );
  }
}
