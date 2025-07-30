import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gsecsurvey/features/auth/logic/auth_cubit.dart';
import 'package:gsecsurvey/features/admin/presentation/screens/main_admin_screen_with_bottom_nav.dart';
import 'package:gsecsurvey/features/auth/presentation/screens/create_password_screen.dart';
import 'package:gsecsurvey/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:gsecsurvey/features/home/presentation/screens/home_screen.dart';
import 'package:gsecsurvey/features/auth/presentation/screens/login_screen.dart';
import 'package:gsecsurvey/features/auth/presentation/screens/signup_screen.dart';
import 'package:gsecsurvey/features/home/presentation/screens/submission_result_screen.dart';
import 'routes.dart';

class AppRouter {
  final AuthCubit authCubit;

  AppRouter() : authCubit = AuthCubit();

  Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.forgetScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: authCubit,
            child: const ForgetScreen(),
          ),
        );

      case Routes.homeScreen:
        return MaterialPageRoute(
          builder: (context) {
            return BlocProvider.value(
              value: authCubit,
              child: const Home(),
            );
          },
        );

      case Routes.adminScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: authCubit,
            child: const MainAdminScreenWithBottomNav(),
          ),
        );

      case Routes.createPassword:
        final arguments = settings.arguments;
        if (arguments is List) {
          return MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: authCubit,
              child: CreatePassword(
                googleUser: arguments[0],
                credential: arguments[1],
              ),
            ),
          );
        }
        return _errorRoute();

      case Routes.signupScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: authCubit,
            child: const SignUpScreen(),
          ),
        );

      case Routes.loginScreen:
      case '/':
      case '/login':
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: authCubit,
            child: const LoginScreen(),
          ),
        );

      default:
        // Handle submission result screen route
        if (settings.name?.startsWith('/submission_result') == true) {
          return MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: authCubit,
              child: const SubmissionResultScreen(),
            ),
          );
        }
        return _errorRoute();
    }
  }

  Route _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Page not found'),
        ),
      ),
    );
  }

  void dispose() {
    authCubit.close();
  }
}
