import 'package:flutter/material.dart';

class AccountNotExistsPopup extends StatelessWidget {
  final VoidCallback onLogout;

  const AccountNotExistsPopup({Key? key, required this.onLogout})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Account Does Not Exist'),
      content: const Text('The logged in account no longer exists.'),
      actions: [
        TextButton(
          child: const Text('Log Out'),
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
            onLogout(); // Call the logout function
          },
        ),
      ],
    );
  }
}
