import 'package:flutter/material.dart';
import 'package:gruene_auth_app/app/router.dart';
import 'package:gruene_auth_app/app/theme/theme.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // ignore: library_private_types_in_public_api
  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // ThemeMode _themeMode = ThemeMode.system;
  ThemeMode _themeMode = ThemeMode.light;

  void setTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  void toggleThemeMode() {
    setState(() {
      _themeMode =
          themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  ThemeMode get themeMode {
    return _themeMode;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Gruene Authenticator App',
      theme: createLightTheme(),
      darkTheme: createDarkTheme(),
      themeMode: _themeMode,
      routerConfig: createAppRouter(),
    );
  }
}
