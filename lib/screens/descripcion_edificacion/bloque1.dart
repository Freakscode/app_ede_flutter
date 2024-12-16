import 'package:ede_flutter/screens/descripcion_edificacion/usos_predominantes.dart';
import 'package:flutter/material.dart';
import 'caracteristicas_generales.dart';
import '../../widgets/floating_navigation_menu.dart'; // Importar el menú flotante

class Bloque1Screen extends StatefulWidget {
  final int evaluacionId;
  final int evaluacionEdificioId;
  final int userId;

  const Bloque1Screen({
    super.key,
    required this.evaluacionId,
    required this.evaluacionEdificioId,
    required this.userId,
  });

  @override
  State<Bloque1Screen> createState() => _Bloque1ScreenState();
}

class _Bloque1ScreenState extends State<Bloque1Screen> {
  int _currentIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      CaracteristicasGeneralesScreen(
        evaluacionId: widget.evaluacionId,
        evaluacionEdificioId: widget.evaluacionEdificioId,
      ),
      UsosPredominantesScreen(
        evaluacionId: widget.evaluacionId,
        evaluacionEdificioId: widget.evaluacionEdificioId,
        userId: widget.userId,
      ),
    ];
  }

  void _onSectionSelected(int section) {
    setState(() {
      _currentIndex = section - 1;
    });
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
      floatingActionButton: FloatingSectionsMenu(
        currentSection: _currentIndex + 1,
        onSectionSelected: _onSectionSelected,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
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