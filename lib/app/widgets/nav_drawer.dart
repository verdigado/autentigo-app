import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_auth_app/app/app.dart';

class NavDrawer extends StatefulWidget {
  const NavDrawer({super.key});

  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.only(top: 42, right: 24, left: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Grüne Authenticator App',
              style: TextStyle(fontSize: 18),
            ),
            OutlinedButton(
              onPressed: () => context.goNamed('home'),
              child: const Text('Home'),
            ),
            OutlinedButton(
              onPressed: () => context.go('/authenticator'),
              child: const Text('Authenticator'),
            ),
            Text(
                'Theme: ${MyApp.of(context).themeMode == ThemeMode.dark ? 'Dunkel' : 'Hell'}'),
            Switch(
              value: MyApp.of(context).themeMode == ThemeMode.dark,
              onChanged: (bool value) {
                MyApp.of(context).toggleThemeMode();
              },
            ),
          ],
        ),
      ),
    );
  }
}
