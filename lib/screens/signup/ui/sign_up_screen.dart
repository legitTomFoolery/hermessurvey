import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import '../../../core/widgets/already_have_account_text.dart';
import '../../../core/widgets/login_and_signup_animated_form.dart';
import '../../../helpers/rive_controller.dart';
import '../../../logic/cubit/auth_cubit.dart';
import '../../../routing/routes.dart';

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
        child: Padding(
          padding:
              EdgeInsets.only(left: 30.w, right: 30.w, bottom: 15.h, top: 5.h),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'GSEC Survey Signup',
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
                      ).show();
                    } else if (state is AuthError) {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.error,
                        animType: AnimType.rightSlide,
                        title: 'Error',
                        desc: state.message,
                        btnOkText: 'OK',
                        btnOkOnPress: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            Routes.signupScreen,
                            (route) => false,
                          );
                        },
                        dismissOnTouchOutside: false,
                        dismissOnBackKeyPress: false,
                      ).show();
                    }
                  },
                  builder: (context, state) {
                    return Column(
                      children: [
                        EmailAndPassword(isSignUpPage: true),
                        Gap(15.h),
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
