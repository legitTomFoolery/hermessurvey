import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:gsecsurvey/features/auth/presentation/widgets/login_and_signup_animated_form.dart';
import 'package:gsecsurvey/shared/presentation/widgets/progress_indicator.dart';
import 'package:gsecsurvey/features/auth/presentation/widgets/do_not_have_account.dart';
import 'package:gsecsurvey/shared/utils/helpers/app_extensions.dart';
import 'package:gsecsurvey/shared/utils/helpers/rive_animation_helper.dart';
import 'package:gsecsurvey/features/auth/logic/auth_cubit.dart';
import 'package:gsecsurvey/app/config/routes.dart';

/// Main content widget for the login page
class LoginPageContent extends StatefulWidget {
  const LoginPageContent({super.key});

  @override
  State<LoginPageContent> createState() => _LoginPageContentState();
}

class _LoginPageContentState extends State<LoginPageContent> {
  final RiveAnimationControllerHelper riveHelper =
      RiveAnimationControllerHelper();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding:
            EdgeInsets.only(left: 30.w, right: 30.w, bottom: 15.h, top: 5.h),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: BlocConsumer<AuthCubit, AuthState>(
            buildWhen: (previous, current) => previous != current,
            listenWhen: (previous, current) => previous != current,
            listener: _handleAuthStateChanges,
            builder: (context, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Gap(10.h),
                  const LoginHeader(),
                  const LoginForm(),
                  Gap(15.h),
                  const LoginFooter(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleAuthStateChanges(BuildContext context, AuthState state) async {
    final theme = AdaptiveTheme.of(context).theme;

    if (state is AuthLoading) {
      ProgressIndicaror.showProgressIndicator(context);
    } else if (state is AuthError) {
      context.pop();
      riveHelper.addFailController();
      _showErrorDialog(context, theme);
    } else if (state is UserSignIn) {
      await _handleSuccessfulSignIn(context, state);
    } else if (state is UserNotVerified) {
      riveHelper.addFailController();
      _showVerificationDialog(context, theme);
    } else if (state is IsNewUser) {
      context.pushNamedAndRemoveUntil(
        Routes.createPassword,
        predicate: (route) => false,
        arguments: [state.googleUser, state.credential],
      );
    }
  }

  void _showErrorDialog(BuildContext context, ThemeData theme) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.rightSlide,
      title: 'Error',
      desc: 'Invalid email/password, please try again.',
      btnOkText: 'OK',
      btnOkColor: theme.colorScheme.primary,
      btnOkOnPress: () {
        context.read<AuthCubit>().resetState();
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.loginScreen,
          (route) => false,
        );
      },
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
    ).show();
  }

  void _showVerificationDialog(BuildContext context, ThemeData theme) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.rightSlide,
      title: 'Email Not Verified',
      desc: 'Please check your email and verify your account.',
      btnOkText: 'OK',
      btnOkColor: theme.colorScheme.primary,
      btnOkOnPress: () {
        context.read<AuthCubit>().resetState();
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.loginScreen,
          (route) => false,
        );
      },
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
    ).show();
  }

  Future<void> _handleSuccessfulSignIn(
      BuildContext context, UserSignIn state) async {
    riveHelper.addSuccessController();
    await Future.delayed(const Duration(seconds: 2));
    riveHelper.dispose();
    if (!context.mounted) return;

    // Direct user to admin screen or home screen based on admin status
    if (state.isAdmin) {
      context.pushNamedAndRemoveUntil(
        Routes.adminScreen,
        predicate: (route) => false,
      );
    } else {
      context.pushNamedAndRemoveUntil(
        Routes.homeScreen,
        predicate: (route) => false,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<AuthCubit>(context);
  }

  @override
  void dispose() {
    riveHelper.dispose();
    super.dispose();
  }
}

/// Header section of the login page
class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;

    return Align(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GSEC Survey Login',
            style: TextStyle(
              fontSize: 28,
              color: theme.colorScheme.onSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Form section of the login page
class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return EmailAndPassword();
  }
}

/// Footer section of the login page
class LoginFooter extends StatelessWidget {
  const LoginFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const DoNotHaveAccountText(),
        Gap(20.h),
        const DeleteAccountButton(),
      ],
    );
  }
}

/// Delete account button widget
class DeleteAccountButton extends StatelessWidget {
  const DeleteAccountButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;

    return TextButton(
      onPressed: () => _launchDeleteAccountURL(context),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
      ),
      child: Text(
        'Delete my account',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: theme.textTheme.displayLarge?.color?.withOpacity(0.6) ??
              Colors.grey,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Future<void> _launchDeleteAccountURL(BuildContext context) async {
    const String url =
        'https://goodmancenter.stanford.edu/research/feedback-evaluation-app.html';
    final Uri uri = Uri.parse(url);

    try {
      if (!await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      )) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open delete account page'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
