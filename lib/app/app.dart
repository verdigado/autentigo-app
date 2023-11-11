import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_auth_app/app/router.dart';
import 'package:gruene_auth_app/app/theme/theme.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // If the router is created outside of the `build` method, the
  // navigation will not reset after a hot reload
  final GoRouter _router = createAppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Gruene Authenticator App',
      theme: createLightTheme(),
      darkTheme: createDarkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
