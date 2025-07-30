import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:gsecsurvey/theme/colors.dart';

class PasswordValidations extends StatelessWidget {
  final bool hasMinLength;
  const PasswordValidations({super.key, required this.hasMinLength});

  @override
  Widget build(BuildContext context) {
    return buildValidationRow('At least 6 characters', hasMinLength, context);
  }

  Widget buildValidationRow(
      String text, bool hasValidated, BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;

    return Row(
      children: [
        const CircleAvatar(
          radius: 2.5,
          backgroundColor: ColorsManager.gray,
        ),
        const Gap(6.0),
        Text(
          text,
          style: TextStyle(
            fontSize: 14, // Adjusted font size
            fontWeight: FontWeight.w400, // Normal weight
            color:
                theme.textTheme.displayLarge?.color?.withValues(alpha: 0.6) ??
                    Colors.grey, // Lighter text color
          ).copyWith(
            decoration: hasValidated ? TextDecoration.lineThrough : null,
            decorationColor: Colors.green,
            decorationThickness: 2,
            color: hasValidated ? ColorsManager.gray : ColorsManager.darkBlue,
          ),
        )
      ],
    );
  }
}
