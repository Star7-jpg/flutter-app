import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScreenInfo extends StatefulWidget {
  final String name;
  final String description;
  final bool isAvailable;

  const ScreenInfo({
    super.key,
    required this.name,
    required this.description,
    required this.isAvailable,
  });

  @override
  State<ScreenInfo> createState() => _ScreenInfoState();
}

class _ScreenInfoState extends State<ScreenInfo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isWatch(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide < 300; // smartwatch
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView( // ✅ scrolleable para smartwatch
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    widget.isAvailable
                        ? Icons.check_circle_outline
                        : Icons.cancel_outlined,
                    color: widget.isAvailable ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Flexible( // ✅ evita overflow
                    child: Text(
                      widget.isAvailable ? 'Disponible' : 'No disponible',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: widget.isAvailable ? Colors.green : Colors.red,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 0,
                color: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    widget.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              OutlinedButton.icon(
                icon: const Icon(Icons.schedule),
                label: const Text('Marcar como no disponible'),
                onPressed: () => _selectUnavailableDateTime(context),
              ),

              const SizedBox(height: 16),
              Text("Apartados registrados:",
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),

              // ✅ Lista en vivo desde Firestore
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('aulas')
                    .doc(widget.name)
                    .collection('no_disponible')
                    .orderBy('timestamp')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Text("No hay apartados aún.");
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final fechaLegible = doc['fecha_legible'];

                      return Dismissible(
                        key: Key(doc.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) async {
                          return await _confirmDelete(context, fechaLegible);
                        },
                        onDismissed: (_) async {
                          await doc.reference.delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Apartado eliminado")),
                          );
                        },
                        child: Card(
                          child: ListTile(
                            leading: const Icon(Icons.event_busy),
                            title: Text(fechaLegible),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

Future<bool?> _confirmDelete(BuildContext context, String fechaLegible) async {
  if (_isWatch(context)) {
    // Smartwatch → bottomSheet deslizable con estilo como home_screen
    return await showModalBottomSheet<bool>(
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
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.warning, color: Colors.red),
                      title: Text(
                        '¿Eliminar apartado del $fechaLegible?',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Botón rojo eliminar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Eliminar', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Botón cancelar
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  } else {
    // Smartphone → AlertDialog clásico
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar eliminación"),
        content: Text("¿Eliminar apartado del $fechaLegible?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }
}


  void _selectUnavailableDateTime(BuildContext context) async {
    final today = DateTime.now();

    // Selecciona la fecha
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 30)),
      helpText: 'Selecciona un día hábil',
      selectableDayPredicate: (DateTime day) {
        return day.weekday >= 1 && day.weekday <= 5;
      },
    );

    if (selectedDate == null) return;

    // Selecciona la hora
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 7, minute: 0),
      helpText: 'Selecciona una hora',
    );

    if (selectedTime == null) return;

    final isValidHour = selectedTime.hour >= 7 && selectedTime.hour < 20;

    if (!isValidHour) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Hora no válida'),
          content: Text('La hora debe estar entre las 7:00 y las 20:00.'),
        ),
      );
      return;
    }

    final unavailableDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    final aulaDoc =
        FirebaseFirestore.instance.collection('aulas').doc(widget.name);

    await aulaDoc.collection('no_disponible').add({
      'timestamp': unavailableDateTime.toIso8601String(),
      'fecha_legible':
          DateFormat('dd/MM/yyyy - HH:mm').format(unavailableDateTime),
      'creado_en': FieldValue.serverTimestamp(),
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Marcado como no disponible a las: ${DateFormat('HH:mm').format(unavailableDateTime)}',
          ),
        ),
      );
    }
  }
}
