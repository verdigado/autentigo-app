import 'package:flutter/material.dart';

const verdigadoPink = Color(0xFFE60064);
const verdigadoRed = Color(0xFFA00057);
const verdigadoBlack = Color(0xFF00354E);
const verdigadoWhite = Color(0xFFFFFFFF);
const lightGrey = Color(0xFFBBBBBB);
const grey = Color(0xFF888888);

class CustomTheme {
  static final primaryColor = verdigadoPink;
  static final secondaryColor = verdigadoRed;
  static final tertiaryColor = verdigadoBlack;
  static final contrastColor = verdigadoWhite;
  static final contrastColorDark = lightGrey;
  static final disabledColor = grey;

  static final warningColor = Colors.deepOrange;
  static final successColor = Colors.greenAccent;

  static TextTheme textTheme(Color textColor) {
    return TextTheme(
      displayLarge: TextStyle(fontFamily: 'iAWriter', color: textColor),
      displayMedium: TextStyle(fontFamily: 'iAWriter', color: textColor),
      displaySmall: TextStyle(fontFamily: 'iAWriter', color: textColor),

      headlineLarge: TextStyle(fontFamily: 'iAWriter', color: textColor),
      headlineMedium: TextStyle(fontFamily: 'iAWriter', color: textColor),
      headlineSmall: TextStyle(fontFamily: 'iAWriter', color: textColor),

      titleLarge: TextStyle(fontFamily: 'iAWriter', color: textColor),
      titleMedium: TextStyle(fontFamily: 'iAWriter', color: textColor),
      titleSmall: TextStyle(fontFamily: 'iAWriter', color: textColor),

      bodyLarge: TextStyle(fontFamily: 'Sarabun', color: textColor),
      bodyMedium: TextStyle(fontFamily: 'Sarabun', color: textColor),
      bodySmall: TextStyle(fontFamily: 'Sarabun', color: textColor),

      labelLarge: TextStyle(fontFamily: 'Sarabun', color: textColor),
      labelMedium: TextStyle(fontFamily: 'Sarabun', color: textColor),
      labelSmall: TextStyle(fontFamily: 'Sarabun', color: textColor),
    );
  }

  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: contrastColor,
    ),
    textTheme: textTheme(tertiaryColor),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(side: BorderSide(color: primaryColor)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: contrastColor,
      contentTextStyle: TextStyle(color: tertiaryColor),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: primaryColor,
      primary: primaryColor,
      onPrimary: contrastColor,
      secondary: secondaryColor,
      surface: tertiaryColor,
    ),
    textTheme: textTheme(contrastColor),
    appBarTheme: AppBarTheme(
      titleTextStyle: textTheme(contrastColor).titleLarge,
      iconTheme: IconThemeData(color: contrastColor),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(side: BorderSide(color: primaryColor)),
    ),
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(disabledBackgroundColor: disabledColor)),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: contrastColor,
      contentTextStyle: TextStyle(color: tertiaryColor),
    ),
  );
}
