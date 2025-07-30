# GSEC Survey App

A comprehensive Flutter-based survey application developed for the Goodman Surgical Education Center at Stanford Medicine. This app facilitates the collection of survey responses to improve surgical education and training programs.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [Development Setup](#development-setup)
- [Environment Management](#environment-management)
- [Project Structure](#project-structure)
- [Documentation](#documentation)
- [Deployment](#deployment)
- [Contributing](#contributing)
- [Security](#security)

## 🎯 Overview

The GSEC Survey App is a modern, scalable Flutter application that provides:

- **Multi-platform support**: iOS, Android, and Web
- **Institutional customization**: Easy rebranding for different institutions
- **Secure authentication**: Email/password and Google Sign-In
- **Admin management**: Comprehensive admin panel for survey and user management
- **Real-time data**: Firebase Firestore integration
- **Environment switching**: Seamless development/production environment management

## ✨ Features

### For Users
- 📱 Cross-platform mobile and web access
- 🔐 Secure authentication with email verification
- 📊 Interactive survey interface with multiple question types
- 🔄 Real-time response synchronization
- 📱 Push notifications for survey reminders

### For Administrators
- 👥 User management and role assignment
- 📝 Dynamic survey creation and editing
- 📈 Response analytics and data export
- 🔔 Notification management
- 📊 Comprehensive reporting dashboard

## 🏗️ Architecture

The app follows a **feature-based modular architecture** with clean separation of concerns:

```
lib/
├── app/                    # App-level configuration
│   └── config/            # Routing, DI, constants
├── features/              # Feature modules
│   ├── auth/             # Authentication system
│   ├── admin/            # Admin panel
│   └── home/             # Survey interface
├── shared/               # Shared utilities and widgets
├── theme/                # App theming and styling
└── main.dart            # App entry point
```

**Key Architectural Patterns:**
- **BLoC/Cubit**: State management
- **Provider**: Dependency injection and state sharing
- **Repository Pattern**: Data layer abstraction
- **Feature-based Organization**: Modular, scalable structure

## 🚀 Quick Start

### Prerequisites

Ensure you have the following installed:

- **Flutter SDK** (3.4.0 or higher)
- **Dart SDK** (included with Flutter)
- **Git**
- **IDE**: VS Code, Android Studio, or IntelliJ IDEA

### Platform-Specific Requirements

#### Windows
```bash
# Install Flutter
# Download from https://docs.flutter.dev/get-started/install/windows

# Install Git
winget install Git.Git

# Install Visual Studio (for Windows development)
# Download from https://visualstudio.microsoft.com/
```

#### macOS
```bash
# Install Flutter
brew install flutter

# Install Xcode (for iOS development)
# Download from Mac App Store

# Install CocoaPods
sudo gem install cocoapods
```

#### Linux
```bash
# Install Flutter
sudo snap install flutter --classic

# Install additional dependencies
sudo apt-get install curl git unzip xz-utils zip libglu1-mesa
```

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/gsecsurveyapp/gsecsurvey.git
   cd gsecsurvey
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase** (see [Firebase Setup](#firebase-setup))

4. **Run the app**
   ```bash
   # Development mode
   flutter run
   
   # Specific platform
   flutter run -d chrome        # Web
   flutter run -d android       # Android
   flutter run -d ios           # iOS (macOS only)
   ```

## 🛠️ Development Setup

### Firebase Setup

1. **Create a Firebase project** at [Firebase Console](https://console.firebase.google.com/)

2. **Enable Authentication**
   - Go to Authentication > Sign-in method
   - Enable Email/Password and Google Sign-In

3. **Set up Firestore Database**
   - Create a Firestore database in production mode
   - Configure security rules (see `docs/DEPLOYMENT.md`)

4. **Configure Firebase for Flutter**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Configure Flutter app
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

5. **Add configuration files**
   - Place `google-services.json` in `android/app/`
   - Place `GoogleService-Info.plist` in `ios/Runner/`
   - Update `lib/firebase_options.dart` with your project configuration

### IDE Setup

#### VS Code
Install recommended extensions:
```bash
# Flutter and Dart extensions
code --install-extension Dart-Code.flutter
code --install-extension Dart-Code.dart-code

# Additional helpful extensions
code --install-extension ms-vscode.vscode-json
code --install-extension bradlc.vscode-tailwindcss
```

#### Android Studio
1. Install Flutter and Dart plugins
2. Configure Flutter SDK path
3. Set up Android emulator

### Code Quality Tools

```bash
# Run linter
flutter analyze

# Format code
dart format .

# Run tests
flutter test

# Generate test coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 🔄 Environment Management

The app supports switching between development and production environments through a simple configuration change.

### Environment Control

**Primary Control Point**: `lib/app/config/environment_config.dart`
```dart
bool _isDevelopment = true;  // Change this to switch environments
```

### Development vs Production

| Environment | Collection Prefix | Use Case |
|-------------|------------------|----------|
| Development | `dev-` | Testing, development, staging |
| Production | None | Live app, real users |

### Switching Environments

**Manual Configuration** (Recommended):
Edit `lib/app/config/environment_config.dart` line 17:
```dart
bool _isDevelopment = false;  // Set to false for production
```

### Environment Verification

Check current environment:
```dart
final env = EnvironmentConfig();
print('Environment: ${env.isDevelopment ? 'DEVELOPMENT' : 'PRODUCTION'}');
```

**Note**: The Python scripts in the `scripts/` directory have their own separate environment configuration and are not automatically synchronized with the Flutter app environment.

## 📁 Project Structure

```
gsecsurvey/
├── android/                 # Android-specific files
├── ios/                     # iOS-specific files
├── web/                     # Web-specific files
├── lib/                     # Main application code
│   ├── app/                 # App configuration
│   │   └── config/          # Routing, DI, constants
│   ├── features/            # Feature modules
│   │   ├── auth/            # Authentication
│   │   ├── admin/           # Admin panel
│   │   └── home/            # Survey interface
│   ├── shared/              # Shared code
│   │   ├── data/            # Services and providers
│   │   ├── presentation/    # Common widgets
│   │   └── utils/           # Utilities and extensions
│   └── theme/               # App theming
├── scripts/                 # Backend utilities
├── test/                    # Test files
├── docs/                    # Additional documentation
└── assets/                  # Images, fonts, etc.
```

## 📚 Documentation

### Feature Documentation
- [Authentication System](lib/features/auth/README.md) - User authentication and security
- [Admin Panel](lib/features/admin/README.md) - Administrative functionality
- [Survey Interface](lib/features/home/README.md) - User survey experience
- [Backend Scripts](scripts/README.md) - Utility scripts and environment management

### Technical Documentation
- [Deployment Guide](docs/DEPLOYMENT.md) - Production deployment instructions
- [Development Guide](docs/DEVELOPMENT.md) - Detailed development setup
- [Architecture Overview](docs/ARCHITECTURE.md) - Technical architecture details
- [Institution Configuration](INSTITUTION_CONFIG_README.md) - Customization guide

## 🚀 Deployment

### Development Deployment
```bash
# Ensure development environment
cd scripts && python toggle_environment.py dev

# Run with development Firebase collections
flutter run --debug
```

### Production Deployment
```bash
# Switch to production environment
cd scripts && python toggle_environment.py prod

# Build for production
flutter build apk --release          # Android
flutter build ios --release          # iOS
flutter build web --release          # Web
```

### Environment Checklist

Before production deployment:
- [ ] Set `_isDevelopment = false` in `environment_config.dart`
- [ ] Verify Firebase security rules
- [ ] Update app version in `pubspec.yaml`
- [ ] Test with production Firebase collections
- [ ] Remove debug configurations
- [ ] Verify all sensitive data is secured

## 🤝 Contributing

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Follow coding standards**
   - Use `dart format` for consistent formatting
   - Run `flutter analyze` to check for issues
   - Write tests for new functionality
4. **Commit your changes**
   ```bash
   git commit -m "feat: add your feature description"
   ```
5. **Push and create a Pull Request**

### Coding Standards
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable and function names
- Add documentation for public APIs
- Maintain test coverage above 80%

## 🔒 Security

### Environment Security
- **Never commit** Firebase private keys or sensitive configuration
- Use environment variables for sensitive data in production
- Regularly rotate API keys and certificates

### Data Security
- All user data is encrypted in transit and at rest
- Firebase security rules enforce proper access control
- Email verification required for all accounts
- Admin privileges managed through secure Firestore documents

### Recommended Security Practices
- Enable Firebase App Check for production
- Implement proper Firestore security rules
- Use HTTPS for all network communications
- Regular security audits and dependency updates

## 📄 License

MIT License

Copyright (c) 2025 Goodman Surgical Education Center at Stanford Medicine

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## 📞 Support

For technical support or questions:
- **Email**: gsecsurveyapp@gmail.com
- **Issues**: [GitHub Issues](https://github.com/gsecsurveyapp/gsecsurvey/issues)
- **Documentation**: See the `docs/` directory for detailed guides

---

**Version**: 2.0.0  
**Last Updated**: January 2025  
**Developed by**: GSEC Development Team
