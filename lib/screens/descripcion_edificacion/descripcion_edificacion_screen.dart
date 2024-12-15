import 'package:flutter/material.dart';
import 'sistema_estructural_material/sistema_estructural_material_screen.dart';
import 'sistemas_entrepiso_cubierta/sistemas_entrepiso_cubierta_screen.dart';
import 'sistema_soporte_revestimiento/sistema_soporte_revestimiento_screen.dart';
import 'elementos_no_estructurales/elementos_no_estructurales_screen.dart';
import 'caracteristicas_generales.dart';
import 'usos_predominantes.dart';


class DescripcionEdificacionScreen extends StatefulWidget {
  final int evaluacionId;
  final int evaluacionEdificioId;

  const DescripcionEdificacionScreen({
    Key? key,
    required this.evaluacionId,
    required this.evaluacionEdificioId,
  }) : super(key: key);

  @override
  State<DescripcionEdificacionScreen> createState() => _DescripcionEdificacionScreenState();
}

class _DescripcionEdificacionScreenState extends State<DescripcionEdificacionScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _initializeScreens();
  }

  void _initializeScreens() {
  _screens = [
    CaracteristicasGeneralesScreen(
      evaluacionId: widget.evaluacionId,
      evaluacionEdificioId: widget.evaluacionEdificioId,
    ),
    UsosPredominantesScreen(
      evaluacionId: widget.evaluacionId,
      evaluacionEdificioId: widget.evaluacionEdificioId,
    ),
    SistemaEstructuralMaterialScreen(
      evaluacionId: widget.evaluacionId,
      evaluacionEdificioId: widget.evaluacionEdificioId,
    ),
    SistemasEntrepisoCubiertaScreen(
      evaluacionId: widget.evaluacionId,
      evaluacionEdificioId: widget.evaluacionEdificioId,
    ),
    SistemaSoporteRevestimientoScreen(
      evaluacionId: widget.evaluacionId,
      evaluacionEdificioId: widget.evaluacionEdificioId,
    ),
    ElementosNoEstructuralesScreen(
      evaluacionId: widget.evaluacionId,
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
            icon: Icon(Icons.domain),
            label: 'Estructural',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.layers),
            label: 'Entrepiso',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.roofing),
            label: 'Cubierta',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Elementos',
          ),
        ],
      ),
    );
  }
}