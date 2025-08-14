import 'package:authenticator_app/app/theme/custom_colors.dart';
import 'package:flutter/material.dart';

export './custom_colors.dart';

ThemeData createLightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'PTSans',
    appBarTheme: AppBarTheme(backgroundColor: CustomColors.sand.shade400),
    inputDecorationTheme: const InputDecorationTheme(
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
    ),
    scaffoldBackgroundColor: CustomColors.sand.shade400,
    colorScheme: ColorScheme.fromSwatch(primarySwatch: CustomColors.tanne),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(width: 1.0, color: CustomColors.tanne),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)))),
    ),
  );
}

ThemeData createDarkTheme() {
  return ThemeData(useMaterial3: true, brightness: Brightness.dark);
}
