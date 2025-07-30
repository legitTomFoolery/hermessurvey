import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

import 'features/home/data/services/question_store.dart';
import 'shared/data/services/response_provider.dart';
import 'shared/data/services/user_service.dart';
import 'firebase_options.dart';
import 'app/config/app_router.dart';
import 'app/config/routes.dart';
import 'theme/app_theme.dart';
import 'app/config/app_constants.dart';
import 'app/config/dependency_injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase first
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Then initialize other services that may depend on Firebase
  await Future.wait([
    preloadSVGs([AppConstants.googleLogoSvg]),
    setupDependencies(),
  ]);

  // Get the current user and check admin status for app lifecycle behavior
  final user = FirebaseAuth.instance.currentUser;
  String initialRoute = Routes.loginScreen;

  if (user != null && user.emailVerified) {
    // Check if user is admin to determine app lifecycle behavior
    bool isAdmin = await UserService.isCurrentUserAdmin();

    // For admin users, always redirect to login on app restart for security
    // For non-admin users, go to home screen
    initialRoute = isAdmin ? Routes.loginScreen : Routes.homeScreen;
  }

  runApp(MyApp(
    router: AppRouter(),
    initialRoute: initialRoute,
  ));
}

Future<void> preloadSVGs(List<String> paths) async {
  for (final path in paths) {
    final loader = SvgAssetLoader(path);
    await svg.cache.putIfAbsent(
      loader.cacheKey(null),
      () => loader.loadBytes(null),
    );
  }
}

class MyApp extends StatefulWidget {
  final AppRouter router;
  final String initialRoute;

  const MyApp({
    super.key,
    required this.router,
    required this.initialRoute,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<QuestionStore>(
          create: (_) => getIt<QuestionStore>(),
          lazy: false,
        ),
        ChangeNotifierProvider<ResponseProvider>(
          create: (_) => getIt<ResponseProvider>(),
        ),
      ],
      child: AdaptiveTheme(
        light: AppTheme.lightTheme,
        dark: AppTheme.darkTheme,
        initial: AdaptiveThemeMode.system,
        builder: (theme, darkTheme) => MaterialApp(
          title: AppConstants.appTitle,
          theme: theme,
          darkTheme: darkTheme,
          onGenerateRoute: widget.router.generateRoute,
          debugShowCheckedModeBanner: false,
          initialRoute: widget.initialRoute,
        ),
      ),
    );
  }
}
