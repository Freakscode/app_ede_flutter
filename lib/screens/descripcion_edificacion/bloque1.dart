import 'package:ede_flutter/screens/descripcion_edificacion/usos_predominantes.dart';
import 'package:flutter/material.dart';
import 'sistema_estructural_material/sistema_estructural_material_screen.dart';

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

  void _guardarYContinuar() async {
    // Aquí haces la lógica de guardado en la BD solo cuando el usuario haya completado ambos pasos.
    // Por ejemplo:
    // await DatabaseHelper().insertarCaracteristicasGenerales(datosRecopilados3_1);
    // await DatabaseHelper().insertarUsosPredominantes(datosRecopilados3_2);

    // Luego de guardar, ir al siguiente bloque de secciones
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SistemaEstructuralMaterialScreen(
          evaluacionId: widget.evaluacionId,
          evaluacionEdificioId: widget.evaluacionEdificioId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Descripción de la Edificación'),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      // En el bloque 1, el menú inferior es para cambiar entre 3.1 y 3.2
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
      // Aquí puedes agregar el botón "Guardar y Continuar" al final si quieres,
      // por ejemplo en un FloatingActionButton o en la misma pantalla de Usos:
      floatingActionButton: _currentIndex == 1 
        ? FloatingActionButton.extended(
            onPressed: _guardarYContinuar,
            label: Text('Guardar y continuar'),
            icon: Icon(Icons.arrow_forward),
          )
        : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
