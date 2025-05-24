import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubit/auth_cubit.dart';
import '../../routing/routes.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is UserSignedOut) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.loginScreen,
            (Route<dynamic> route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.tertiary,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.primary,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Container(),
          title: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 200,
              ),
              child: Text(
                'Admin Dashboard',
                style: theme.textTheme.displayLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          centerTitle: true,
          actions: [
            SizedBox(
              width: 48,
              child: IconButton(
                icon: Icon(
                  Icons.logout,
                  color: theme.colorScheme.onPrimary,
                  size: 20,
                ),
                onPressed: () => context.read<AuthCubit>().signOut(),
              ),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ADMIN',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Admin Dashboard',
                style: TextStyle(
                  fontSize: 24,
                  color: theme.colorScheme.onTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
