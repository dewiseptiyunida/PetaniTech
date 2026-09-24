import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF51932E);
  static const Color accentColor = Color(0xFF7DB360);
  static const Color primaryDarkColor = Color.fromARGB(255, 53, 82, 38);

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    fontFamily: 'Poppins',
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: primaryColor,
      textTheme: ButtonTextTheme.primary,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blueGrey,
    fontFamily: 'Poppins',
    colorScheme: ColorScheme.dark(
      primary: Colors.blueGrey,
      secondary: Colors.cyanAccent,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blueGrey,
      foregroundColor: Colors.white,
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Colors.cyanAccent,
      textTheme: ButtonTextTheme.primary,
    ),
  );
}
