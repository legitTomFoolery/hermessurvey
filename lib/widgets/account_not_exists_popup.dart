import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

class AccountNotExistsPopup extends StatelessWidget {
  final VoidCallback onLogout;

  const AccountNotExistsPopup({Key? key, required this.onLogout})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.scale,
        title: 'Account Does Not Exist',
        desc: 'The logged in account no longer exists.',
        btnOkText: 'Log Out',
        btnOkColor: AdaptiveTheme.of(context).theme.colorScheme.primary,
        dismissOnTouchOutside: false,
        dismissOnBackKeyPress: false,
        btnOkOnPress: onLogout, // Use the callback from parent screen's context
      ).show();
    });

    // Return an empty container since AwesomeDialog is shown post-frame
    return Container();
  }
}
