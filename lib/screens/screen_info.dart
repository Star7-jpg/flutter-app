import 'package:flutter/material.dart';

class ScreenInfo extends StatelessWidget {
  final String name;
  final String description;
  final bool isAvailable;

  const ScreenInfo({
    super.key, 
    required this.name, 
    required this.description,
    required this.isAvailable
    });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name)),
 
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column( 
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Icon(
                isAvailable ? Icons.check_circle : Icons.cancel,
                color: isAvailable ? Colors.green : Colors.redAccent,
              ),
              const SizedBox(width: 8),
              Text(
                isAvailable ? 'Aula disponible' : 'Aula no disponible',
                style: TextStyle(
                  fontSize: 16.0,
                  color: isAvailable ? Colors.green : Colors.redAccent,
                  fontWeight: FontWeight.w500
                ),
              )
            ],)
          ],)
      ),
    );
  }
}
