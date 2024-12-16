import 'package:ede_flutter/screens/descripcion_edificacion/usos_predominantes.dart';
import 'package:flutter/material.dart';
import 'caracteristicas_generales.dart';

class Bloque1Screen extends StatefulWidget {
  final int evaluacionId;
  final int evaluacionEdificioId;

  const Bloque1Screen({
    super.key,
    required this.evaluacionId,
    required this.evaluacionEdificioId,
  });

  @override
  State<Bloque1Screen> createState() => _Bloque1ScreenState();
}

class _Bloque1ScreenState extends State<Bloque1Screen> {
  int _currentIndex = 0;
  late List<Widget> _screens;

  // Aquí podrías tener variables para almacenar temporalmente los datos ingresados
  // en las secciones 3.1 y 3.2 antes de guardarlos en la BD, si es necesario.

  @override
  void initState() {
    super.initState();
    _screens = [
      CaracteristicasGeneralesScreen(
        evaluacionId: widget.evaluacionId,
        evaluacionEdificioId: widget.evaluacionEdificioId,
        // Opcional: puedes pasar callbacks para actualizar el estado local
      ),
      UsosPredominantesScreen(
        evaluacionId: widget.evaluacionId,
        evaluacionEdificioId: widget.evaluacionEdificioId,
        // Igual que arriba, pasar callbacks si quieres recolectar datos
      ),
    ];
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Descripción de la Edificación'),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Características Generales',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Usos Predominantes',
          ),
        ],
      ),
    );
  }
}