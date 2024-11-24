import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../logic/cubit/auth_cubit.dart';
import '../screens/create_password/ui/create_password.dart';
import '../screens/forget/ui/forget_screen.dart';
import '../screens/home/home.dart';
import '../screens/login/ui/login_screen.dart';
import '../screens/signup/ui/sign_up_sceen.dart';
import '../services/question_store.dart';
import 'routes.dart';

class AppRouter {
  late AuthCubit authCubit;

  AppRouter() {
    authCubit = AuthCubit();
  }

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
            // Reset QuestionStore when navigating to home
            Provider.of<QuestionStore>(context, listen: false).reset();
            return BlocProvider.value(
              value: authCubit,
              child: const Home(),
            );
          },
          maintainState: false,
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
