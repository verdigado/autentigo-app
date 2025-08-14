import 'package:flutter/material.dart';

/// Color Palette
// https://zeroheight.com/0cb5678fa/p/17de02-farbwelt

abstract final class CustomColors {
  static const MaterialColor klee = MaterialColor(_kleePrimaryValue, <int, Color>{
    50: Color(0xFFE5F3EB),
    100: Color(0xFFCCE7D7),
    200: Color(0xFFB2DCC4),
    300: Color(0xFF99D0B0),
    400: Color(0xFF66B888),
    500: Color(0xFF33A161),
    600: Color(_kleePrimaryValue),
    700: Color(0xFF006E2E),
    800: Color(0xFF005222),
    900: Color(0xFF003717),
    // 950: Color(0xFF002911),
  });
  static const int _kleePrimaryValue = 0xFF008939;

  static const int _tannePrimaryValue = 0xFF005437;
  static const MaterialColor tanne = MaterialColor(_tannePrimaryValue, <int, Color>{
    50: Color(0xFFD5EEE6),
    100: Color(0xFFBEDDD2),
    200: Color(0xFFA6CCBF),
    300: Color(0xFF8EBBAB),
    400: Color(0xFF5F9885),
    500: Color(0xFF2F765E),
    600: Color(_tannePrimaryValue),
    700: Color(0xFF00432C),
    800: Color(0xFF003221),
    900: Color(0xFF002216),
  });

  // orignal tanne hls(159, 50%, 16%)
  static const HSLColor tanneBg = HSLColor.fromAHSL(1, 159, 0.5, .15);

  static const int _sandPrimaryValue = 0xFFF5F1E9;
  static const MaterialColor sand = MaterialColor(_sandPrimaryValue, <int, Color>{
    400: Color(0xFFF9F6F1),
    500: Color(0xFFF7F4ED),
    600: Color(_sandPrimaryValue),
    700: Color(0xFFEFE8DB),
  });

  static const int _sonnePrimaryValue = 0xFFFFF17A;
  static const MaterialColor sonne = MaterialColor(_sonnePrimaryValue, <int, Color>{
    600: Color(_sonnePrimaryValue),
  });

  static const int _himmelPrimaryValue = 0xFF0BA1DD;
  static const MaterialColor himmel = MaterialColor(_himmelPrimaryValue, <int, Color>{
    500: Color(0xFF3CB4E4),
    600: Color(_himmelPrimaryValue),
    700: Color(0xFF0981B1),
  });

  static const int _grashalmPrimaryValue = 0xFF8ABD24;
  static const MaterialColor grashalm = MaterialColor(_grashalmPrimaryValue, <int, Color>{
    500: Color(0xFFA1CA50),
    600: Color(_grashalmPrimaryValue),
    700: Color(0xFF6E971D),
  });
}
