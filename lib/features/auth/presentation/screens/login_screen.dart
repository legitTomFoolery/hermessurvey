import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';

import 'package:gsecsurvey/shared/presentation/widgets/common_widgets.dart';
import 'package:gsecsurvey/shared/presentation/widgets/no_internet.dart';
import 'package:gsecsurvey/features/auth/presentation/widgets/login_page_content.dart';

/// Login screen with offline connectivity handling
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
          return connected ? const LoginPageContent() : const BuildNoInternet();
        },
        child: CommonWidgets.buildLoadingIndicator(
          context: context,
          message: 'Checking connection...',
        ),
      ),
    );
  }
}
