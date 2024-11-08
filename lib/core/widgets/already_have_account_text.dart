import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

import '../../helpers/extensions.dart';
import '../../routing/routes.dart';

class AlreadyHaveAccountText extends StatelessWidget {
  const AlreadyHaveAccountText({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;
    return GestureDetector(
      onTap: () {
        context.pushNamedAndRemoveUntil(
          Routes.loginScreen,
          predicate: (route) => false,
        );
      },
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Already have an account?',
              style: TextStyle(
                fontSize: 14, // Adjusted font size
                fontWeight: FontWeight.w400, // Normal weight
                color: theme.textTheme.displayLarge?.color?.withOpacity(0.6) ??
                    Colors.grey, // Lighter text color
              ),
            ),
            TextSpan(
              text: ' Login',
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
