import 'package:flutter/material.dart';

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

class _ScreenInfoState extends State<ScreenInfo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Configura el controlador de animación
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // 2. Define desde dónde se desliza (abajo en este caso)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0), // desde abajo
      end: Offset.zero,          // hasta su posición final
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // 3. Inicia la animación
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose(); // Libera el controlador
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: Padding(
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
            ],
          ),
        ),
      ),
    );
  }
}
