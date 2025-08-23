import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
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
  final now = DateTime.now();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  if (_isWatch(context)) {
    // Smartwatch → BottomSheet
final result = await showModalBottomSheet<Map<String, dynamic>>(
  context: context,
  isScrollControlled: true,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  ),
  builder: (context) {
    DateTime tempDate = now;
    TimeOfDay tempTime = const TimeOfDay(hour: 8, minute: 0);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Selecciona fecha y hora',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100, // Reducido para evitar overflow
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                minimumDate: now,
                maximumDate: now.add(const Duration(days: 30)),
                onDateTimeChanged: (date) => tempDate = date,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100, // Reducido para evitar overflow
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: DateTime(now.year, now.month, now.day, 8),
                use24hFormat: true,
                onDateTimeChanged: (dateTime) => tempTime = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop({
                  'date': tempDate,
                  'time': tempTime,
                }),
                child: const Text('Guardar'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
            ),
          ],
        ),
      ),
    );
  },
);


    if (result == null) return;

    selectedDate = result['date'] as DateTime;
    selectedTime = result['time'] as TimeOfDay;
  } else {
    // Smartphone → DatePicker + TimePicker
    selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      helpText: 'Selecciona un día hábil',
      selectableDayPredicate: (d) => d.weekday >= 1 && d.weekday <= 5,
    );
    if (selectedDate == null) return;

    selectedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
      helpText: 'Selecciona una hora',
    );
    if (selectedTime == null) return;
  }

  // Validaciones comunes
  final unavailableDateTime = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    selectedTime.hour,
    selectedTime.minute,
  );

  if (unavailableDateTime.isBefore(now)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No puedes registrar horas en el pasado')),
    );
    return;
  }

  if (unavailableDateTime.hour < 8 || unavailableDateTime.hour >= 20) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('La hora debe estar entre las 8:00 y las 20:00')),
    );
    return;
  }

  // Guardar en Firestore
  final aulaDoc = FirebaseFirestore.instance.collection('aulas').doc(widget.name);
  await aulaDoc.collection('no_disponible').add({
    'timestamp': unavailableDateTime.toIso8601String(),
    'fecha_legible': DateFormat('dd/MM/yyyy - HH:mm').format(unavailableDateTime),
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
