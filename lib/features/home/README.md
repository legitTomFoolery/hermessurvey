# Survey Interface

The survey interface provides an intuitive and responsive user experience for completing surveys in the GSEC Survey App. It features dynamic question rendering, real-time response saving, and comprehensive progress tracking.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Question Types](#question-types)
- [Response Management](#response-management)
- [User Experience](#user-experience)
- [Data Models](#data-models)
- [State Management](#state-management)
- [API Reference](#api-reference)
- [Testing](#testing)

## 🎯 Overview

The survey interface is the primary user-facing component that provides:

- **Dynamic Question Rendering**: Supports multiple question types with adaptive UI
- **Real-time Response Saving**: Automatic saving of user responses
- **Progress Tracking**: Visual progress indicators and completion status
- **Offline Support**: Continue surveys without internet connection
- **Responsive Design**: Optimized for mobile, tablet, and desktop
- **Accessibility**: Full accessibility support for all users

## 🏗️ Architecture

### Directory Structure

```
lib/features/home/
├── data/                          # Data layer
│   ├── models/                   # Data models
│   │   ├── question_model.dart   # Question data structure
│   │   └── survey_response_model.dart # Response data structure
│   └── services/                 # Business services
│       └── question_store.dart   # Question management service
└── presentation/                  # UI layer
    ├── screens/                  # Main survey screens
    │   ├── home_screen.dart      # Main survey interface
    │   └── submission_result_screen.dart # Completion screen
    └── widgets/                  # Survey UI components
        ├── question_card.dart    # Individual question display
        └── question_response_widget.dart # Response input widgets
```

### Key Components

#### QuestionStore (`question_store.dart`)
Central service for managing survey questions and responses.

**Responsibilities:**
- Load questions from Firebase
- Manage response state
- Handle response submission
- Track completion progress

#### Question Models
- **QuestionModel**: Defines question structure and metadata
- **SurveyResponseModel**: Manages user response data

#### UI Components
- **QuestionCard**: Displays individual questions with appropriate input widgets
- **QuestionResponseWidget**: Handles different response input types
- **Progress Indicators**: Shows survey completion status

## ✨ Features

### Dynamic Question Loading
- **Firebase Integration**: Questions loaded from Firestore in real-time
- **Caching**: Local caching for offline access
- **Error Handling**: Graceful handling of loading failures
- **Retry Mechanism**: Automatic retry for failed requests

### Real-time Response Saving
- **Auto-save**: Responses saved automatically as user types
- **Conflict Resolution**: Handles concurrent editing scenarios
- **Offline Queue**: Queues responses when offline for later sync
- **Data Validation**: Client-side validation before saving

### Progress Tracking
- **Visual Progress Bar**: Shows completion percentage
- **Question Counter**: "X of Y questions completed"
- **Section Progress**: Progress within question sections
- **Completion Status**: Clear indication of survey completion

### Responsive Design
- **Mobile-first**: Optimized for mobile devices
- **Tablet Support**: Enhanced layout for larger screens
- **Desktop Compatibility**: Full desktop browser support
- **Orientation Support**: Adapts to portrait/landscape modes

## 📝 Question Types

The survey interface supports multiple question types with specialized input widgets:

### 1. Text Input Questions
```dart
// Short text responses
TextFormField(
  decoration: InputDecoration(
    hintText: 'Enter your response...',
  ),
  onChanged: (value) => saveResponse(questionId, value),
)
```

### 2. Multiple Choice Questions
```dart
// Single selection from options
RadioListTile<String>(
  title: Text(option.text),
  value: option.value,
  groupValue: selectedValue,
  onChanged: (value) => saveResponse(questionId, value),
)
```

### 3. Checkbox Questions
```dart
// Multiple selections allowed
CheckboxListTile(
  title: Text(option.text),
  value: isSelected,
  onChanged: (value) => toggleSelection(questionId, option.value),
)
```

### 4. Rating Scale Questions
```dart
// Numeric rating scales
Slider(
  value: currentRating,
  min: 1.0,
  max: 5.0,
  divisions: 4,
  onChanged: (value) => saveResponse(questionId, value.toString()),
)
```

### 5. Date/Time Questions
```dart
// Date and time selection
DatePicker(
  initialDate: DateTime.now(),
  onDateSelected: (date) => saveResponse(questionId, date.toIso8601String()),
)
```

### 6. File Upload Questions
```dart
// File attachment support
FilePicker(
  allowedExtensions: ['pdf', 'doc', 'jpg', 'png'],
  onFileSelected: (file) => uploadAndSaveResponse(questionId, file),
)
```

## 💾 Response Management

### Response Storage
- **Local Storage**: Responses cached locally for offline access
- **Cloud Sync**: Automatic synchronization with Firebase
- **Conflict Resolution**: Handles conflicts between local and cloud data
- **Data Integrity**: Ensures response data consistency

### Response Validation
```dart
class ResponseValidator {
  static String? validateTextResponse(String? value, bool isRequired) {
    if (isRequired && (value == null || value.isEmpty)) {
      return 'This field is required';
    }
    return null;
  }
  
  static String? validateEmailResponse(String? value) {
    if (value != null && !EmailValidator.validate(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
}
```

### Response Submission
```dart
// Submit completed survey
Future<void> submitSurvey() async {
  try {
    // Validate all responses
    final validationErrors = validateAllResponses();
    if (validationErrors.isNotEmpty) {
      showValidationErrors(validationErrors);
      return;
    }
    
    // Submit to Firebase
    await QuestionStore.submitResponses(responses);
    
    // Navigate to success screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => SubmissionResultScreen()),
    );
  } catch (e) {
    showErrorDialog('Failed to submit survey: $e');
  }
}
```

## 🎨 User Experience

### Loading States
- **Skeleton Loading**: Placeholder content while loading questions
- **Progressive Loading**: Load questions as user progresses
- **Error States**: Clear error messages with retry options
- **Empty States**: Helpful messages when no questions available

### Navigation
- **Next/Previous**: Easy navigation between questions
- **Jump to Question**: Quick navigation to specific questions
- **Auto-advance**: Automatic progression for certain question types
- **Save and Exit**: Allow users to save progress and return later

### Accessibility
- **Screen Reader Support**: Full VoiceOver/TalkBack compatibility
- **Keyboard Navigation**: Complete keyboard accessibility
- **High Contrast**: Support for high contrast themes
- **Font Scaling**: Respects system font size settings

### Offline Support
```dart
class OfflineManager {
  static Future<void> cacheQuestions(List<Question> questions) async {
    // Cache questions locally
  }
  
  static Future<void> queueResponse(String questionId, String response) async {
    // Queue response for later sync
  }
  
  static Future<void> syncQueuedResponses() async {
    // Sync when connection restored
  }
}
```

## 📊 Data Models

### QuestionModel
```dart
class QuestionModel {
  final String id;
  final String title;
  final String description;
  final QuestionType type;
  final bool isRequired;
  final List<String>? options;
  final Map<String, dynamic>? validation;
  final int order;
  
  const QuestionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.isRequired,
    this.options,
    this.validation,
    required this.order,
  });
}

enum QuestionType {
  text,
  multipleChoice,
  checkbox,
  rating,
  date,
  file,
  dropdown,
}
```

### SurveyResponseModel
```dart
class SurveyResponseModel {
  final String id;
  final String userId;
  final String questionId;
  final String response;
  final DateTime timestamp;
  final bool isComplete;
  
  const SurveyResponseModel({
    required this.id,
    required this.userId,
    required this.questionId,
    required this.response,
    required this.timestamp,
    required this.isComplete,
  });
}
```

## 🔄 State Management

### QuestionStore (Provider)
```dart
class QuestionStore extends ChangeNotifier {
  List<QuestionModel> _questions = [];
  Map<String, String> _responses = {};
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<QuestionModel> get questions => _questions;
  Map<String, String> get responses => _responses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Methods
  Future<void> loadQuestions() async { /* ... */ }
  void saveResponse(String questionId, String response) { /* ... */ }
  Future<void> submitResponses() async { /* ... */ }
  double get completionPercentage { /* ... */ }
}
```

### Usage in UI
```dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<QuestionStore>(
      builder: (context, questionStore, child) {
        if (questionStore.isLoading) {
          return LoadingWidget();
        }
        
        if (questionStore.error != null) {
          return ErrorWidget(
            error: questionStore.error!,
            onRetry: () => questionStore.loadQuestions(),
          );
        }
        
        return QuestionListView(
          questions: questionStore.questions,
          responses: questionStore.responses,
          onResponseChanged: questionStore.saveResponse,
        );
      },
    );
  }
}
```

## 📚 API Reference

### QuestionStore Methods

#### `loadQuestions()`
Load survey questions from Firebase.

**Returns:** `Future<void>`

**Throws:** `Exception` if loading fails

#### `saveResponse(String questionId, String response)`
Save user response for a specific question.

**Parameters:**
- `questionId`: Unique question identifier
- `response`: User's response value

**Returns:** `void`

#### `submitResponses()`
Submit all responses to Firebase.

**Returns:** `Future<void>`

**Throws:** `Exception` if submission fails

#### `getResponse(String questionId)`
Get saved response for a question.

**Parameters:**
- `questionId`: Question identifier

**Returns:** `String?` - Saved response or null

#### `completionPercentage`
Get survey completion percentage.

**Returns:** `double` - Percentage (0.0 to 1.0)

### Question Widget API

#### `QuestionCard`
```dart
QuestionCard({
  required QuestionModel question,
  String? savedResponse,
  required Function(String) onResponseChanged,
  bool isReadOnly = false,
})
```

#### `QuestionResponseWidget`
```dart
QuestionResponseWidget({
  required QuestionModel question,
  String? initialValue,
  required Function(String) onChanged,
  bool enabled = true,
})
```

## 🧪 Testing

### Unit Tests
```bash
# Run home feature tests
flutter test test/unit/home/

# Test question store
flutter test test/unit/home/question_store_test.dart
```

### Widget Tests
```bash
# Test survey widgets
flutter test test/widget/home/

# Test question cards
flutter test test/widget/home/question_card_test.dart
```

### Integration Tests
```bash
# Test complete survey flow
flutter test integration_test/survey_flow_test.dart
```

### Test Examples
```dart
group('QuestionStore', () {
  late QuestionStore questionStore;
  
  setUp(() {
    questionStore = QuestionStore();
  });
  
  test('should save response correctly', () {
    questionStore.saveResponse('q1', 'test response');
    expect(questionStore.getResponse('q1'), equals('test response'));
  });
  
  test('should calculate completion percentage', () {
    // Setup test data
    questionStore.loadTestQuestions(3);
    questionStore.saveResponse('q1', 'answer1');
    
    expect(questionStore.completionPercentage, equals(1.0 / 3.0));
  });
});
```

## 🚀 Usage Examples

### Basic Survey Screen
```dart
class SurveyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Survey'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: Consumer<QuestionStore>(
            builder: (context, store, _) => LinearProgressIndicator(
              value: store.completionPercentage,
            ),
          ),
        ),
      ),
      body: Consumer<QuestionStore>(
        builder: (context, questionStore, _) {
          return ListView.builder(
            itemCount: questionStore.questions.length,
            itemBuilder: (context, index) {
              final question = questionStore.questions[index];
              return QuestionCard(
                question: question,
                savedResponse: questionStore.getResponse(question.id),
                onResponseChanged: (response) => 
                    questionStore.saveResponse(question.id, response),
              );
            },
          );
        },
      ),
      floatingActionButton: Consumer<QuestionStore>(
        builder: (context, store, _) => FloatingActionButton(
          onPressed: store.completionPercentage == 1.0 
              ? () => store.submitResponses()
              : null,
          child: Icon(Icons.send),
        ),
      ),
    );
  }
}
```

## 📝 Best Practices

1. **Always validate responses** before submission
2. **Provide clear progress indicators** to users
3. **Handle offline scenarios** gracefully
4. **Implement auto-save** to prevent data loss
5. **Use appropriate input widgets** for each question type
6. **Provide accessibility support** for all users
7. **Test on multiple screen sizes** and orientations

## 🔗 Related Documentation

- [Authentication System](../auth/README.md)
- [Admin Panel](../admin/README.md)
- [Main App Documentation](../../README.md)

---

**Last Updated**: January 2025  
**Version**: 2.0.0
