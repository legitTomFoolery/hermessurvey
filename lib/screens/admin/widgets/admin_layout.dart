import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gsecsurvey/logic/cubit/auth_cubit.dart';
import 'package:gsecsurvey/routing/routes.dart';

/// A common layout for admin screens with consistent styling and behavior
class AdminLayout extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  const AdminLayout({
    Key? key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
  }) : super(key: key);

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
        appBar: AppBar(
          backgroundColor: theme.colorScheme.primary,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            title,
            style: theme.textTheme.displayLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(
            color: theme.colorScheme.onPrimary,
          ),
          actions: [
            if (actions != null) ...actions!,
            IconButton(
              icon: Icon(
                Icons.logout,
                color: theme.colorScheme.onPrimary,
              ),
              onPressed: () {
                context.read<AuthCubit>().signOut();
              },
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
