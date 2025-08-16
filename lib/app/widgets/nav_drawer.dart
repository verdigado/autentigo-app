import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
            const SizedBox(height: 24),
            const Text('Menü', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
            const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider()),
            OutlinedButton(onPressed: () => context.goNamed('home'), child: const Text('Home')),
            OutlinedButton(onPressed: () => context.go('/authenticator'), child: const Text('Authenticator')),
          ],
        ),
      ),
    );
  }
}
