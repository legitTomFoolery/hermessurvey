import 'package:flutter/material.dart';

class ColorsManager {
  static const Color mainBlue = Color(0xFF247CFF);
  static const Color gray = Color(0xFF757575);
  static const Color gray93Color = Color(0xFFEDEDED);
  static const Color gray76 = Color(0xFFC2C2C2);
  static const Color darkBlue = Color(0xFF242424);
  static const Color lightShadeOfGray = Color(0xFFFDFDFF);
  static const Color mediumLightShadeOfGray = Color(0xFF9E9E9E);
  static const Color coralRed = Color(0xFFFF4C5E);
}

class LightColors {
  static const Color primary = ColorsManager.mainBlue;
  static const Color background = Colors.white;
  static const Color text = Colors.black;
  static const Color secondaryText = ColorsManager.gray;
}

class DarkColors {
  static const Color primary = ColorsManager.mainBlue;
  static const Color background = ColorsManager.darkBlue;
  static const Color text = Colors.white;
  static const Color secondaryText = ColorsManager.gray76;
}
