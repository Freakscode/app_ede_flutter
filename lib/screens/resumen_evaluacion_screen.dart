// ignore_for_file: unused_element

import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../utils/database_helper.dart';

class ResumenEvaluacionScreen extends StatefulWidget {
  final int evaluacionId;

  const ResumenEvaluacionScreen({Key? key, required this.evaluacionId}) : super(key: key);

  @override
  _ResumenEvaluacionScreenState createState() => _ResumenEvaluacionScreenState();
}

class _ResumenEvaluacionScreenState extends State<ResumenEvaluacionScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Widget _buildSectionTitle(String titulo) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        titulo,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF002855),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, Map<String, dynamic>? data) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF002855),
              ),
            ),
            const Divider(),
            if (data != null) ..._buildDataWidgets(data),
          ],
        ),
      ),
    );
  }

  Widget _buildDataWidget(String key, dynamic value) {
    if (key.toLowerCase() == 'firma' && value is List<int>) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Firma del Evaluador:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: value.isNotEmpty
                ? Image.memory(
                    Uint8List.fromList(value),
                    fit: BoxFit.contain,
                  )
                : const Center(
                    child: Text('No hay firma disponible'),
                  ),
          ),
        ],
      );
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        '$key: ${value ?? "No especificado"}',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  List<Widget> _buildDataWidgets(Map<String, dynamic> data) {
    return data.entries.map((entry) {
      if (entry.value is List && entry.key.toLowerCase() != 'firma') {
        return _buildListSection(entry.key, entry.value as List);
      } else if (entry.value is Map) {
        return _buildMapSection(entry.key, entry.value as Map);
      } else {
        return _buildDataWidget(entry.key, entry.value);
      }
    }).toList();
  }

  Widget _buildListSection(String title, List items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 4.0),
              child: Text('• ${item.toString()}'),
            )),
      ],
    );
  }

  Widget _buildMapSection(String title, Map data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        ...data.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 4.0),
              child: Text('${entry.key}: ${entry.value}'),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen de la Evaluación'),
        backgroundColor: const Color(0xFF002855),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dbHelper.obtenerDatosEvaluacion(widget.evaluacionId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No se encontraron datos.'));
          }

          final datos = snapshot.data!;

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.only(bottom: 80.0),
                children: [
                  _buildSectionCard('1. Identificación de la Evaluación', datos['evaluacion']),
                  _buildSectionCard('2. Identificación de la Edificación', {
                    ...?datos['edificio'] as Map<String, dynamic>?,
                    'Contacto': datos['contacto'],
                  }),
                  _buildSectionCard('3. Descripción de la Edificación', {
                    'Características': datos['caracteristicas_generales'],
                    'Usos': datos['usos_predominantes'],
                    'Estructura': datos['detalle_estructura'],
                  }),
                  _buildSectionCard('4. Riesgos Externos', {
                    'Riesgos': datos['riesgos_externos'],
                  }),
                  _buildSectionCard('5. Daños en la Edificación', {
                    'Evaluación': datos['danos_evaluacion'],
                    'Elementos': datos['elementos_no_estructurales'],
                  }),
                  _buildSectionCard('6. Habitabilidad', datos['habitabilidad']),
                  _buildSectionCard('7. Acciones Recomendadas', {
                    'Acciones': datos['acciones_recomendadas'],
                    'Evaluación Adicional': datos['evaluacion_adicional'],
                  }),
                  const SizedBox(height: 80),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implementar guardado PDF
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('PDF'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implementar envío PDF
                        },
                        icon: const Icon(Icons.send),
                        label: const Text('PDF'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implementar guardado CSV
                        },
                        icon: const Icon(Icons.save_alt),
                        label: const Text('CSV'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implementar envío CSV
                        },
                        icon: const Icon(Icons.upload_file),
                        label: const Text('CSV'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}