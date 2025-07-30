# Authentication System

The authentication system provides secure user authentication and authorization for the GSEC Survey App. It supports multiple authentication methods and implements comprehensive security measures.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Authentication Methods](#authentication-methods)
- [Security Features](#security-features)
- [State Management](#state-management)
- [User Roles](#user-roles)
- [API Reference](#api-reference)
- [Testing](#testing)

## 🎯 Overview

The authentication system is built on Firebase Authentication and provides:

- **Multiple sign-in methods**: Email/password and Google Sign-In
- **Email verification**: Required for all email-based accounts
- **Password reset**: Secure password recovery via email
- **Role-based access**: Admin and regular user roles
- **Session management**: Secure session handling and automatic logout
- **State management**: Reactive authentication state using BLoC pattern

## 🏗️ Architecture

### Directory Structure

```
lib/features/auth/
├── logic/                          # Business logic
│   ├── auth_cubit.dart            # Main authentication cubit
│   ├── auth_state.dart            # Authentication states
│   └── auth_cubit_documentation.md # Detailed cubit documentation
└── presentation/                   # UI components
    ├── screens/                   # Authentication screens
    │   ├── login_screen.dart      # Login interface
    │   ├── signup_screen.dart     # Registration interface
    │   ├── forgot_password_screen.dart # Password reset
    │   └── create_password_screen.dart # Password creation
    └── widgets/                   # Reusable auth widgets
        ├── login_and_signup_animated_form.dart
        ├── login_page_content.dart
        ├── password_validations.dart
        ├── already_have_account_text.dart
        ├── do_not_have_account.dart
        └── password_reset.dart
```

### Key Components

#### AuthCubit (`auth_cubit.dart`)
The central business logic component that manages all authentication operations.

**Responsibilities:**
- User sign-in and sign-up
- Password reset functionality
- Session management
- Admin status verification
- Error handling and state management

#### Authentication States (`auth_state.dart`)
Defines all possible authentication states:

```dart
abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class UserSignIn extends AuthState {
  final User user;
  final bool isAdmin;
}
class AuthError extends AuthState {
  final String message;
}
```

## 🔐 Authentication Methods

### 1. Email/Password Authentication

**Sign Up Process:**
1. User provides name, email, and password
2. Firebase creates user account
3. Email verification sent automatically
4. User document created in Firestore (non-admin by default)
5. User must verify email before accessing app

**Sign In Process:**
1. User provides email and password
2. Firebase validates credentials
3. System checks email verification status
4. Admin status retrieved from Firestore
5. User redirected based on role

**Implementation:**
```dart
// Sign up
await authCubit.signUpWithEmail(name, email, password);

// Sign in
await authCubit.signInWithEmail(email, password);
```

### 2. Google Sign-In

**Process:**
1. User initiates Google Sign-In
2. Google authentication flow
3. Firebase authentication with Google credentials
4. User document created/updated in Firestore
5. Admin status determined from existing data

**Implementation:**
```dart
await authCubit.signInWithGoogle();
```

### 3. Password Reset

**Process:**
1. User provides email address
2. Firebase sends password reset email
3. User follows email link to reset password
4. User can sign in with new password

**Implementation:**
```dart
await authCubit.resetPassword(email);
```

## 🛡️ Security Features

### Email Verification
- **Required**: All email-based accounts must verify email
- **Enforcement**: Unverified users cannot access the app
- **User Experience**: Clear messaging about verification requirements

### Admin Role Management
- **Secure Storage**: Admin status stored in Firestore user documents
- **Client-Side Protection**: Admin status cannot be modified from client
- **Default Security**: All new users default to non-admin status

### Session Security
- **Automatic Logout**: Sessions expire based on Firebase configuration
- **Secure Sign-Out**: Proper cleanup of authentication state
- **State Validation**: Regular validation of authentication status

### Input Validation
- **Email Format**: Client-side email validation
- **Password Strength**: Configurable password requirements
- **Error Handling**: Comprehensive error messages for security issues

## 📊 State Management

The authentication system uses the BLoC pattern with Cubit for state management:

### State Flow

```
AuthInitial
    ↓
AuthLoading (during authentication)
    ↓
UserSignIn (success) / AuthError (failure)
```

### Usage Example

```dart
BlocBuilder<AuthCubit, AuthState>(
  builder: (context, state) {
    if (state is AuthLoading) {
      return CircularProgressIndicator();
    } else if (state is UserSignIn) {
      return HomeScreen(isAdmin: state.isAdmin);
    } else if (state is AuthError) {
      return ErrorWidget(message: state.message);
    }
    return LoginScreen();
  },
)
```

## 👥 User Roles

### Regular Users
- **Permissions**: Access to survey interface
- **Features**: Complete surveys, view personal responses
- **Restrictions**: Cannot access admin functions

### Admin Users
- **Permissions**: Full system access
- **Features**: User management, survey creation, analytics
- **Security**: Admin status managed through Firestore documents

### Role Determination
```dart
// Check if current user is admin
bool isAdmin = await UserService.isCurrentUserAdmin();

// Access admin status from authentication state
if (state is UserSignIn && state.isAdmin) {
  // Show admin interface
}
```

## 📚 API Reference

### AuthCubit Methods

#### `signInWithEmail(String email, String password)`
Authenticates user with email and password.

**Parameters:**
- `email`: User's email address
- `password`: User's password

**Returns:** `Future<void>`

**Throws:** Emits `AuthError` state on failure

#### `signUpWithEmail(String name, String email, String password)`
Creates new user account with email verification.

**Parameters:**
- `name`: User's display name
- `email`: User's email address
- `password`: User's password

**Returns:** `Future<void>`

#### `signInWithGoogle()`
Authenticates user with Google Sign-In.

**Returns:** `Future<void>`

#### `resetPassword(String email)`
Sends password reset email to user.

**Parameters:**
- `email`: User's email address

**Returns:** `Future<void>`

#### `signOut()`
Signs out current user and resets state.

**Returns:** `Future<void>`

#### `checkUserAccountExists()`
Validates current user authentication status.

**Returns:** `Future<void>`

### Error Handling

Common error scenarios and their handling:

```dart
// Invalid credentials
"Invalid email or password"

// Unverified email
"Please verify your email before signing in"

// Network issues
"Network error. Please check your connection"

// Generic errors
"An error occurred during sign in"
```

## 🧪 Testing

### Unit Tests

The authentication system includes comprehensive unit tests:

```bash
# Run auth-specific tests
flutter test test/unit/auth/

# Run with coverage
flutter test --coverage test/unit/auth/
```

### Test Coverage

- **AuthCubit**: All authentication methods and state transitions
- **Error Handling**: Various error scenarios and edge cases
- **State Management**: Proper state emissions and transitions

### Mock Testing

```dart
// Example test setup
group('AuthCubit', () {
  late AuthCubit authCubit;
  late MockFirebaseAuth mockFirebaseAuth;
  
  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    authCubit = AuthCubit();
  });
  
  test('should emit UserSignIn when sign in succeeds', () async {
    // Test implementation
  });
});
```

## 🔧 Configuration

### Firebase Configuration

Ensure Firebase is properly configured:

1. **Authentication Methods**: Enable Email/Password and Google Sign-In
2. **Email Templates**: Customize verification and password reset emails
3. **Security Rules**: Configure Firestore rules for user documents

### Environment Variables

No environment variables required for basic authentication functionality.

## 🚀 Usage Examples

### Basic Authentication Flow

```dart
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is UserSignIn) {
            Navigator.pushReplacementNamed(
              context, 
              state.isAdmin ? '/admin' : '/home'
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: LoginForm(),
      ),
    );
  }
}
```

### Admin Route Protection

```dart
class AdminRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is UserSignIn && state.isAdmin) {
          return AdminDashboard();
        } else {
          return UnauthorizedScreen();
        }
      },
    );
  }
}
```

## 📝 Best Practices

1. **Always handle loading states** to provide user feedback
2. **Implement proper error handling** with user-friendly messages
3. **Validate user input** before making authentication requests
4. **Use secure navigation** based on authentication state
5. **Test authentication flows** thoroughly across all platforms

## 🔗 Related Documentation

- [AuthCubit Detailed Documentation](logic/auth_cubit_documentation.md)
- [Admin Panel Documentation](../admin/README.md)
- [Main App Documentation](../../README.md)

---

**Last Updated**: January 2025  
**Version**: 2.0.0
