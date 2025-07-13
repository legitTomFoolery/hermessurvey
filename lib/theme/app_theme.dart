import 'package:flutter/material.dart';
import 'colors.dart';
import 'styles.dart';
import 'package:gsecsurvey/app/config/app_constants.dart';

/// Centralized theme configuration for the application
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// Light theme configuration
  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        primaryColor: ColorsManager.mainBlue,
        scaffoldBackgroundColor: ColorsManager.lightShadeOfGray,
        colorScheme: const ColorScheme.light().copyWith(
          primary: const Color.fromARGB(255, 141, 27, 27),
          secondary: Colors.white,
          tertiary: const Color.fromARGB(255, 188, 188, 188),
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          surface: const Color.fromARGB(255, 236, 230, 240),
          shadow: const Color.fromARGB(255, 24, 24, 24),
          outline: LightColors.fieldOutline,
          surfaceContainerHighest: LightColors.fieldFill,
          error: LightColors.danger,
          onSurfaceVariant: LightColors.modalSecondaryText,
          // Using inversePrimary for success color (green)
          inversePrimary: LightColors.success,
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: const Color.fromARGB(255, 141, 27, 27),
          selectionColor: const Color.fromARGB(188, 36, 124, 255),
          selectionHandleColor: const Color.fromARGB(255, 141, 27, 27),
        ),
        textTheme: _buildTextTheme(LightColors.text, LightColors.secondaryText),
        appBarTheme: AppBarTheme(
          backgroundColor: ColorsManager.mainBlue,
          titleTextStyle: TextStyles.font16White600Weight,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        elevatedButtonTheme: _buildElevatedButtonTheme(),
        textButtonTheme: _buildTextButtonTheme(),
        inputDecorationTheme: _buildInputDecorationTheme(true),
        floatingActionButtonTheme: _buildFloatingActionButtonTheme(),
      );

  /// Dark theme configuration
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        primaryColor: ColorsManager.mainBlue,
        scaffoldBackgroundColor: ColorsManager.darkBlue,
        colorScheme: const ColorScheme.dark().copyWith(
          primary: const Color.fromARGB(255, 141, 27, 27),
          secondary: Colors.black,
          tertiary: const Color.fromARGB(255, 10, 10, 10),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          surface: const Color.fromARGB(255, 42, 41, 47),
          shadow: const Color.fromARGB(255, 171, 171, 171),
          outline: DarkColors.fieldOutline,
          surfaceContainerHighest: DarkColors.fieldFill,
          error: DarkColors.danger,
          onSurfaceVariant: DarkColors.modalSecondaryText,
          // Using inversePrimary for success color (green)
          inversePrimary: DarkColors.success,
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: const Color.fromARGB(255, 141, 27, 27),
          selectionColor: const Color.fromARGB(188, 36, 124, 255),
          selectionHandleColor: const Color.fromARGB(255, 141, 27, 27),
        ),
        textTheme: _buildTextTheme(DarkColors.text, DarkColors.secondaryText),
        appBarTheme: AppBarTheme(
          backgroundColor: ColorsManager.mainBlue,
          titleTextStyle: TextStyles.font16White600Weight,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        elevatedButtonTheme: _buildElevatedButtonTheme(),
        textButtonTheme: _buildTextButtonTheme(),
        inputDecorationTheme: _buildInputDecorationTheme(false),
        floatingActionButtonTheme: _buildFloatingActionButtonTheme(),
      );

  /// Build consistent text theme
  static TextTheme _buildTextTheme(Color primaryText, Color secondaryText) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 22.0,
        fontWeight: FontWeight.w500,
        color: primaryText,
      ),
      headlineLarge: TextStyle(
        fontSize: 22.0,
        fontWeight: FontWeight.w500,
        color: primaryText,
      ),
      titleLarge: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w500,
        color: primaryText,
      ),
      bodyLarge: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        color: primaryText,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        color: secondaryText,
      ),
    );
  }

  /// Build elevated button theme
  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.buttonHorizontalPadding,
          vertical: AppConstants.buttonVerticalPadding,
        ),
        minimumSize: Size(double.infinity, AppConstants.defaultButtonHeight),
      ),
    );
  }

  /// Build text button theme
  static TextButtonThemeData _buildTextButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.buttonHorizontalPadding,
          vertical: AppConstants.buttonVerticalPadding,
        ),
        minimumSize: Size(double.infinity, AppConstants.defaultButtonHeight),
      ),
    );
  }

  /// Build input decoration theme
  static InputDecorationTheme _buildInputDecorationTheme(bool isLight) {
    final colors = isLight ? LightColors.background : DarkColors.background;
    final borderColor = isLight
        ? const Color.fromARGB(255, 236, 230, 240)
        : const Color.fromARGB(255, 42, 41, 47);

    return InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: colors,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppConstants.textFieldHorizontalPadding,
        vertical: AppConstants.textFieldVerticalPadding,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        borderSide: BorderSide(
          color: borderColor,
          width: AppConstants.textFieldBorderWidth,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        borderSide: BorderSide(
          color: borderColor,
          width: AppConstants.textFieldBorderWidth,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        borderSide: BorderSide(
          color: ColorsManager.mainBlue,
          width: AppConstants.textFieldBorderWidth,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        borderSide: BorderSide(
          color: ColorsManager.coralRed,
          width: AppConstants.textFieldBorderWidth,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        borderSide: BorderSide(
          color: ColorsManager.coralRed,
          width: AppConstants.textFieldBorderWidth,
        ),
      ),
    );
  }

  /// Build floating action button theme
  static FloatingActionButtonThemeData _buildFloatingActionButtonTheme() {
    return const FloatingActionButtonThemeData(
      shape: CircleBorder(),
      elevation: 6.0,
      highlightElevation: 12.0,
    );
  }
}
