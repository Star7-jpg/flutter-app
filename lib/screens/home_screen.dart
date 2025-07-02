import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screen_info.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CollectionReference aulasCollection = FirebaseFirestore.instance
      .collection('aulas');

  @override
  Widget build(BuildContext context) {
    final screenHeight =
        MediaQuery.of(context).size.height; //Obtener el alto de la pantalla

    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),

      body: StreamBuilder<QuerySnapshot>(
        stream:
            aulasCollection
                .snapshots(), //Escucha los cambios en la colección 'aulas'
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
                  children:
                      aulas.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final name = data['name'] ?? 'Aula sin nombre';
                        final description = data['description'] ?? 'Sin descripción';
                        final isAvailable = data['is_available'] ?? true;

                        return _buildAulaButton(name, description, isAvailable);
                      }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  //Función reutilizada para crear los botones de las aulas
  Widget _buildAulaButton(String name, String description, bool isAvailable) {
    return SizedBox(
      width: 150,
      height: 220,
      child: OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ScreenInfo(
                    name: name, 
                    description: description,
                    isAvailable: isAvailable,
                  ),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isAvailable ? Icons.school_outlined : Icons.school_outlined,
              size: 48,
              color: isAvailable ? Colors.black87 : Colors.redAccent,
            ),
            const SizedBox(height: 8),
            Text(name),
          ],
        ),
      ),
    );
  }
}
