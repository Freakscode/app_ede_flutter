import 'package:flutter/material.dart';
import '../../utils/database_helper.dart'; // Asegúrate de que la ruta sea correcta
import '../evaluacion_daños_edificacion/evaluacion_damage_edificacion.dart';

class AlcanceEvaluacionScreen extends StatefulWidget {
  final int evaluacionId;
  final int evaluacionEdificioId;
  final int userId;

  const AlcanceEvaluacionScreen({
    Key? key,
    required this.evaluacionId,
    required this.evaluacionEdificioId,
    required this.userId,
  }) : super(key: key);

  @override
  _AlcanceEvaluacionScreenState createState() => _AlcanceEvaluacionScreenState();
}

class _AlcanceEvaluacionScreenState extends State<AlcanceEvaluacionScreen> {
  // Opciones para Exterior
  String? _seleccionExterior;

  // Opciones para Interior
  String? _seleccionInterior;

  /// Guardar los datos en la base de datos
  Future<void> _guardarDatosEnBaseDeDatos() async {
    if (_seleccionExterior == null || _seleccionInterior == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona todas las opciones.')),
      );
      return;
    }

    try {
      final dbHelper = DatabaseHelper();

      // Crear un mapa para los datos de Alcance de Evaluación
      Map<String, dynamic> datosAlcance = {
        'evaluacion_edificio_id': widget.evaluacionEdificioId,
        'exterior': _seleccionExterior,
        'interior': _seleccionInterior,
      };

      // Insertar o actualizar los datos en la base de datos
      await dbHelper.insertarAlcanceEvaluacion(datosAlcance);

      // Imprimir en consola los valores guardados
      print('Datos de Alcance de Evaluación guardados:');
      print(datosAlcance);

      // Navegar a la siguiente pantalla
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EvaluacionDamagesEdificacionScreen(
            evaluacionId: widget.evaluacionId,
            evaluacionEdificioId: widget.evaluacionEdificioId,
            userId: widget.userId,
          ),
        ),
      );
    } catch (e) {
      print('Error al guardar Alcance de Evaluación: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alcance de la evaluación realizada'),
        backgroundColor: const Color(0xFF002855),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección: Exterior
            const Text(
              'Exterior',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            RadioListTile<String>(
              title: const Text('Parcial'),
              value: 'Parcial',
              groupValue: _seleccionExterior,
              onChanged: (String? value) {
                setState(() {
                  _seleccionExterior = value;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Completa'),
              value: 'Completa',
              groupValue: _seleccionExterior,
              onChanged: (String? value) {
                setState(() {
                  _seleccionExterior = value;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Ninguno'),
              value: 'Ninguno',
              groupValue: _seleccionExterior,
              onChanged: (String? value) {
                setState(() {
                  _seleccionExterior = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // Sección: Interior
            const Text(
              'Interior',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            RadioListTile<String>(
              title: const Text('No Ingreso'),
              value: 'No Ingreso',
              groupValue: _seleccionInterior,
              onChanged: (String? value) {
                setState(() {
                  _seleccionInterior = value;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Parcial'),
              value: 'Parcial',
              groupValue: _seleccionInterior,
              onChanged: (String? value) {
                setState(() {
                  _seleccionInterior = value;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Completa'),
              value: 'Completa',
              groupValue: _seleccionInterior,
              onChanged: (String? value) {
                setState(() {
                  _seleccionInterior = value;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Ninguno'),
              value: 'Ninguno',
              groupValue: _seleccionInterior,
              onChanged: (String? value) {
                setState(() {
                  _seleccionInterior = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // Botón Guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _guardarDatosEnBaseDeDatos,
                icon: const Icon(Icons.save),
                label: const Text('Guardar Alcance'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002855),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}