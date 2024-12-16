import 'package:flutter/material.dart';
import 'acciones_recomendadas_screen.dart';
import 'evaluacion_adicional.dart';

class EvaluacionCompletaScreen extends StatefulWidget {
  final int evaluacionId;
  final int evaluacionEdificioId;

  const EvaluacionCompletaScreen({Key? key, required this.evaluacionEdificioId, required this.evaluacionId})
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