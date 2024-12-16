import 'package:flutter/material.dart';
import 'acciones_recomendadas_screen.dart';
import 'evaluacion_adicional.dart';
import '../../widgets/floating_navigation_menu.dart'; // Importar el menú flotante

class EvaluacionCompletaScreen extends StatefulWidget {
  final int evaluacionId;
  final int evaluacionEdificioId;
  final int userId;

  const EvaluacionCompletaScreen({Key? key, required this.evaluacionEdificioId, required this.evaluacionId,
    required this.userId})
      : super(key: key);

  @override
  _EvaluacionCompletaScreenState createState() =>
      _EvaluacionCompletaScreenState();
}

class _EvaluacionCompletaScreenState extends State<EvaluacionCompletaScreen> {
  int _currentIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      RecomendacionesMedidasScreen(
        evaluacionEdificioId: widget.evaluacionEdificioId,
        evaluacionId: widget.evaluacionId,
        userId: widget.userId,
      ),
      EvaluacionAdicionalScreen(
        evaluacionEdificioId: widget.evaluacionEdificioId,
      ),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onSectionSelected(int section) {
    setState(() {
      _currentIndex = section - 1; // Asumiendo que las secciones empiezan en 1
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('8. Evaluación Completa'),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingSectionsMenu(
        currentSection: _currentIndex + 1, // Convertir a 1-indexado
        onSectionSelected: _onSectionSelected,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check),
            label: 'Acciones Recomendadas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Evaluación Adicional',
          ),
        ],
      ),
    );
  }
}