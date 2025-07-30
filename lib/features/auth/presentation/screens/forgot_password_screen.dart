import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

import 'package:gsecsurvey/features/auth/presentation/widgets/already_have_account_text.dart';
import 'package:gsecsurvey/features/auth/presentation/widgets/password_reset.dart';
import 'package:gsecsurvey/features/auth/logic/auth_cubit.dart';
import 'package:gsecsurvey/app/config/routes.dart';
import 'package:gsecsurvey/shared/presentation/widgets/responsive_scroll_wrapper.dart';

class ForgetScreen extends StatefulWidget {
  const ForgetScreen({super.key});

  @override
  State<ForgetScreen> createState() => _ForgetScreenState();
}

class _ForgetScreenState extends State<ForgetScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;

    return Scaffold(
      backgroundColor: theme.colorScheme.secondary,
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
                  'Reset',
                  style: TextStyle(
                    fontSize: 28,
                    color: theme.colorScheme.onSecondary,
                  ),
                ),
                const Gap(10.0),
                Text(
                  "Enter email to reset password",
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.shadow,
                  ),
                ),
                const Gap(20.0),
                BlocConsumer<AuthCubit, AuthState>(
                  listenWhen: (previous, current) => previous != current,
                  listener: (context, state) async {
                    if (state is AuthError) {
                      await AwesomeDialog(
                        context: context,
                        dialogType: DialogType.error,
                        animType: AnimType.rightSlide,
                        title: 'Error',
                        desc: state.message,
                        btnOkColor: theme.colorScheme.primary,
                      ).show();
                    } else if (state is ResetPasswordSent) {
                      await AwesomeDialog(
                        context: context,
                        dialogType: DialogType.info,
                        animType: AnimType.rightSlide,
                        title: 'Reset Password',
                        desc:
                            'Link to reset password sent to your email, please check your inbox.',
                        dismissOnTouchOutside: false,
                        dismissOnBackKeyPress: false,
                        btnOkText: 'OK',
                        btnOkColor: theme.colorScheme.primary,
                        btnOkOnPress: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            Routes.loginScreen,
                            (Route<dynamic> route) => false,
                          );
                        },
                      ).show();
                    }
                  },
                  buildWhen: (previous, current) {
                    return previous != current;
                  },
                  builder: (context, state) {
                    return const Column(
                      children: [
                        PasswordReset(),
                        Gap(24.0),
                        AlreadyHaveAccountText(),
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
  }
}
