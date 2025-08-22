import 'package:firebase_auth/firebase_auth.dart';
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
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
IconButton(
  icon: const Icon(Icons.logout),
  tooltip: 'Cerrar sesión',
  onPressed: () async {
    final screenWidth = MediaQuery.of(context).size.width;

    final shouldLogout = screenWidth <= 400
        ? await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (context) {
              return DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.4,
                minChildSize: 0.2,
                maxChildSize: 0.8,
                builder: (context, scrollController) {
                  return SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Cerrar sesión',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '¿Estás seguro de que quieres cerrar sesión?',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                            ),
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Cerrar sesión'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          )
        : await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Cerrar sesión'),
              content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Cerrar sesión'),
                ),
              ],
            ),
          );

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
    }
  },
)

        ],
      ),

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
                        final description =
                            data['description'] ?? 'Sin descripción';
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
