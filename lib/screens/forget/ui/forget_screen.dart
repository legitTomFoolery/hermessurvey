import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

import '../../../core/widgets/already_have_account_text.dart';
import '../../../core/widgets/password_reset.dart';
import '../../../logic/cubit/auth_cubit.dart';
import '../../../routing/routes.dart';

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
        child: Padding(
          padding:
              EdgeInsets.only(left: 30.w, right: 30.w, bottom: 15.h, top: 5.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Reset',
                  style: TextStyle(
                    fontSize: 28,
                    color: theme.colorScheme.onSecondary,
                  ),
                ),
                Gap(10.h),
                Text(
                  "Enter email to reset password",
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.shadow,
                  ),
                ),
                Gap(20.h),
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
                    return Column(
                      children: [
                        const PasswordReset(),
                        Gap(24.h),
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
  }
}
