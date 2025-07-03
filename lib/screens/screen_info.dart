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
              //Título grande
              name,
              style: Theme.of(context).textTheme.headlineSmall,
              ),

            const SizedBox(height: 16),

            //Estado de disponibilidad
            Row(children: [
              Icon(
                isAvailable ? Icons.check_circle : Icons.cancel_outlined,
                color: isAvailable ? Colors.green : Colors.redAccent,
                size: 24,
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
            ],
            ),
            const SizedBox(height: 24),

            //Descripción del aula
            Card(
              elevation: 0,
              color: Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16.0),
                ),
              ),
            )

          ],)
      ),
    );
  }
}
