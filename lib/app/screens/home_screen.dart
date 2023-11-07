import 'package:flutter/material.dart';
import 'package:gruene_auth_app/app/widgets/nav_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavDrawer(),
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 42),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Home Screen'),
            ],
          ),
        ),
      ),
    );
  }
}
