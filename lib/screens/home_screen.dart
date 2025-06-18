import 'package:flutter/material.dart';
import 'screen_info.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

//Lista de nombres de los botones
final List<String> aulas = [
    'Aula 1',
    'Aula 2',
    'Aula 3',
    'Aula 4',
    'Aula 5',
    'Aula 6',
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight =
        MediaQuery.of(context).size.height; //Obtener el alto de la pantalla

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: screenHeight * 0.05),

          child: Center(
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,

              children: aulas.map((aula) => _buildAulaButton(aula)).toList(),
            ),
          ),
        ),
      ),
    );
  }


//Función reutilizada para crear los botones de las aulas
  Widget _buildAulaButton(String label) {
    return SizedBox(
      width: 150,
      height: 220,
      child: OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScreenInfo()),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school_outlined, size: 48),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
