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

### Rive Animations

The app uses **Rive** animations for enhanced user experience. Rive is a real-time interactive design and animation tool that creates lightweight, interactive animations for apps.

#### What is Rive?
- **Rive** is a modern animation platform that creates vector-based animations
- Animations are stored in `.riv` files that are much smaller than video files
- Supports interactive animations that can respond to user input
- Provides smooth, scalable animations that work across all screen sizes

#### Headless Bear Animation

The app includes a custom "headless bear" animation located in `assets/animation/`:

- **`headless_bear.riv`** - Main animation file used in the app
- **`backup_headless_bear.riv`** - Backup version of the animation

**What is the Headless Bear?**
- A custom mascot animation created specifically for the GSEC Survey App
- Used as a loading animation and visual element throughout the app
- Provides a friendly, approachable visual identity
- The "headless" design is intentionally minimalist and professional

**Where it's used:**
- Loading screens during data synchronization
- Transition animations between screens
- Empty state illustrations
- Progress indicators

#### Customizing Animations for Your Institution

To replace the headless bear with your own institution's mascot or branding:

1. **Create your animation** in [Rive Editor](https://rive.app/)
2. **Export as .riv file** from Rive
3. **Replace the files** in `assets/animation/`:
   ```
   assets/animation/
   ├── your_mascot.riv          # Replace headless_bear.riv
   └── backup_your_mascot.riv   # Replace backup_headless_bear.riv
   ```
4. **Update references** in the code to point to your new animation files
5. **Test thoroughly** to ensure animations work correctly

**Animation Guidelines:**
- Keep file size under 500KB for optimal performance
- Use vector-based graphics for scalability
- Ensure animations work well on both light and dark themes
- Test on various screen sizes and orientations
- Consider accessibility - animations should not be essential for app functionality

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
