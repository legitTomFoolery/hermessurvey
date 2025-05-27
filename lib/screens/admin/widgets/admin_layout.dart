import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/common_widgets.dart';
import '../../../logic/cubit/auth_cubit.dart';
import '../../../routing/routes.dart';

/// A common layout for admin screens with consistent styling and behavior
class AdminLayout extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  const AdminLayout({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is UserSignedOut) {
          Navigator.of(context).pushReplacementNamed(Routes.loginScreen);
        }
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.tertiary,
        appBar: CommonWidgets.buildAppBar(
          context: context,
          title: title,
          actions: [
            if (actions != null) ...actions!,
            CommonWidgets.buildLogoutButton(
              context: context,
              onPressed: () => context.read<AuthCubit>().signOut(),
            ),
          ],
        ),
        body: body,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}
