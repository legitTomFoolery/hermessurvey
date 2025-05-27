import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/config/app_constants.dart';
import '../../../../shared/presentation/widgets/common_widgets.dart';
import '../../../auth/logic/auth_cubit.dart';
import '../../../../app/config/routes.dart';

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
        appBar: CommonWidgets.buildAppBar(
          context: context,
          title: AppConstants.appBarTitle,
          automaticallyImplyLeading: false,
          actions: [
            CommonWidgets.buildLogoutButton(
              context: context,
              onPressed: () => context.read<AuthCubit>().signOut(),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
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
              const SizedBox(
                  height: AppConstants.defaultPadding +
                      AppConstants.defaultSpacing / 2),
              CommonWidgets.buildElevatedButton(
                context: context,
                text: 'Submit New Response',
                onPressed: () => _submitNewResponse(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
