import 'package:autentigo_app/app/constants/app.dart';
import 'package:autentigo_app/app/router.dart';
import 'package:autentigo_app/app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class App extends StatelessWidget {
  App({super.key});

  // If the router is created outside of the `build` method, the
  // navigation will not reset after a hot reload
  final GoRouter _router = createAppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: CustomTheme.lightTheme,
      darkTheme: CustomTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
