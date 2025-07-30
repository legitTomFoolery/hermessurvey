# Architecture Overview

This document provides a comprehensive overview of the GSEC Survey App's technical architecture, design patterns, and implementation decisions.

## 📋 Table of Contents

- [System Architecture](#system-architecture)
- [Application Architecture](#application-architecture)
- [Design Patterns](#design-patterns)
- [Data Flow](#data-flow)
- [State Management](#state-management)
- [Security Architecture](#security-architecture)
- [Performance Considerations](#performance-considerations)
- [Scalability](#scalability)

## 🏗️ System Architecture

### High-Level Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │   Firebase      │    │   Admin Tools   │
│                 │    │   Backend       │    │                 │
│  ┌───────────┐  │    │                 │    │  ┌───────────┐  │
│  │    UI     │  │◄──►│  ┌───────────┐  │    │  │  Python   │  │
│  │  Layer    │  │    │  │ Firestore │  │    │  │  Scripts  │  │
│  └───────────┘  │    │  │ Database  │  │    │  └───────────┘  │
│  ┌───────────┐  │    │  └───────────┘  │    │                 │
│  │ Business  │  │    │  ┌───────────┐  │    │  ┌───────────┐  │
│  │  Logic    │  │    │  │   Auth    │  │    │  │   Data    │  │
│  └───────────┘  │    │  │ Service   │  │    │  │  Export   │  │
│  ┌───────────┐  │    │  └───────────┘  │    │  └───────────┘  │
│  │   Data    │  │    │  ┌───────────┐  │    │                 │
│  │  Layer    │  │    │  │ Functions │  │    └─────────────────┘
│  └───────────┘  │    │  │ (Future)  │  │
└─────────────────┘    │  └───────────┘  │
                       └─────────────────┘
```

### Technology Stack

**Frontend:**
- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language
- **Material Design**: UI design system

**Backend:**
- **Firebase**: Backend-as-a-Service platform
- **Firestore**: NoSQL document database
- **Firebase Auth**: Authentication service
- **Firebase Hosting**: Web hosting (for web version)

**Development Tools:**
- **Python**: Backend scripting and data management
- **Firebase Admin SDK**: Server-side Firebase operations
- **Git**: Version control

## 📱 Application Architecture

### Feature-Based Architecture

The app follows a **feature-based modular architecture** that promotes:
- **Separation of concerns**
- **Code reusability**
- **Maintainability**
- **Testability**
- **Team collaboration**

```
lib/
├── app/                    # Application-level configuration
│   └── config/            # App configuration and setup
├── features/              # Feature modules (business domains)
│   ├── auth/             # Authentication feature
│   ├── admin/            # Administration feature
│   └── home/             # Survey interface feature
├── shared/               # Shared code across features
│   ├── data/            # Shared data services
│   ├── presentation/    # Shared UI components
│   └── utils/           # Utilities and helpers
└── theme/               # Application theming
```

### Layer Architecture

Each feature follows a **layered architecture**:

```
Feature Module
├── data/                  # Data Layer
│   ├── models/           # Data models and entities
│   └── services/         # Data services and repositories
├── logic/                # Business Logic Layer (optional)
│   ├── cubits/          # State management (BLoC/Cubit)
│   └── states/          # State definitions
└── presentation/         # Presentation Layer
    ├── screens/         # Full-screen widgets
    └── widgets/         # Reusable UI components
```

## 🎯 Design Patterns

### 1. Repository Pattern

**Purpose**: Abstract data access logic from business logic.

```dart
abstract class UserRepository {
  Future<User?> getCurrentUser();
  Future<bool> isUserAdmin(String userId);
  Future<void> updateUserProfile(User user);
}

class FirebaseUserRepository implements UserRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  
  @override
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }
  
  @override
  Future<bool> isUserAdmin(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data()?['isAdmin'] ?? false;
  }
}
```

### 2. BLoC/Cubit Pattern

**Purpose**: Manage application state reactively.

```dart
class AuthCubit extends Cubit<AuthState> {
  final UserRepository _userRepository;
  
  AuthCubit(this._userRepository) : super(AuthInitial());
  
  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _userRepository.signIn(email, password);
      final isAdmin = await _userRepository.isUserAdmin(user.uid);
      emit(UserSignIn(user: user, isAdmin: isAdmin));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}
```

### 3. Provider Pattern

**Purpose**: Dependency injection and state sharing.

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<QuestionStore>(
          create: (_) => getIt<QuestionStore>(),
        ),
        ChangeNotifierProvider<ResponseProvider>(
          create: (_) => getIt<ResponseProvider>(),
        ),
      ],
      child: MaterialApp(/* ... */),
    );
  }
}
```

### 4. Singleton Pattern

**Purpose**: Ensure single instance of critical services.

```dart
class EnvironmentConfig {
  static final EnvironmentConfig _instance = EnvironmentConfig._internal();
  factory EnvironmentConfig() => _instance;
  EnvironmentConfig._internal();
  
  bool _isDevelopment = true;
  
  bool get isDevelopment => _isDevelopment;
  set isDevelopment(bool value) => _isDevelopment = value;
}
```

### 5. Factory Pattern

**Purpose**: Create objects without specifying exact classes.

```dart
abstract class QuestionWidget {
  Widget build(QuestionModel question);
}

class QuestionWidgetFactory {
  static QuestionWidget create(QuestionType type) {
    switch (type) {
      case QuestionType.text:
        return TextQuestionWidget();
      case QuestionType.multipleChoice:
        return MultipleChoiceQuestionWidget();
      case QuestionType.rating:
        return RatingQuestionWidget();
      default:
        throw UnsupportedError('Question type not supported: $type');
    }
  }
}
```

## 🔄 Data Flow

### Authentication Flow

```
User Input → AuthCubit → Firebase Auth → Firestore → AuthState → UI Update
```

**Detailed Flow:**
1. User enters credentials in UI
2. AuthCubit processes authentication request
3. Firebase Auth validates credentials
4. Firestore checked for user admin status
5. AuthState emitted with user data and role
6. UI updates based on new state

### Survey Response Flow

```
User Response → QuestionStore → Local Cache → Firebase Sync → UI Update
```

**Detailed Flow:**
1. User provides response to question
2. QuestionStore saves response locally
3. Response cached for offline access
4. Background sync to Firestore
5. UI updated with save confirmation

### Admin Operations Flow

```
Admin Action → Service Layer → Firebase Admin → Firestore → State Update → UI Refresh
```

**Detailed Flow:**
1. Admin performs action (create user, send notification)
2. Appropriate service handles business logic
3. Firebase Admin SDK executes operation
4. Firestore data updated
5. Local state updated
6. UI refreshes with new data

## 📊 State Management

### State Management Strategy

The app uses a **hybrid state management approach**:

1. **BLoC/Cubit**: For complex business logic and authentication
2. **Provider**: For dependency injection and simple state sharing
3. **Local State**: For UI-specific state (form inputs, animations)

### State Architecture

```dart
// Global State (App Level)
MultiProvider(
  providers: [
    // Authentication state
    BlocProvider<AuthCubit>(create: (_) => getIt<AuthCubit>()),
    
    // Survey data state
    ChangeNotifierProvider<QuestionStore>(create: (_) => getIt<QuestionStore>()),
    
    // Response state
    ChangeNotifierProvider<ResponseProvider>(create: (_) => getIt<ResponseProvider>()),
  ],
  child: App(),
)

// Feature State (Feature Level)
BlocProvider<AdminCubit>(
  create: (_) => AdminCubit(),
  child: AdminFeature(),
)

// Local State (Widget Level)
class _QuestionCardState extends State<QuestionCard> {
  bool _isExpanded = false;
  // ... local state management
}
```

### State Persistence

```dart
class QuestionStore extends ChangeNotifier {
  Map<String, String> _responses = {};
  
  // Auto-save responses locally
  void saveResponse(String questionId, String response) {
    _responses[questionId] = response;
    _saveToLocalStorage();
    _syncToFirebase();
    notifyListeners();
  }
  
  Future<void> _saveToLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('responses', jsonEncode(_responses));
  }
}
```

## 🔒 Security Architecture

### Authentication Security

```dart
// Multi-layer authentication
class AuthService {
  // 1. Firebase Authentication
  Future<User?> signInWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // 2. Email verification check
    if (!credential.user!.emailVerified) {
      throw AuthException('Email not verified');
    }
    
    // 3. Admin status verification
    final isAdmin = await _checkAdminStatus(credential.user!.uid);
    
    return credential.user;
  }
}
```

### Data Security

**Firestore Security Rules:**
```javascript
// Role-based access control
match /users/{userId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}

// Admin-only operations
match /admin/{document} {
  allow read, write: if request.auth != null && 
    get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
}
```

### Environment Security

```dart
class EnvironmentConfig {
  String getCollectionName(String collectionName) {
    if (_isDevelopment) {
      return 'dev-$collectionName';  // Isolate development data
    }
    return collectionName;
  }
}
```

## ⚡ Performance Considerations

### Widget Optimization

```dart
// Use const constructors
class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.question,
    required this.onResponseChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return const Card(/* ... */);  // Const where possible
  }
}

// Selective rebuilds
Consumer<QuestionStore>(
  builder: (context, store, child) {
    return ListView.builder(
      itemCount: store.questions.length,
      itemBuilder: (context, index) {
        return QuestionCard(
          question: store.questions[index],
          onResponseChanged: store.saveResponse,
        );
      },
    );
  },
)
```

### Data Loading Optimization

```dart
class QuestionStore extends ChangeNotifier {
  // Lazy loading
  Future<void> loadQuestions() async {
    if (_questions.isNotEmpty) return;  // Already loaded
    
    _isLoading = true;
    notifyListeners();
    
    try {
      // Load with pagination
      final snapshot = await _firestore
          .collection('questions')
          .limit(20)
          .get();
      
      _questions = snapshot.docs.map((doc) => QuestionModel.fromDoc(doc)).toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### Caching Strategy

```dart
class CacheManager {
  static final Map<String, dynamic> _cache = {};
  
  static T? get<T>(String key) => _cache[key] as T?;
  
  static void set<T>(String key, T value, {Duration? ttl}) {
    _cache[key] = value;
    if (ttl != null) {
      Timer(ttl, () => _cache.remove(key));
    }
  }
}
```

## 📈 Scalability

### Horizontal Scaling

**Firebase Firestore** automatically scales:
- **Read/Write Scaling**: Automatic scaling based on demand
- **Geographic Distribution**: Multi-region deployment
- **Concurrent Users**: Supports millions of concurrent users

### Code Scalability

**Feature Modularity:**
```dart
// Easy to add new features
lib/features/
├── auth/           # Existing
├── admin/          # Existing  
├── home/           # Existing
├── analytics/      # New feature
├── notifications/  # New feature
└── reporting/      # New feature
```

**Service Abstraction:**
```dart
// Easy to swap implementations
abstract class NotificationService {
  Future<void> sendNotification(String userId, String message);
}

class FirebaseNotificationService implements NotificationService {
  // Firebase implementation
}

class PushNotificationService implements NotificationService {
  // Push notification implementation
}
```

### Database Scaling

**Collection Design:**
```javascript
// Scalable collection structure
/users/{userId}                    // User documents
/questions/{questionId}            // Question documents  
/responses/{userId}/answers/{id}   // Nested responses for scalability
/admin/{adminId}                   // Admin-specific data
```

**Indexing Strategy:**
```javascript
// Composite indexes for efficient queries
{
  "collectionGroup": "responses",
  "queryScope": "COLLECTION",
  "fields": [
    {"fieldPath": "userId", "order": "ASCENDING"},
    {"fieldPath": "timestamp", "order": "DESCENDING"}
  ]
}
```

## 🔧 Development Workflow

### Environment Management

```bash
# Development workflow
git checkout develop
cd scripts && python toggle_environment.py dev
flutter run

# Production deployment
git checkout main
cd scripts && python toggle_environment.py prod
flutter build apk --release
```

### Testing Strategy

```dart
// Unit tests
group('AuthCubit', () {
  test('should emit UserSignIn when authentication succeeds', () {
    // Test implementation
  });
});

// Widget tests
testWidgets('QuestionCard should display question title', (tester) async {
  // Widget test implementation
});

// Integration tests
void main() {
  group('Survey Flow', () {
    testWidgets('complete survey flow', (tester) async {
      // End-to-end test
    });
  });
}
```

## 🔗 Related Documentation

- [Main App Documentation](../README.md)
- [Deployment Guide](DEPLOYMENT.md)
- [Feature Documentation](../lib/features/)

---

**Last Updated**: January 2025  
**Version**: 2.0.0
