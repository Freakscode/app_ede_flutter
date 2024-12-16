import 'package:flutter/material.dart';
import '../../utils/database_helper.dart';

class EvaluacionAdicionalScreen extends StatefulWidget {
  final int evaluacionEdificioId;

  const EvaluacionAdicionalScreen({Key? key, required this.evaluacionEdificioId}) : super(key: key);

  @override
  _EvaluacionAdicionalScreenState createState() => _EvaluacionAdicionalScreenState();
}

class _EvaluacionAdicionalScreenState extends State<EvaluacionAdicionalScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  TextEditingController estructuralController = TextEditingController();
  TextEditingController geotecnicaController = TextEditingController();
  bool otraSeleccionada = false;
  TextEditingController detalleOtraController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    Map<String, dynamic>? datos = await _dbHelper.obtenerEvaluacionAdicional(widget.evaluacionEdificioId);
    if (datos != null) {
      setState(() {
        estructuralController.text = datos['estructural'] ?? '';
        geotecnicaController.text = datos['geotecnica'] ?? '';
        otraSeleccionada = datos['otra'] == 1;
        detalleOtraController.text = datos['detalle_otra'] ?? '';
      });
    }
  }

  Future<void> _guardarDatos() async {
    Map<String, dynamic> datos = {
      'evaluacion_edificio_id': widget.evaluacionEdificioId,
      'estructural': estructuralController.text,
      'geotecnica': geotecnicaController.text,
      'otra': otraSeleccionada ? 1 : 0,
      'detalle_otra': otraSeleccionada ? detalleOtraController.text : '',
    };

    if (await _dbHelper.obtenerEvaluacionAdicional(widget.evaluacionEdificioId) != null) {
      await _dbHelper.actualizarEvaluacionAdicional(widget.evaluacionEdificioId, datos);
    } else {
      await _dbHelper.insertarEvaluacionAdicional(datos);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Evaluación Adicional guardada exitosamente')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('8.1 Evaluación Adicional'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: estructuralController,
              decoration: const InputDecoration(
                labelText: 'Estructural',
                hintText: 'Revisión de muros de carga y sistema de entrepisos.',
              ),
            ),
            TextField(
              controller: geotecnicaController,
              decoration: const InputDecoration(
                labelText: 'Geotécnica',
                hintText: 'Estudio de estabilidad del suelo.',
              ),
            ),
            CheckboxListTile(
              title: const Text('Otra'),
              value: otraSeleccionada,
              onChanged: (bool? value) {
                setState(() {
                  otraSeleccionada = value ?? false;
                });
              },
            ),
            if (otraSeleccionada)
              TextField(
                controller: detalleOtraController,
                decoration: const InputDecoration(
                  labelText: '¿Cuál?',
                  hintText: 'Evaluación eléctrica o de instalaciones hidráulicas.',
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guardarDatos,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}