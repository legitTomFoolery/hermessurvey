# Institution Configuration Guide

This document explains how to customize the GSEC Survey App for different institutions using the centralized configuration system.

## Overview

The app now uses a centralized configuration system that allows you to rebrand the entire application for different institutions by editing a single file: `lib/app/config/institution_config.dart`.

## Quick Start

To customize the app for a new institution:

1. Open `lib/app/config/institution_config.dart`
2. Edit the constants in the `InstitutionConfig` class
3. Rebuild the app

That's it! The entire app will now reflect your institution's branding and identity.

## Configuration Options

### Institution Identity

```dart
/// Short name of the institution (used in titles and labels)
static const String institutionName = 'GSEC';

/// Full name of the institution
static const String institutionFullName = 'Goodman Surgical Education Center';

/// Institution affiliation or parent organization
static const String institutionAffiliation = 'Stanford Medicine';
```

### App Identity

```dart
/// App package identifier (Android applicationId / iOS bundle identifier)
static const String appPackageId = 'edu.stanford.goodman.gsecsurvey';

/// App name (used in pubspec.yaml and internal references)
static const String appName = 'gsecsurvey';
```

### Branding Colors

```dart
/// Primary brand color (main color used throughout the app)
static const Color primaryColor = Color.fromARGB(255, 141, 27, 27);

/// Color for text and icons that appear on the primary color
static const Color onPrimaryColor = Colors.white;
```

### App Titles & Labels

All app titles are automatically generated from the `institutionName`:

- Login screen: "{institutionName} Survey Login"
- Signup screen: "{institutionName} Survey Signup"
- App title: "{institutionName} Survey App"
- Display name: "{institutionName} Survey"

### Notification Configuration

```dart
/// Name of the notification channel
static const String notificationChannelName = '{institutionName} Survey Notifications';

/// Default notification message template
static const String defaultNotificationMessage = 
    '{institutionName} Survey - This is a reminder to complete your feedback using the feedback evaluation tool.';
```

## Example: Customizing for UCSF

To rebrand the app for University of California San Francisco:

```dart
class InstitutionConfig {
  // Institution Identity
  static const String institutionName = 'UCSF';
  static const String institutionFullName = 'University of California San Francisco';
  static const String institutionAffiliation = 'UC System';
  
  // App Identity
  static const String appPackageId = 'edu.ucsf.surgicalsurvey';
  static const String appName = 'ucsf_survey';
  
  // Branding Colors
  static const Color primaryColor = Color(0xFF003366); // Navy blue
  static const Color onPrimaryColor = Colors.white;
  
  // ... rest of the configuration is auto-generated
}
```

This would result in:
- Login screen showing "UCSF Survey Login"
- App title becoming "UCSF Survey App"
- Primary color changing to navy blue
- Notifications showing "UCSF Survey - ..."

## What Gets Updated Automatically

When you change the `InstitutionConfig`, the following elements are automatically updated throughout the app:

### UI Elements
- ✅ Login screen title
- ✅ Signup screen title
- ✅ App bar titles
- ✅ Primary color scheme (buttons, progress indicators, etc.)
- ✅ Text colors on primary backgrounds

### Notifications
- ✅ Notification channel name
- ✅ Default notification messages
- ✅ Notification titles

### App Constants
- ✅ App title references
- ✅ Display name references

## Files That Reference Institution Config

The following files automatically use the centralized configuration:

- `lib/app/config/app_constants.dart` - App-wide constants
- `lib/theme/colors.dart` - Color definitions
- `lib/theme/app_theme.dart` - Theme configuration
- `lib/shared/data/services/notification_service.dart` - Notification service
- `lib/features/auth/presentation/widgets/login_page_content.dart` - Login screen
- `lib/features/auth/presentation/screens/signup_screen.dart` - Signup screen
- `lib/features/admin/presentation/widgets/modals/notification_modal.dart` - Admin notifications
- `lib/shared/presentation/widgets/progress_indicator.dart` - Loading indicators

## Additional Customization

### Package Identifier
Remember to also update the package identifier in:
- `android/app/build.gradle` (applicationId)
- `pubspec.yaml` (name field)
- iOS configuration files

### App Description
The app description is automatically generated but can be customized in the `InstitutionConfig.appDescription` field.

### Helper Methods
The config includes helper methods for dynamic string generation:

```dart
// Get a formatted app title with custom suffix
String customTitle = InstitutionConfig.getAppTitleWithSuffix('Admin');
// Result: "GSEC Survey Admin"

// Get a formatted notification message with custom content
String customNotification = InstitutionConfig.getNotificationMessage('Please complete your evaluation');
// Result: "GSEC Survey - Please complete your evaluation"
```

## Best Practices

1. **Test thoroughly** after making changes to ensure all UI elements display correctly
2. **Keep institution names short** for better UI layout (3-6 characters recommended)
3. **Choose high contrast colors** for accessibility
4. **Update package identifiers** when deploying to app stores
5. **Document your changes** for future reference

## Troubleshooting

### Colors not updating
- Ensure you're using `InstitutionConfig.primaryColor` and not hardcoded colors
- Rebuild the app completely (flutter clean && flutter pub get && flutter run)

### Strings not updating
- Check that you're referencing the config constants, not hardcoded strings
- Verify the import statement includes `institution_config.dart`

### Build errors
- Ensure all syntax is correct in the config file
- Check that color values are valid Flutter Color objects

## Migration from Hardcoded Values

If you're working with an older version of the app that had hardcoded values, look for:

- Any references to "GSEC" in string literals
- Hardcoded color values like `Color(0xFF247CFF)` or `Color.fromARGB(255, 141, 27, 27)`
- Direct references to app names or titles

These should be replaced with references to `InstitutionConfig` constants.
