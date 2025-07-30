import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import 'package:gsecsurvey/features/auth/presentation/widgets/already_have_account_text.dart';
import 'package:gsecsurvey/features/auth/presentation/widgets/login_and_signup_animated_form.dart';
import 'package:gsecsurvey/shared/utils/helpers/rive_animation_helper.dart';
import 'package:gsecsurvey/features/auth/logic/auth_cubit.dart';
import 'package:gsecsurvey/app/config/routes.dart';
import 'package:gsecsurvey/shared/presentation/widgets/responsive_scroll_wrapper.dart';
import 'package:gsecsurvey/app/config/institution_config.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final RiveAnimationControllerHelper riveHelper =
      RiveAnimationControllerHelper();

  void _showVerificationDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.rightSlide,
      title: 'Verification Email Sent',
      desc: 'Please check your email for a verification link.',
      btnOkText: 'Return to Login',
      btnOkColor: AdaptiveTheme.of(context).theme.colorScheme.primary,
      btnOkOnPress: () {
        Navigator.of(context).pushReplacementNamed(Routes.loginScreen);
      },
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;

    return Scaffold(
      backgroundColor: theme.colorScheme.secondary,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: ResponsiveScrollWrapper(
          padding: const EdgeInsets.only(
              left: 30.0, right: 30.0, bottom: 15.0, top: 5.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  50.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  InstitutionConfig.signupTitle,
                  style: TextStyle(
                    fontSize: 28,
                    color: theme.colorScheme.onSecondary,
                  ),
                ),
                BlocConsumer<AuthCubit, AuthState>(
                  buildWhen: (previous, current) => previous != current,
                  listenWhen: (previous, current) => previous != current,
                  listener: (context, state) {
                    if (state is UserSingupButNotVerified) {
                      _showVerificationDialog();
                    } else if (state is ExistingEmailNotVerified) {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.info,
                        animType: AnimType.rightSlide,
                        title: 'Email Already Registered',
                        desc:
                            'This email has been registered but not yet verified. Please check your email for the verification link.',
                        btnOkText: 'Return to Login',
                        btnOkOnPress: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            Routes.loginScreen,
                            (route) => false,
                          );
                        },
                        dismissOnTouchOutside: false,
                        dismissOnBackKeyPress: false,
                        btnOkColor: theme.colorScheme.primary,
                      ).show();
                    } else if (state is AuthError) {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.error,
                        animType: AnimType.rightSlide,
                        title: 'Error',
                        desc: state.message,
                        btnOkOnPress: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            Routes.signupScreen,
                            (route) => false,
                          );
                        },
                        dismissOnTouchOutside: false,
                        dismissOnBackKeyPress: false,
                        btnOkColor: theme.colorScheme.primary,
                      ).show();
                    }
                  },
                  builder: (context, state) {
                    return Column(
                      children: [
                        EmailAndPassword(isSignUpPage: true),
                        const Gap(15.0),
                        const AlreadyHaveAccountText(),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<AuthCubit>(context);
  }
}
