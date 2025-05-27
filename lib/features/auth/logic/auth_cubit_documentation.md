# AuthCubit Documentation

## Overview

The `AuthCubit` is responsible for managing authentication state throughout the GSEC Survey application. It handles various authentication methods including email/password authentication, Google Sign-In, password reset functionality, and user verification status management.

## Architecture

The AuthCubit follows the BLoC (Business Logic Component) pattern and extends `Cubit<AuthState>` to provide reactive state management for authentication operations.

### State Management

The cubit manages the following states:
- `AuthInitial`: Initial state when no authentication operation is in progress
- `AuthLoading`: State during authentication operations (sign in, sign up, password reset)
- `UserSignIn`: State when user successfully authenticates (contains user data and admin status)
- `AuthError`: State when authentication operations fail (contains error message)

## Key Methods

### signInWithEmail(String email, String password)

**Purpose**: Authenticates users using email and password credentials.

**Process**:
1. Emits `AuthLoading` state to indicate operation start
2. Attempts Firebase authentication with provided credentials
3. Validates email verification status
4. Determines admin privileges by checking user document in Firestore
5. Emits `UserSignIn` with user data and admin status on success
6. Emits `AuthError` with appropriate message on failure

**Error Handling**:
- Invalid credentials: "Invalid email or password"
- Unverified email: "Please verify your email before signing in"
- Network issues: "Network error. Please check your connection"
- Generic errors: "An error occurred during sign in"

### signUpWithEmail(String name, String email, String password)

**Purpose**: Creates new user accounts with email verification.

**Process**:
1. Emits `AuthLoading` state
2. Creates Firebase user account
3. Updates user profile with display name
4. Sends email verification
5. Creates user document in Firestore with default non-admin status
6. Signs out user (requires email verification before access)
7. Emits success state with verification message

**Security Considerations**:
- All new users default to non-admin status
- Email verification required before account access
- User data stored in Firestore for admin status management

### signInWithGoogle()

**Purpose**: Provides Google Sign-In authentication option.

**Process**:
1. Initiates Google Sign-In flow
2. Authenticates with Firebase using Google credentials
3. Creates user document if first-time user (non-admin by default)
4. Determines admin status from existing user document
5. Emits appropriate state based on result

**Special Handling**:
- Automatic user document creation for new Google users
- Admin status preservation for existing users
- Graceful handling of user cancellation

### resetPassword(String email)

**Purpose**: Sends password reset emails to users.

**Process**:
1. Validates email format
2. Sends Firebase password reset email
3. Provides user feedback on success/failure

### Administrative Functions

#### checkUserAccountExists()
- Verifies if current user has valid authentication
- Used for session validation

#### signOut()
- Safely signs out current user
- Resets authentication state

#### resetState()
- Manually resets cubit to initial state
- Used for UI state management

## Error Handling Strategy

The AuthCubit implements comprehensive error handling:

1. **Firebase Exceptions**: Specific handling for common Firebase auth errors
2. **Network Errors**: Detection and user-friendly messaging for connectivity issues
3. **Validation Errors**: Client-side validation with appropriate feedback
4. **Generic Errors**: Fallback error handling for unexpected issues

## Security Features

### Email Verification
- Required for all email/password accounts
- Prevents access to unverified accounts
- Clear messaging for verification requirements

### Admin Status Management
- Stored securely in Firestore user documents
- Cannot be modified through client-side code
- Checked on every authentication

### Session Management
- Automatic session validation
- Secure sign-out functionality
- State reset on authentication changes

## Integration Points

### Firebase Services
- **Firebase Auth**: Core authentication functionality
- **Firestore**: User data and admin status storage
- **Google Sign-In**: Third-party authentication provider

### UI Integration
- Reactive state updates for loading indicators
- Error message display
- Navigation based on authentication status

## Usage Examples

### Basic Sign In
```dart
final authCubit = context.read<AuthCubit>();
await authCubit.signInWithEmail('user@example.com', 'password123');
```

### State Listening
```dart
BlocListener<AuthCubit, AuthState>(
  listener: (context, state) {
    if (state is UserSignIn) {
      // Navigate to home screen
      Navigator.pushReplacementNamed(context, '/home');
    } else if (state is AuthError) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: // Your widget tree
)
```

## Testing Considerations

The AuthCubit is designed to be testable with:
- Clear state transitions
- Mockable dependencies (Firebase services)
- Predictable error handling
- Isolated business logic

## Future Enhancements

Potential improvements for the AuthCubit:
1. Biometric authentication support
2. Multi-factor authentication
3. Social login providers (Facebook, Apple)
4. Enhanced session management
5. Audit logging for authentication events

## Dependencies

- `firebase_auth`: Firebase authentication SDK
- `cloud_firestore`: Firestore database SDK
- `google_sign_in`: Google Sign-In SDK
- `flutter_bloc`: State management framework
