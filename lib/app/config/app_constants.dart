/// Application-wide constants
class AppConstants {
  // App Information
  static const String appTitle = 'GSEC Survey App';
  static const String appBarTitle = 'Feedback Evaluation Tool';

  // Design System
  static const double defaultBorderRadius = 16.0;
  static const double defaultPadding = 16.0;
  static const double defaultSpacing = 8.0;
  static const double defaultButtonHeight = 52.0;

  // Animation Durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration scrollAnimationDuration = Duration(milliseconds: 500);

  // UI Dimensions
  static const double floatingActionButtonSize = 56.0;
  static const double progressBarHeight = 5.0;
  static const double appBarIconSize = 20.0;

  // Form Field Dimensions
  static const double textFieldHorizontalPadding = 20.0;
  static const double textFieldVerticalPadding = 17.0;
  static const double textFieldBorderWidth = 1.3;

  // Button Dimensions
  static const double buttonHorizontalPadding = 12.0;
  static const double buttonVerticalPadding = 14.0;

  // Screen Util Design Size
  static const double designWidth = 360.0;
  static const double designHeight = 690.0;

  // Asset Paths
  static const String googleLogoSvg = 'assets/svgs/google_logo.svg';

  // Text Content
  static const String appName = 'GSEC Survey';
  static const String defaultNotificationMessage =
      'You have a new notification';
  static const String noQuestionsFound = 'No questions found';
  static const String submitResponses = 'Submit Responses';
  static const String noInternet = 'No Internet';
  static const String retryText = 'Retry';
  static const String completedSuffix = '% Completed';

  // Error Messages
  static const String errorLoadingQuestions = 'Error loading questions';
  static const String failedToInitializeNotifications =
      'Failed to initialize notification service';

  // Private constructor to prevent instantiation
  AppConstants._();
}
