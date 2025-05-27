import 'package:flutter/material.dart';
import 'colors.dart';
import 'styles.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: ColorsManager.mainBlue,
  scaffoldBackgroundColor: ColorsManager.lightShadeOfGray,
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: ColorsManager.mainBlue,
    selectionColor: Color.fromARGB(188, 36, 124, 255),
    selectionHandleColor: ColorsManager.mainBlue,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
        fontSize: 10, fontWeight: FontWeight.bold, color: DarkColors.text),
    headlineLarge: TextStyle(
        fontSize: 22, fontWeight: FontWeight.bold, color: LightColors.text),
    titleLarge: TextStyle(
        fontSize: 20, fontWeight: FontWeight.bold, color: LightColors.text),
    bodyLarge: TextStyle(
        fontSize: 16, fontWeight: FontWeight.normal, color: LightColors.text),
    bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: LightColors.secondaryText),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: ColorsManager.mainBlue,
    titleTextStyle: TextStyles.font16White600Weight,
  ),
  // Add other theme properties here
);
