/// Extension methods to add functionality to existing classes
library extensions;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// String extensions for common operations
extension StringExtensions on String {
  /// Validates if the string is a valid email address
  bool get isValidEmail =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);

  /// Capitalizes the first letter of the string
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Converts string to title case
  String get toTitleCase =>
      split(' ').map((word) => word.isEmpty ? word : word.capitalize).join(' ');

  /// Checks if string is null or empty
  bool get isNullOrEmpty => isEmpty;

  /// Removes all whitespace from string
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Truncates string to specified length with ellipsis
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  /// Validates if string contains only numbers
  bool get isNumeric => RegExp(r'^[0-9]+$').hasMatch(this);

  /// Validates password strength (min 8 chars, uppercase, lowercase, number)
  bool get isStrongPassword {
    return length >= 8 &&
        contains(RegExp(r'[A-Z]')) &&
        contains(RegExp(r'[a-z]')) &&
        contains(RegExp(r'[0-9]'));
  }
}

/// DateTime extensions for common date operations
extension DateTimeExtensions on DateTime {
  /// Formats date as yyyy-MM-dd
  String get formattedDate => DateFormat('yyyy-MM-dd').format(this);

  /// Formats date as MMM dd, yyyy
  String get formattedDateLong => DateFormat('MMM dd, yyyy').format(this);

  /// Formats time as HH:mm
  String get formattedTime => DateFormat('HH:mm').format(this);

  /// Formats date and time as MMM dd, yyyy HH:mm
  String get formattedDateTime => DateFormat('MMM dd, yyyy HH:mm').format(this);

  /// Checks if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Checks if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Checks if date is in the current week
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Gets relative time string (e.g., "2 hours ago", "yesterday")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}

/// BuildContext extensions for common UI operations
extension BuildContextExtensions on BuildContext {
  /// Shows error snackbar with consistent styling
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(this).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Shows success snackbar with consistent styling
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Shows info snackbar with consistent styling
  void showInfoSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(this).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Gets screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Gets screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Checks if device is in landscape mode
  bool get isLandscape =>
      MediaQuery.of(this).orientation == Orientation.landscape;

  /// Checks if device is a tablet (width > 600)
  bool get isTablet => screenWidth > 600;

  /// Gets safe area padding
  EdgeInsets get safeAreaPadding => MediaQuery.of(this).padding;

  /// Unfocuses current focus node
  void unfocus() => FocusScope.of(this).unfocus();

  /// Pushes named route and removes all previous routes
  Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String routeName, {
    bool Function(Route<dynamic>)? predicate,
    Object? arguments,
  }) {
    return Navigator.of(this).pushNamedAndRemoveUntil(
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  /// Pops current route
  void pop<T extends Object?>([T? result]) {
    return Navigator.of(this).pop(result);
  }
}

/// List extensions for common operations
extension ListExtensions<T> on List<T> {
  /// Safely gets element at index, returns null if out of bounds
  T? safeGet(int index) {
    if (index >= 0 && index < length) {
      return this[index];
    }
    return null;
  }

  /// Adds element if it doesn't already exist
  void addIfNotExists(T element) {
    if (!contains(element)) {
      add(element);
    }
  }

  /// Removes duplicates from list
  List<T> get unique {
    return toSet().toList();
  }

  /// Chunks list into smaller lists of specified size
  List<List<T>> chunk(int size) {
    List<List<T>> chunks = [];
    for (int i = 0; i < length; i += size) {
      chunks.add(sublist(i, i + size > length ? length : i + size));
    }
    return chunks;
  }
}

/// Map extensions for common operations
extension MapExtensions<K, V> on Map<K, V> {
  /// Safely gets value by key, returns null if key doesn't exist
  V? safeGet(K key) {
    return containsKey(key) ? this[key] : null;
  }

  /// Gets value by key or returns default value
  V getOrDefault(K key, V defaultValue) {
    return containsKey(key) ? this[key]! : defaultValue;
  }
}

/// Color extensions for common color operations
extension ColorExtensions on Color {
  /// Converts color to hex string
  String get toHex {
    return '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  /// Creates a lighter version of the color
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Creates a darker version of the color
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}
