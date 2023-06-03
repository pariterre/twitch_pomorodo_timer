import 'package:flutter/material.dart';

class ThemeColor {
  static const Color greenScreen = Color.fromARGB(255, 0, 255, 0);
  static const Color main = Color.fromARGB(255, 45, 74, 168);
  static const Color text = Colors.white;
  static const Color conceiled = Color.fromARGB(255, 45, 74, 168);
  static const Color conceiledContrast = Colors.amber;
  static const Color revealed = Color.fromARGB(255, 204, 234, 248);
}

class ThemeButton {
  static ButtonStyle elevated =
      ElevatedButton.styleFrom(backgroundColor: Colors.white);
}

class ThemeSize {
  static double title(context) => MediaQuery.of(context).size.height * 0.028;
  static double text(context) => MediaQuery.of(context).size.height * 0.02;
}

class ThemePadding {
  static double normal(context) => MediaQuery.of(context).size.height * 0.015;
  static double interline(context) =>
      MediaQuery.of(context).size.height * 0.005;
}
