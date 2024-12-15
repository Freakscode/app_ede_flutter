// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import '../utils/database_helper.dart';

class ResumeScreen extends StatelessWidget {
  final int evaluacionId;

  const ResumeScreen({Key? key, required this.evaluacionId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dbHelper = DatabaseHelper();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen de la Evaluación'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: dbHelper.obtenerDatosEvaluacion(evaluacionId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No se encontraron datos.'));
          }

          final datos = snapshot.data!;
          final evaluacion = datos['evaluacion'];
          final edificio = datos['edificio'];
          final contacto = datos['contacto'] as List<dynamic>;
          final caracteristicas = datos['caracteristicas_generales'];
          final usos = datos['usos_predominantes'] as List<dynamic>;
          final detalleEstructura = datos['detalle_estructura'];
          final danos = datos['danos_evaluacion'];
          final habitabilidad = datos['habitabilidad'];
          final acciones = datos['acciones_recomendadas'] as List<dynamic>;
          final riesgos = datos['riesgos_externos'] as List<dynamic>;
          final adicional = datos['evaluacion_adicional'] as List<dynamic>;
          final elementosNoEstructurales = datos['elementos_no_estructurales'] as List<dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (evaluacion != null) ...[
                  const Text('Evaluación', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Evento ID: ${evaluacion['eventoId']}'),
                  const SizedBox(height: 16),
                ],
                if (edificio != null) ...[
                  const Text('Edificio', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Nombre: ${edificio['nombre']}'),
                  const SizedBox(height: 16),
                ],
                if (contacto.isNotEmpty) ...[
                  const Text('Contacto(s)', style: TextStyle(fontWeight: FontWeight.bold)),
                  for (var c in contacto) Text('${c['nombre']} - ${c['telefono'] ?? ''}'),
                  const SizedBox(height: 16),
                ],
                if (caracteristicas != null) ...[
                  const Text('Características Generales', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Número de pisos: ${caracteristicas['numero_pisos']}'),
                  const SizedBox(height: 16),
                ],
                if (usos.isNotEmpty) ...[
                  const Text('Usos Predominantes', style: TextStyle(fontWeight: FontWeight.bold)),
                  for (var u in usos) Text('- ${u['descripcion']}'),
                  const SizedBox(height: 16),
                ],
                // Y así sucesivamente con el resto de datos...
              ],
            ),
          );
        },
      ),
    );
  }
}
