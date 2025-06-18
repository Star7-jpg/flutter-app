import 'package:flutter/material.dart';
import 'screen_info.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
          padding: EdgeInsets.only(top: screenHeight * 0.10),

          child: Center(
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,

              children: [
                SizedBox(
                  width: 150,
                  height: 220,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScreenInfo(),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school_outlined, size: 48), // Icono de inicio
                        SizedBox(height: 8),
                        Text('Aula 1'),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  width: 150,
                  height: 220,
                  child: OutlinedButton(
                    onPressed: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScreenInfo(),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school_outlined, size: 48), // Icono de inicio
                        SizedBox(height: 8),
                        Text('Aula 2'),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  width: 150,
                  height: 220,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScreenInfo(),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school_outlined, size: 48), // Icono de inicio
                        SizedBox(height: 8),
                        Text('Aula 3'),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  width: 150,
                  height: 220,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScreenInfo(),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school_outlined, size: 48), // Icono de inicio
                        SizedBox(height: 8),
                        Text('Aula 4'),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  width: 150,
                  height: 220,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScreenInfo(),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school_outlined, size: 48), // Icono de inicio
                        SizedBox(height: 8),
                        Text('Aula 5'),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  width: 150,
                  height: 220,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScreenInfo(),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school_outlined, size: 48), // Icono de inicio
                        SizedBox(height: 8),
                        Text('Aula 6'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
