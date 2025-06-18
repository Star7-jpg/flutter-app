import 'package:flutter/material.dart';

class ScreenInfo extends StatefulWidget {
  const ScreenInfo({super.key});

  @override
  State<ScreenInfo> createState() => _ScreenInfoState();
}

class _ScreenInfoState extends State<ScreenInfo> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen Info'),

      ),

      body: const Center(
        child: Text('Pantalla de Información',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}