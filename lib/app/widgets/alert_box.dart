import 'package:flutter/material.dart';

class AlertBox extends StatelessWidget {
  final String text;
  const AlertBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.deepOrange.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(text),
      ),
    );
  }
}
