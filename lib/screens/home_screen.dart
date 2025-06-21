import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screen_info.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

final CollectionReference aulasCollection = FirebaseFirestore.instance.collection('aulas');

  @override
  Widget build(BuildContext context) {
    final screenHeight =
        MediaQuery.of(context).size.height; //Obtener el alto de la pantalla

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),

      body: FutureBuilder<QuerySnapshot>(
        future: aulasCollection.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay aulas disponibles.'));
          }

          final aulas = snapshot.data!.docs;

      
      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: screenHeight * 0.05),

          child: Center(
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,

              children: aulas
                .map((doc) => _buildAulaButton(doc['nombre']))
                .toList(),
                ),
              ),
            ),
          );
        },
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
