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

  bool get _isWatch {
    final size = MediaQuery.of(context).size;
    return size.width < 300;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: SlideTransition(
        position: _slideAnimation,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(24.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
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
                      Text(
                        widget.isAvailable ? 'Disponible' : 'No disponible',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: widget.isAvailable ? Colors.green : Colors.red,
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
                  const SizedBox(height: 16),

                  OutlinedButton.icon(
                    icon: const Icon(Icons.schedule),
                    label: const Text('Marcar como no disponible'),
                    onPressed: () => _selectUnavailableDateTime(context),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Apartados registrados:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                ]),
              ),
            ),

            // Lista de apartados en SliverList
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('aulas')
                  .doc(widget.name)
                  .collection('no_disponible')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text('No hay apartados registrados.')),
                  );
                }

                final apartados = snapshot.data!.docs;

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final doc = apartados[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final fechaLegible =
                          data['fecha_legible'] ?? 'Sin fecha';

                      return Dismissible(
                        key: Key(doc.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          if (_isWatch) {
                            // smartwatch → bottomSheet
                            return await showModalBottomSheet<bool>(
                              context: context,
                              builder: (context) => Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.warning),
                                    title: Text(
                                        '¿Eliminar apartado del $fechaLegible?'),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text('Eliminar'),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          } else {
                            // smartphone → AlertDialog
                            return await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Eliminar apartado'),
                                content: Text(
                                    '¿Quieres eliminar el apartado del $fechaLegible?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text('Eliminar'),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        onDismissed: (direction) async {
                          await doc.reference.delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Apartado del $fechaLegible eliminado')),
                          );
                        },
                        child: ListTile(
                          leading: const Icon(Icons.event_busy),
                          title: Text(fechaLegible),
                        ),
                      );
                    },
                    childCount: apartados.length,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _selectUnavailableDateTime(BuildContext context) async {
    final today = DateTime.now();

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

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
      helpText: 'Selecciona una hora',
    );

    if (selectedTime == null) return;

    final isValidHour = selectedTime.hour >= 8 && selectedTime.hour < 20;
    if (!isValidHour) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Hora no válida'),
          content: Text('La hora debe estar entre las 8:00 y las 20:00.'),
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

    if (unavailableDateTime.isBefore(today)) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Fecha no válida'),
          content: Text('No puedes registrar horas en el pasado.'),
        ),
      );
      return;
    }

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
