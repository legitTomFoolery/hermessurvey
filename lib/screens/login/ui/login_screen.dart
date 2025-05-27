import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/login_and_signup_animated_form.dart';
import '../../../core/widgets/no_internet.dart';
import '../../../core/widgets/progress_indicator.dart';
import '../../../core/widgets/do_not_have_account.dart';
import '../../../helpers/extensions.dart';
import '../../../helpers/rive_controller.dart';
import '../../../logic/cubit/auth_cubit.dart';
import '../../../routing/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final RiveAnimationControllerHelper riveHelper =
      RiveAnimationControllerHelper();

  Future<void> _launchDeleteAccountURL() async {
    final Uri url = Uri.parse(
        'https://goodmancenter.stanford.edu/research/feedback-evaluation-app.html');
    try {
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      )) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open delete account page'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;

    return Scaffold(
      backgroundColor: theme.colorScheme.secondary,
      resizeToAvoidBottomInset: false,
      body: OfflineBuilder(
        connectivityBuilder: (
          BuildContext context,
          ConnectivityResult connectivity,
          Widget child,
        ) {
          final bool connected = connectivity != ConnectivityResult.none;
          return connected
              ? _loginPage(context, theme)
              : const BuildNoInternet();
        },
        child: CommonWidgets.buildLoadingIndicator(
          context: context,
          message: 'Checking connection...',
        ),
      ),
    );
  }

  SafeArea _loginPage(BuildContext context, ThemeData theme) {
    return SafeArea(
      child: Padding(
        padding:
            EdgeInsets.only(left: 30.w, right: 30.w, bottom: 15.h, top: 5.h),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: BlocConsumer<AuthCubit, AuthState>(
            buildWhen: (previous, current) => previous != current,
            listenWhen: (previous, current) => previous != current,
            listener: (context, state) async {
              if (state is AuthLoading) {
                ProgressIndicaror.showProgressIndicator(context);
              } else if (state is AuthError) {
                context.pop();
                riveHelper.addFailController();
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
              } else if (state is UserSignIn) {
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
              } else if (state is UserNotVerified) {
                riveHelper.addFailController();
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
              } else if (state is IsNewUser) {
                context.pushNamedAndRemoveUntil(
                  Routes.createPassword,
                  predicate: (route) => false,
                  arguments: [state.googleUser, state.credential],
                );
              }
            },
            builder: (context, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Gap(10.h),
                  Align(
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
                  ),
                  EmailAndPassword(),
                  Gap(15.h),
                  const DoNotHaveAccountText(),
                  Gap(20.h),
                  TextButton(
                    onPressed: _launchDeleteAccountURL,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                    ),
                    child: Text(
                      'Delete my account',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: theme.textTheme.displayLarge?.color
                                ?.withOpacity(0.6) ??
                            Colors.grey,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              );
            },
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
