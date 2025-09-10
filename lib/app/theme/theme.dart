import 'package:flutter/material.dart';

const verdigadoPink = Color(0xFFE60064);
const verdigadoRed = Color(0xFFA00057);
const verdigadoBlack = Color(0xFF00354E);
const verdigadoWhite = Color(0xFFFFFFFF);

class CustomTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: verdigadoPink).copyWith(secondary: verdigadoRed),
    textTheme: TextTheme(
      displayLarge: TextStyle(fontFamily: 'iAWriter', color: verdigadoBlack),
      displayMedium: TextStyle(fontFamily: 'iAWriter', color: verdigadoBlack),
      displaySmall: TextStyle(fontFamily: 'iAWriter', color: verdigadoBlack),

      headlineLarge: TextStyle(fontFamily: 'iAWriter', color: verdigadoBlack),
      headlineMedium: TextStyle(fontFamily: 'iAWriter', color: verdigadoBlack),
      headlineSmall: TextStyle(fontFamily: 'iAWriter', color: verdigadoBlack),

      titleLarge: TextStyle(fontFamily: 'iAWriter', color: verdigadoBlack),
      titleMedium: TextStyle(fontFamily: 'iAWriter', color: verdigadoBlack),
      titleSmall: TextStyle(fontFamily: 'iAWriter', color: verdigadoBlack),

      bodyLarge: TextStyle(fontFamily: 'Sarabun', color: verdigadoBlack),
      bodyMedium: TextStyle(fontFamily: 'Sarabun', color: verdigadoBlack),
      bodySmall: TextStyle(fontFamily: 'Sarabun', color: verdigadoBlack),

      labelLarge: TextStyle(fontFamily: 'Sarabun', color: verdigadoBlack),
      labelMedium: TextStyle(fontFamily: 'Sarabun', color: verdigadoBlack),
      labelSmall: TextStyle(fontFamily: 'Sarabun', color: verdigadoBlack),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: verdigadoPink,
    ).copyWith(secondary: verdigadoRed, surface: verdigadoBlack),
    textTheme: TextTheme(
      displayLarge: TextStyle(fontFamily: 'iAWriter', color: verdigadoWhite),
      displayMedium: TextStyle(fontFamily: 'iAWriter', color: verdigadoWhite),
      displaySmall: TextStyle(fontFamily: 'iAWriter', color: verdigadoWhite),

      headlineLarge: TextStyle(fontFamily: 'iAWriter', color: verdigadoWhite),
      headlineMedium: TextStyle(fontFamily: 'iAWriter', color: verdigadoWhite),
      headlineSmall: TextStyle(fontFamily: 'iAWriter', color: verdigadoWhite),

      titleLarge: TextStyle(fontFamily: 'iAWriter', color: verdigadoWhite),
      titleMedium: TextStyle(fontFamily: 'iAWriter', color: verdigadoWhite),
      titleSmall: TextStyle(fontFamily: 'iAWriter', color: verdigadoWhite),

      bodyLarge: TextStyle(fontFamily: 'Sarabun', color: verdigadoWhite),
      bodyMedium: TextStyle(fontFamily: 'Sarabun', color: verdigadoWhite),
      bodySmall: TextStyle(fontFamily: 'Sarabun', color: verdigadoWhite),

      labelLarge: TextStyle(fontFamily: 'Sarabun', color: verdigadoWhite),
      labelMedium: TextStyle(fontFamily: 'Sarabun', color: verdigadoWhite),
      labelSmall: TextStyle(fontFamily: 'Sarabun', color: verdigadoWhite),
    ),
  );
}
