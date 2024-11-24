import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:gsecsurvey/services/question_store.dart';
import 'package:gsecsurvey/services/response_provider.dart';
import 'package:gsecsurvey/firebase_options.dart';
import 'package:gsecsurvey/routing/app_router.dart';
import 'package:gsecsurvey/routing/routes.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Future.wait([
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ),
    ScreenUtil.ensureScreenSize(),
    preloadSVGs(['assets/svgs/google_logo.svg'])
  ]);

  // Get the current user synchronously
  final user = FirebaseAuth.instance.currentUser;
  final initialRoute = (user != null && user.emailVerified)
      ? Routes.homeScreen
      : Routes.loginScreen;

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

class MyApp extends StatelessWidget {
  final AppRouter router;
  final String initialRoute;

  const MyApp({
    super.key,
    required this.router,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) => MultiProvider(
        providers: [
          ChangeNotifierProvider<QuestionStore>(
            create: (_) => QuestionStore(),
            lazy: false,
          ),
          ChangeNotifierProvider<ResponseProvider>(
            create: (_) => ResponseProvider(),
          ),
        ],
        child: Builder(
          builder: (context) => AdaptiveTheme(
            light: ThemeData.light(useMaterial3: true).copyWith(
              colorScheme:
                  ThemeData.light(useMaterial3: true).colorScheme.copyWith(
                        primary: const Color.fromARGB(255, 141, 27, 27),
                        secondary: Colors.white,
                        tertiary: const Color.fromARGB(255, 188, 188, 188),
                        onPrimary: Colors.white,
                        onSecondary: Colors.black,
                        surface: const Color.fromARGB(255, 236, 230, 240),
                        shadow: const Color.fromARGB(255, 24, 24, 24),
                      ),
            ),
            dark: ThemeData.dark(useMaterial3: true).copyWith(
              colorScheme:
                  ThemeData.dark(useMaterial3: true).colorScheme.copyWith(
                        primary: const Color.fromARGB(255, 141, 27, 27),
                        secondary: Colors.black,
                        tertiary: const Color.fromARGB(255, 10, 10, 10),
                        onPrimary: Colors.white,
                        onSecondary: Colors.white,
                        surface: const Color.fromARGB(255, 42, 41, 47),
                        shadow: const Color.fromARGB(255, 171, 171, 171),
                      ),
            ),
            initial: AdaptiveThemeMode.system,
            builder: (theme, darkTheme) => MaterialApp(
              title: 'GSEC Survey App',
              theme: theme,
              darkTheme: darkTheme,
              onGenerateRoute: router.generateRoute,
              debugShowCheckedModeBanner: false,
              initialRoute: initialRoute,
            ),
          ),
        ),
      ),
    );
  }
}
