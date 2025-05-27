/// Common callback type definitions for improved code clarity and type safety
library typedefs;

/// Callback for handling question responses
typedef QuestionResponseCallback = void Function(
    String questionId, String response);

/// Callback for handling errors with error message
typedef ErrorCallback = void Function(String error);

/// Callback for handling success operations
typedef SuccessCallback = void Function();

/// Callback for handling authentication state changes
typedef AuthStateCallback = void Function(bool isAuthenticated, bool isAdmin);

/// Callback for handling data loading states
typedef LoadingStateCallback = void Function(bool isLoading);

/// Callback for handling form validation
typedef ValidationCallback = String? Function(String? value);

/// Callback for handling async operations with result
typedef AsyncCallback<T> = Future<T> Function();

/// Callback for handling list item selection
typedef ItemSelectionCallback<T> = void Function(T item);

/// Callback for handling confirmation dialogs
typedef ConfirmationCallback = void Function(bool confirmed);

/// Callback for handling navigation
typedef NavigationCallback = void Function(String route);

/// Callback for handling file operations
typedef FileOperationCallback = void Function(String filePath);
