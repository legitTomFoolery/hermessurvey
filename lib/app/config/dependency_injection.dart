/// Dependency injection configuration using get_it
library dependency_injection;

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:gsecsurvey/features/auth/logic/auth_cubit.dart';
import 'package:gsecsurvey/features/home/data/services/question_store.dart';
import 'package:gsecsurvey/shared/data/services/response_provider.dart';
import 'package:gsecsurvey/shared/data/services/user_service.dart';
import 'package:gsecsurvey/shared/data/services/notification_service.dart';

/// Global service locator instance
final GetIt getIt = GetIt.instance;

/// Sets up all dependency injection bindings
Future<void> setupDependencies() async {
  // Register services as singletons
  getIt.registerLazySingleton<UserService>(() => UserService());
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());

  // Register providers as singletons
  getIt.registerLazySingleton<QuestionStore>(() => QuestionStore());
  getIt.registerLazySingleton<ResponseProvider>(() => ResponseProvider());

  // Register cubits as factories (new instance each time)
  getIt.registerFactory<AuthCubit>(() => AuthCubit());

  // Initialize services that need async setup
  await _initializeServices();
}

/// Initialize services that require async setup
Future<void> _initializeServices() async {
  try {
    // Initialize notification service
    await NotificationService.initialize();
  } catch (e) {
    // Log error but don't throw to prevent app crash
    // In production, consider using a proper logging service like firebase_crashlytics
    debugPrint('Failed to initialize some services: $e');
  }
}

/// Resets all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await getIt.reset();
}

/// Gets a dependency from the service locator
T getDependency<T extends Object>() {
  return getIt<T>();
}

/// Checks if a dependency is registered
bool isDependencyRegistered<T extends Object>() {
  return getIt.isRegistered<T>();
}
