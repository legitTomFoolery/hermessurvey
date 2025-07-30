import 'package:flutter/foundation.dart';

/// Environment configuration for the application
/// This class provides a centralized way to manage environment-specific settings
class EnvironmentConfig {
  /// Singleton instance
  static final EnvironmentConfig _instance = EnvironmentConfig._internal();

  /// Factory constructor to return the singleton instance
  factory EnvironmentConfig() => _instance;

  /// Private constructor
  EnvironmentConfig._internal();

  /// Whether the app is running in development mode
  /// Set this to true to use development collections (with 'dev-' prefix)
  /// Set this to false to use production collections (without prefix)
  bool _isDevelopment = false;

  /// Get the current environment mode
  bool get isDevelopment => _isDevelopment;

  /// Set the environment mode
  set isDevelopment(bool value) {
    _isDevelopment = value;
    debugPrint('Environment set to: ${value ? 'DEVELOPMENT' : 'PRODUCTION'}');
  }

  /// Get the correct collection name based on the current environment
  /// If in development mode, it will prefix the collection name with 'dev-'
  /// If in production mode, it will return the original collection name
  String getCollectionName(String collectionName) {
    if (_isDevelopment) {
      // Skip adding prefix if the collection already has the dev- prefix
      if (collectionName.startsWith('dev-')) {
        return collectionName;
      }
      return 'dev-$collectionName';
    }
    // In production mode, remove the dev- prefix if it exists
    if (collectionName.startsWith('dev-')) {
      return collectionName.substring(4);
    }
    return collectionName;
  }
}
