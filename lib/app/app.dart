import 'package:flutter/material.dart';
import 'package:gruene_auth_app/app/router.dart';
import 'package:gruene_auth_app/app/theme/theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Gruene Authenticator App',
      theme: createLightTheme(),
      darkTheme: createDarkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: createAppRouter(),
    );
  }
}
