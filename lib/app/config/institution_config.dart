import 'package:flutter/material.dart';

/// Centralized configuration for institutional branding and identity.
/// Edit this file to customize the app for different institutions.
class InstitutionConfig {
  // Private constructor to prevent instantiation
  InstitutionConfig._();

  // ============================================================================
  // INSTITUTION IDENTITY
  // ============================================================================

  /// Short name of the institution (used in titles and labels)
  static const String institutionName = 'GSEC';

  /// Full name of the institution
  static const String institutionFullName = 'Goodman Surgical Education Center';

  /// Institution affiliation or parent organization
  static const String institutionAffiliation = 'Stanford Medicine';

  // ============================================================================
  // APP IDENTITY
  // ============================================================================

  /// App package identifier (Android applicationId / iOS bundle identifier)
  static const String appPackageId = 'edu.stanford.goodman.gsecsurvey';

  /// App name (used in pubspec.yaml and internal references)
  static const String appName = 'gsecsurvey';

  /// App description for stores and documentation
  static const String appDescription =
      'The $institutionName Survey App is developed for the $institutionFullName at $institutionAffiliation. '
      'It facilitates the collection of survey responses to improve surgical education and training programs.';

  // ============================================================================
  // BRANDING COLORS
  // ============================================================================

  /// Primary brand color (main color used throughout the app)
  static const Color primaryColor = Color.fromARGB(255, 141, 27, 27);

  /// Color for text and icons that appear on the primary color
  static const Color onPrimaryColor = Colors.white;

  // ============================================================================
  // APP TITLES & LABELS
  // ============================================================================

  /// Main app title shown in app bars and headers
  static const String appTitle = '$institutionName Survey App';

  /// Display name for the app (shorter version)
  static const String appDisplayName = '$institutionName Survey';

  /// Title for login screen
  static const String loginTitle = '$institutionName Survey Login';

  /// Title for signup screen
  static const String signupTitle = '$institutionName Survey Signup';

  /// App bar title for main screens
  static const String appBarTitle = 'Feedback Evaluation Tool';

  // ============================================================================
  // NOTIFICATION CONFIGURATION
  // ============================================================================

  /// Name of the notification channel
  static const String notificationChannelName =
      '$institutionName Survey Notifications';

  /// Description of the notification channel
  static const String notificationChannelDescription =
      'Notifications for $institutionName Survey App';

  /// Default notification message template
  static const String defaultNotificationMessage =
      '$institutionName Survey - This is a reminder to complete your feedback using the feedback evaluation tool.';

  /// Default notification title
  static const String defaultNotificationTitle = '$institutionName Survey';

  // ============================================================================
  // EMAIL DOMAIN CONFIGURATION
  // ============================================================================

  /// Required email domain for user registration (e.g., 'stanford.edu')
  /// Set to null to allow any email domain
  static const String requiredEmailDomain = 'stanford.edu';

  /// Error message shown when user enters email with wrong domain
  static const String invalidEmailDomainMessage =
      'Please enter a Stanford email';

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Get a formatted app title with custom suffix
  static String getAppTitleWithSuffix(String suffix) {
    return '$institutionName Survey $suffix';
  }

  /// Get a formatted notification message with custom content
  static String getNotificationMessage(String customMessage) {
    return '$institutionName Survey - $customMessage';
  }

  /// Check if an email domain is valid according to institution requirements
  static bool isEmailDomainValid(String email) {
    return email
        .toLowerCase()
        .endsWith('@${requiredEmailDomain.toLowerCase()}');
  }

  /// Get the formatted email domain requirement message
  static String getEmailDomainErrorMessage() {
    return invalidEmailDomainMessage;
  }
}
