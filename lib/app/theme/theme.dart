import 'package:flutter/material.dart';
import './custom_colors.dart';
export './custom_colors.dart';

ThemeData createLightTheme() {
  return ThemeData(brightness: Brightness.light);
}

ThemeData createLightTheme2() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'PTSans',
    // primarySwatch: Colors.green,
    // colorSchemeSeed: ThemeColors.klee,
    appBarTheme: AppBarTheme(backgroundColor: CustomColors.sand.shade700),
    colorScheme: ColorScheme.fromSwatch(
      backgroundColor: CustomColors.sand.shade700,
      primarySwatch: CustomColors.tanne,
      // accentColor: Colors.black,
      // accentColor: ThemeColors.klee.shade400,
      // errorColor: Colors.deepOrange,
      // brightness: Brightness.light,
    ),
    // outlinedButtonTheme: OutlinedButtonThemeData(
    //   style: OutlinedButton.styleFrom(
    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    //     side: const BorderSide(
    //       width: 1.0,
    //       color: CustomColors.tanne,
    //     ),
    //   ),
    // ),
    // filledButtonTheme: FilledButtonThemeData(
    //   style: ButtonStyle(
    //     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    //       RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    //     ),
    //   ),
    // ),
  );
}

ThemeData createDarkTheme() {
  // return createLightTheme().copyWith(
  //   brightness: Brightness.dark,
  // );
  return ThemeData(brightness: Brightness.dark);
}

ThemeData createDarkTheme2() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    appBarTheme: AppBarTheme(backgroundColor: CustomColors.tanneBg.toColor()),
    fontFamily: 'PTSans',
    // primarySwatch: Colors.green,
    // scaffoldBackgroundColor: ThemeColors.klee,
    // colorSchemeSeed: ThemeColors.himmel,
    // colorScheme: ColorScheme.dark(

    //   background: ThemeColors.tanneBg.toColor(),
    //   primary: ThemeColors.himmel.shade600,
    //   brightness: Brightness.dark,

    // ),
    colorScheme: ColorScheme.fromSwatch(
      backgroundColor: CustomColors.tanneBg.toColor(),
      primarySwatch: CustomColors.himmel,
      errorColor: Colors.deepOrange,
    ),
    filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    )),
  );
}
