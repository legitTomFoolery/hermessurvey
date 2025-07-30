# Deployment Guide

This guide provides comprehensive instructions for deploying the GSEC Survey App to production environments across multiple platforms.

## 📋 Table of Contents

- [Pre-deployment Checklist](#pre-deployment-checklist)
- [Environment Configuration](#environment-configuration)
- [Firebase Configuration](#firebase-configuration)
- [Platform-Specific Deployment](#platform-specific-deployment)
- [Security Configuration](#security-configuration)
- [Performance Optimization](#performance-optimization)
- [Monitoring and Analytics](#monitoring-and-analytics)
- [Troubleshooting](#troubleshooting)

## ✅ Pre-deployment Checklist

### Code Preparation
- [ ] All features tested and working correctly
- [ ] Code reviewed and approved
- [ ] Version number updated in `pubspec.yaml`
- [ ] Environment set to production mode
- [ ] All debug configurations removed
- [ ] Sensitive data secured (no hardcoded credentials)

### Environment Verification
- [ ] Production environment configured (`_isDevelopment = false`)
- [ ] Firebase collections using production names (no `dev-` prefix)
- [ ] All environment variables properly set
- [ ] Database security rules configured for production

### Testing
- [ ] Unit tests passing (`flutter test`)
- [ ] Widget tests passing
- [ ] Integration tests completed
- [ ] Manual testing on target devices
- [ ] Performance testing completed

## 🔄 Environment Configuration

### Switch to Production Mode

1. **Update Dart Configuration**
   ```dart
   // lib/app/config/environment_config.dart
   bool _isDevelopment = false;  // Set to false for production
   ```

2. **Verify Using Scripts**
   ```bash
   cd scripts
   python toggle_environment.py prod
   ```

3. **Confirm Environment**
   ```bash
   # Check current environment
   python toggle_environment.py
   # Should show: "Environment successfully set to: PRODUCTION"
   ```

### Version Management

Update version in `pubspec.yaml`:
```yaml
version: 2.0.0+1  # Major.Minor.Patch+BuildNumber
```

**Version Numbering Guidelines:**
- **Major**: Breaking changes or significant new features
- **Minor**: New features, backward compatible
- **Patch**: Bug fixes and small improvements
- **Build Number**: Increment for each deployment

## 🔥 Firebase Configuration

### Production Firebase Setup

1. **Create Production Firebase Project**
   ```bash
   # Create new project at https://console.firebase.google.com/
   # Or use existing production project
   ```

2. **Configure Authentication**
   - Enable Email/Password authentication
   - Enable Google Sign-In
   - Configure authorized domains
   - Set up email templates

3. **Firestore Database Setup**
   ```bash
   # Create Firestore database in production mode
   # Configure security rules (see Security Configuration)
   ```

4. **Update Firebase Configuration**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Login and configure
   firebase login
   flutterfire configure --project=your-production-project-id
   ```

### Security Rules

**Firestore Security Rules** (`firestore.rules`):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Questions are read-only for authenticated users
    match /questions/{document} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
    
    // Responses can be created/updated by authenticated users
    match /responses/{document} {
      allow read, write: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true);
    }
    
    // Admin-only collections
    match /admin/{document} {
      allow read, write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
  }
}
```

**Deploy Security Rules:**
```bash
firebase deploy --only firestore:rules
```

## 📱 Platform-Specific Deployment

### Android Deployment

#### 1. Prepare Android Build

```bash
# Clean previous builds
flutter clean
flutter pub get

# Build release APK
flutter build apk --release

# Or build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

#### 2. Configure Signing

**Create signing key:**
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Configure `android/key.properties`:**
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=upload
storeFile=/path/to/upload-keystore.jks
```

**Update `android/app/build.gradle`:**
```gradle
android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

#### 3. Google Play Store Deployment

1. **Create Play Console Account**
2. **Upload App Bundle**
3. **Configure Store Listing**
4. **Set up Release Management**
5. **Submit for Review**

### iOS Deployment

#### 1. Prepare iOS Build

```bash
# Clean and prepare
flutter clean
flutter pub get

# Build iOS release
flutter build ios --release
```

#### 2. Xcode Configuration

1. **Open iOS project in Xcode**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Configure Signing & Capabilities**
   - Select development team
   - Configure bundle identifier
   - Enable required capabilities

3. **Archive and Upload**
   - Product → Archive
   - Upload to App Store Connect

#### 3. App Store Deployment

1. **Create App Store Connect Record**
2. **Configure App Information**
3. **Upload Build via Xcode**
4. **Submit for Review**

### Web Deployment

#### 1. Build Web Version

```bash
# Build for web
flutter build web --release

# Output will be in build/web/
```

#### 2. Firebase Hosting Deployment

```bash
# Initialize Firebase Hosting
firebase init hosting

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

#### 3. Custom Domain Setup

```bash
# Add custom domain in Firebase Console
# Configure DNS records
# Enable SSL certificate
```

## 🔒 Security Configuration

### Environment Variables

**Production Environment Variables:**
```bash
# Firebase Configuration
FIREBASE_PROJECT_ID=your-production-project-id
FIREBASE_API_KEY=your-api-key
FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com

# App Configuration
APP_ENVIRONMENT=production
DEBUG_MODE=false
```

### API Security

1. **Firebase App Check**
   ```bash
   # Enable App Check in Firebase Console
   # Configure reCAPTCHA for web
   # Configure DeviceCheck/SafetyNet for mobile
   ```

2. **API Key Restrictions**
   - Restrict API keys to specific platforms
   - Configure allowed domains/bundle IDs
   - Enable only required APIs

### Data Protection

1. **Encryption**
   - All data encrypted in transit (HTTPS)
   - Firestore encrypts data at rest
   - Sensitive data hashed/encrypted

2. **Access Control**
   - Implement proper Firestore security rules
   - Use Firebase Authentication
   - Regular security audits

## ⚡ Performance Optimization

### Build Optimization

```bash
# Optimize build size
flutter build apk --release --shrink

# Enable obfuscation
flutter build apk --release --obfuscate --split-debug-info=debug-info/

# Tree shaking for web
flutter build web --release --tree-shake-icons
```

### Runtime Optimization

1. **Image Optimization**
   - Use appropriate image formats
   - Implement lazy loading
   - Cache network images

2. **Code Optimization**
   - Use const constructors
   - Implement proper state management
   - Minimize widget rebuilds

3. **Database Optimization**
   - Implement proper indexing
   - Use pagination for large datasets
   - Cache frequently accessed data

## 📊 Monitoring and Analytics

### Firebase Analytics

```dart
// Initialize Firebase Analytics
import 'package:firebase_analytics/firebase_analytics.dart';

final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

// Track events
await analytics.logEvent(
  name: 'survey_completed',
  parameters: {
    'survey_id': surveyId,
    'completion_time': completionTime,
  },
);
```

### Crashlytics

```dart
// Initialize Crashlytics
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// Set up crash reporting
FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

// Log custom errors
FirebaseCrashlytics.instance.recordError(
  error,
  stackTrace,
  reason: 'Custom error description',
);
```

### Performance Monitoring

```dart
// Track performance
import 'package:firebase_performance/firebase_performance.dart';

final FirebasePerformance performance = FirebasePerformance.instance;

// Create custom traces
final Trace trace = performance.newTrace('survey_load_time');
await trace.start();
// ... perform operation
await trace.stop();
```

## 🔧 Troubleshooting

### Common Deployment Issues

#### Build Failures

**Issue**: Build fails with dependency conflicts
```bash
# Solution: Clean and rebuild
flutter clean
flutter pub get
flutter pub deps
flutter build [platform] --release
```

**Issue**: iOS build fails with signing errors
```bash
# Solution: Check Xcode configuration
# 1. Verify development team selection
# 2. Check bundle identifier
# 3. Ensure certificates are valid
```

#### Runtime Issues

**Issue**: App crashes on startup
```bash
# Check logs
flutter logs

# Enable debug mode temporarily
flutter run --release --enable-software-rendering
```

**Issue**: Firebase connection fails
```bash
# Verify configuration files
# Check google-services.json (Android)
# Check GoogleService-Info.plist (iOS)
# Verify project ID matches
```

### Performance Issues

**Issue**: Slow app startup
- Check for heavy operations in main()
- Implement lazy loading
- Optimize asset loading

**Issue**: High memory usage
- Check for memory leaks
- Optimize image loading
- Implement proper disposal

### Deployment Verification

```bash
# Test production build locally
flutter run --release

# Verify environment configuration
# Check Firebase collections (no dev- prefix)
# Test authentication flow
# Verify data synchronization
```

## 📋 Post-Deployment Checklist

- [ ] App successfully deployed to target platforms
- [ ] Authentication working correctly
- [ ] Data synchronization functioning
- [ ] Push notifications operational
- [ ] Analytics and crash reporting active
- [ ] Performance metrics within acceptable ranges
- [ ] Security rules properly configured
- [ ] Backup and recovery procedures tested

## 🔗 Related Documentation

- [Main App Documentation](../README.md)
- [Environment Management](../scripts/README.md#environment-management)
- [Security Best Practices](#security-configuration)

---

**Last Updated**: January 2025  
**Version**: 2.0.0
