import 'package:flutter/material.dart';
import '../../../utils/database_helper.dart';
import '../../identificacion_riesgos_externos/identificacion_riesgos_screen.dart';

class EvaluacionSeccion3 extends StatefulWidget {
  final int evaluacionId;
  final int evaluacionEdificioId;

  const EvaluacionSeccion3({
    Key? key,
    required this.evaluacionId,
    required this.evaluacionEdificioId,
  }) : super(key: key);

  @override
  _EvaluacionSeccion3State createState() => _EvaluacionSeccion3State();
}

class _EvaluacionSeccion3State extends State<EvaluacionSeccion3> {
  // Instancia de la base de datos
  final DatabaseHelper dbHelper = DatabaseHelper();

  // Variables de estado para los inputs
  String? nivelDiseno;
  String? calidadDiseno;
  String? estadoEdificacion;

  @override
  void initState() {
    super.initState();
    _cargarDatos(); // Cargar datos existentes al iniciar
  }

  Future<void> _cargarDatos() async {
    final datos = await dbHelper.obtenerEvaluacionSeccion3(widget.evaluacionEdificioId);
    if (datos != null) {
      setState(() {
        nivelDiseno = datos['nivel_disenio'];
        calidadDiseno = datos['calidad_disenio'];
        estadoEdificacion = datos['estado_edificacion'];
      });
    }
  }

  Future<void> _guardarDatos() async {
    await dbHelper.insertarActualizarEvaluacionSeccion3({
      'evaluacion_edificio_id': widget.evaluacionEdificioId,
      'nivel_disenio': nivelDiseno,
      'calidad_disenio': calidadDiseno,
      'estado_edificacion': estadoEdificacion,
    });

    // Mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Datos guardados correctamente')),
    );

    // Navegar a la siguiente pantalla
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IdentificacionRiesgosExternosScreen(
          evaluacionId: widget.evaluacionId,
          evaluacionEdificioId: widget.evaluacionEdificioId,
        ),
      ),
    );
  }

  Widget buildRadioGroup({
    required String title,
    required List<String> opciones,
    required String? currentValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ...opciones.map((opcion) {
          return RadioListTile<String>(
            title: Text(opcion),
            value: opcion,
            groupValue: currentValue,
            onChanged: onChanged,
          );
        }).toList(),
        Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Evaluación - Sección 3"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nivel de diseño
            buildRadioGroup(
              title: "3.7 Nivel de diseño",
              opciones: ["Ingenieril", "No ingenieril", "Precario"],
              currentValue: nivelDiseno,
              onChanged: (value) => setState(() => nivelDiseno = value),
            ),
            // Calidad del diseño
            buildRadioGroup(
              title: "3.8 Calidad del diseño y la construcción de la estructura original",
              opciones: ["Bueno", "Regular", "Malo"],
              currentValue: calidadDiseno,
              onChanged: (value) => setState(() => calidadDiseno = value),
            ),
            // Estado de la edificación
            buildRadioGroup(
              title: "3.9 Estado de la edificación (Conservación)",
              opciones: ["Bueno", "Regular", "Malo"],
              currentValue: estadoEdificacion,
              onChanged: (value) => setState(() => estadoEdificacion = value),
            ),
            SizedBox(height: 20),
            // Botón para guardar
            Center(
              child: ElevatedButton(
                onPressed: _guardarDatos,
                child: Text("Guardar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
