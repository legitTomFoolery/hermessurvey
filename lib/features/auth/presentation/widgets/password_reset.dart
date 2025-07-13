import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:gsecsurvey/shared/utils/helpers/app_regex.dart';
import 'package:gsecsurvey/shared/presentation/widgets/app_text_button.dart';
import 'package:gsecsurvey/shared/presentation/widgets/app_text_form_field.dart';
import 'package:gsecsurvey/features/auth/logic/auth_cubit.dart';

class PasswordReset extends StatefulWidget {
  const PasswordReset({super.key});

  @override
  State<PasswordReset> createState() => _PasswordResetState();
}

class _PasswordResetState extends State<PasswordReset> {
  TextEditingController emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          emailField(),
          const Gap(30.0),
          resetButton(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  AppTextFormField emailField() {
    return AppTextFormField(
      hint: 'Email',
      validator: (value) {
        String email = (value ?? '').trim();

        emailController.text = email;

        if (email.isEmpty) {
          return 'Please enter an email address';
        }

        if (!AppRegex.isEmailValid(email)) {
          return 'Please enter a valid email address';
        }
      },
      controller: emailController,
    );
  }

  AppTextButton resetButton() {
    final theme = AdaptiveTheme.of(context).theme;

    return AppTextButton(
      buttonText: 'Reset',
      textStyle: TextStyle(
        fontSize: 16, // Consistent font size
        color: theme
            .colorScheme.onPrimary, // Secondary color for interactive elements
      ),
      onPressed: () {
        if (formKey.currentState!.validate()) {
          context.read<AuthCubit>().resetPassword(emailController.text);
        }
      },
    );
  }
}
