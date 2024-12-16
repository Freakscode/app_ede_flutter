import 'package:flutter/material.dart';
import '../../../utils/database_helper.dart';
import '../elementos_no_estructurales/elementos_no_estructurales_screen.dart';
import '../../../widgets/floating_navigation_menu.dart'; // Importar el menú flotante

class SistemasCubiertaScreen extends StatefulWidget {
  final int evaluacionEdificioId;
  final int evaluacionId;
  final int userId;

  const SistemasCubiertaScreen({
    Key? key,
    required this.evaluacionEdificioId,
    required this.evaluacionId,
    required this.userId,
  }) : super(key: key);

  @override
  _SistemasCubiertaScreenState createState() => _SistemasCubiertaScreenState();
}

class _SistemasCubiertaScreenState extends State<SistemasCubiertaScreen> {
  // Checkboxes para sistemas de soporte y revestimiento
  final Map<String, bool> _sistemaSoporte = {
    'Vigas de madera': false,
    'Vigas de acero': false,
    'Vigas de concreto': false,
    'Cerchas de madera': false,
    'Cerchas metálicas': false,
  };

  final Map<String, bool> _revestimiento = {
    'Precario (plástico, paja)': false,
    'Teja de barro': false,
    'Teja de asbesto cemento': false,
    'Teja plástica': false,
    'Teja de zinc': false,
    'Teja termo acústica': false,
    'Losa maciza de concreto': false,
    'Losa aligerada de concreto': false,
    'Cúpula, bóveda, arco en mampostería, tierra o madera': false,
  };

  // Controladores para "Otro" campo de texto
  final TextEditingController _otroSoporteController = TextEditingController();
  final TextEditingController _otroRevestimientoController = TextEditingController();

  int _currentSection = 1;

  void _onSectionSelected(int section) {
    // Navegar a la sección correspondiente
  }

  @override
  void dispose() {
    _otroSoporteController.dispose();
    _otroRevestimientoController.dispose();
    super.dispose();
  }

  /// Guardar los datos en la base de datos
  Future<void> _guardarDatosEnBaseDeDatos() async {
    try {
      final dbHelper = DatabaseHelper();

      // Obtener sistemas de soporte seleccionados
      final sistemaSoporteSeleccionados = _sistemaSoporte.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      // Obtener revestimientos seleccionados
      final revestimientoSeleccionados = _revestimiento.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      // Agregar valores "Otro" si existen
      if (_otroSoporteController.text.isNotEmpty) {
        sistemaSoporteSeleccionados.add(_otroSoporteController.text);
      }
      if (_otroRevestimientoController.text.isNotEmpty) {
        revestimientoSeleccionados.add(_otroRevestimientoController.text);
      }

      // Guardar en la base de datos
      for (String soporte in sistemaSoporteSeleccionados) {
        await dbHelper.insertarSistemaCubierta({
          'evaluacion_edificio_id': widget.evaluacionEdificioId,
          'sistema': 'Sistema de Soporte',
          'materiales': soporte,
        });
      }

      for (String revestimiento in revestimientoSeleccionados) {
        await dbHelper.insertarSistemaCubierta({
          'evaluacion_edificio_id': widget.evaluacionEdificioId,
          'sistema': 'Revestimiento',
          'materiales': revestimiento,
        });
      }

      // Navegar a la siguiente pantalla
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ElementosNoEstructuralesScreen(
            evaluacionId: widget.evaluacionId,
            evaluacionEdificioId: widget.evaluacionEdificioId,
            userId: widget.userId,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistemas de Cubierta'),
        backgroundColor: const Color(0xFF002855),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección: Sistema de soporte
            const Text(
              '3.5.1 Sistema de soporte',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._sistemaSoporte.keys.map((key) {
              return CheckboxListTile(
                title: Text(key),
                value: _sistemaSoporte[key],
                onChanged: (bool? value) {
                  setState(() {
                    _sistemaSoporte[key] = value ?? false;
                  });
                },
              );
            }).toList(),
            TextField(
              controller: _otroSoporteController,
              decoration: const InputDecoration(
                labelText: 'Otro (especifique)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Sección: Revestimiento
            const Text(
              '3.5.2 Revestimiento',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._revestimiento.keys.map((key) {
              return CheckboxListTile(
                title: Text(key),
                value: _revestimiento[key],
                onChanged: (bool? value) {
                  setState(() {
                    _revestimiento[key] = value ?? false;
                  });
                },
              );
            }).toList(),
            TextField(
              controller: _otroRevestimientoController,
              decoration: const InputDecoration(
                labelText: 'Otro (especifique)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Botón Guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _guardarDatosEnBaseDeDatos,
                icon: const Icon(Icons.save),
                label: const Text('Guardar Datos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002855),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingSectionsMenu(
        currentSection: _currentSection,
        onSectionSelected: _onSectionSelected,
      ),
    );
  }
}
