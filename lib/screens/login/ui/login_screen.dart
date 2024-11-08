import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../../../core/widgets/login_and_signup_animated_form.dart';
import '../../../core/widgets/no_internet.dart';
import '../../../core/widgets/progress_indicator.dart';
import '../../../helpers/extensions.dart';
import '../../../helpers/rive_controller.dart';
import '../../../logic/cubit/auth_cubit.dart';
import '../../../routing/routes.dart';
import '../../../core/widgets/do_not_have_account.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final RiveAnimationControllerHelper riveHelper =
      RiveAnimationControllerHelper();

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme; // Access the adaptive theme

    return Scaffold(
      backgroundColor: theme.colorScheme.secondary, // Use theme colors
      body: OfflineBuilder(
        connectivityBuilder: (
          BuildContext context,
          ConnectivityResult
              connectivity, // Changed this from List<ConnectivityResult> to ConnectivityResult
          Widget child,
        ) {
          final bool connected = connectivity !=
              ConnectivityResult
                  .none; // Adjust this check based on the current ConnectivityResult
          return connected
              ? _loginPage(context, theme)
              : const BuildNoInternet(); // Display the no internet widget if not connected
        },
        child: Center(
          child: CircularProgressIndicator(
            color: theme.colorScheme.primary, // Use theme color
          ),
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
                  desc: state.message,
                ).show();
              } else if (state is UserSignIn) {
                riveHelper.addSuccessController();
                await Future.delayed(const Duration(seconds: 2));
                riveHelper.dispose();
                if (!context.mounted) return;
                context.pushNamedAndRemoveUntil(
                  Routes.homeScreen,
                  predicate: (route) => false,
                );
              } else if (state is UserNotVerified) {
                riveHelper.addFailController();
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.info,
                  animType: AnimType.rightSlide,
                  title: 'Email Not Verified',
                  desc: 'Please check your email and verify your email.',
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
                          'GSEC Survey Login', // Header Text
                          style: TextStyle(
                            fontSize: 28, // Larger text for the app name
                            color: theme.colorScheme.onSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  EmailAndPassword(),
                  Gap(15.h),
                  const DoNotHaveAccountText(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
