import 'package:flutter/material.dart';
import 'colors.dart';
import 'styles.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: ColorsManager.mainBlue,
  scaffoldBackgroundColor: ColorsManager.darkBlue,
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: ColorsManager.mainBlue,
    selectionColor: Color.fromARGB(188, 36, 124, 255),
    selectionHandleColor: ColorsManager.mainBlue,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
        fontSize: 10, fontWeight: FontWeight.bold, color: DarkColors.text),
    headlineLarge: TextStyle(
        fontSize: 22, fontWeight: FontWeight.bold, color: DarkColors.text),
    titleLarge: TextStyle(
        fontSize: 20, fontWeight: FontWeight.bold, color: DarkColors.text),
    bodyLarge: TextStyle(
        fontSize: 16, fontWeight: FontWeight.normal, color: DarkColors.text),
    bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: DarkColors.secondaryText),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: ColorsManager.mainBlue,
    titleTextStyle: TextStyles.font16White600Weight,
  ),
  // Add other theme properties here as needed
);
