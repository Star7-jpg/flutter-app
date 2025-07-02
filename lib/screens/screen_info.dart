import 'package:flutter/material.dart';

class ScreenInfo extends StatelessWidget {
  final String name;
  final String description;

  const ScreenInfo({super.key, required this.name, required this.description});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),

      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(description, style: const TextStyle(fontSize: 18.0)),
      ),
    );
  }
}
