// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import '../elementos_no_estructurales/elementos_no_estructurales_screen.dart';
import '../../../utils/database_helper.dart';
import '../sistema_cubierta/sistema_cubierta_screen.dart';
import '../../../widgets/floating_navigation_menu.dart'; // Importar el menú flotante

class SistemaEntrepisoScreen extends StatefulWidget {
  final int evaluacionId;
  final int evaluacionEdificioId;
  final int userId;

  const SistemaEntrepisoScreen({
    Key? key,
    required this.evaluacionId,
    required this.evaluacionEdificioId,
    required this.userId,
  }) : super(key: key);

  @override
  State<SistemaEntrepisoScreen> createState() => _SistemaEntrepisoScreenState();
}

class _SistemaEntrepisoScreenState extends State<SistemaEntrepisoScreen> {
  final List<String> sistemasCubierta = [
    'Concreto',
    'Acero',
    'Mixtos',
    'Madera',
    'Otro',
  ];

  final Map<String, List<String>> materialesPorSistema = {
    'Concreto': [
      'Reticular celulado',
      'Losa Maciza',
      'Vigas y losa Maciza',
      'Losa armada en una dirección',
      'Losa armada en dos direcciones',
    ],
    'Acero': [
      'Vigas y rejilla de acero',
      'Cerchas y rejilla de acero',
    ],
    'Mixtos': [
      'Correas en acero y bloques de ladrillo',
      'Vigas en madera y losa de concreto',
      'Vigas metálicas y Steel deck',
      'Vigas de concreto y Steel deck',
      'Cerchas metálicas y entramado de madera',
    ],
    'Madera': [
      'Guadua',
      'Vigas y entramado de madera o guadua',
    ],
    'Otro': [],
  };

  Map<String, bool> _sistemasSeleccionados = {};
  Map<String, List<String>> _materialesSeleccionados = {};
  Map<String, TextEditingController> _otroSistemaControllers = {};

  int _currentSection = 1;

  void _onSectionSelected(int section) {
    // Navegar a la sección correspondiente
  }

  @override
  void initState() {
    super.initState();
    for (var sistema in sistemasCubierta) {
      _sistemasSeleccionados[sistema] = false;
      _materialesSeleccionados[sistema] = [];
      _otroSistemaControllers[sistema] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in _otroSistemaControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema de Entrepiso'),
        backgroundColor: const Color(0xFF002855),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sistema de Entrepiso',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...sistemasCubierta.map((sistema) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckboxListTile(
                    title: Text(sistema),
                    value: _sistemasSeleccionados[sistema],
                    onChanged: (bool? value) {
                      setState(() {
                        _sistemasSeleccionados[sistema] = value ?? false;
                        if (!(value ?? false)) {
                          _materialesSeleccionados[sistema]?.clear();
                          _otroSistemaControllers[sistema]?.clear();
                        }
                      });
                    },
                  ),
                  if (_sistemasSeleccionados[sistema] == true)
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (sistema != 'Otro') ...[
                            const Text(
                              'Materiales/Técnicas disponibles:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...materialesPorSistema[sistema]!.map((material) {
                              return CheckboxListTile(
                                title: Text(material),
                                value: _materialesSeleccionados[sistema]
                                    ?.contains(material),
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      _materialesSeleccionados[sistema]
                                          ?.add(material);
                                    } else {
                                      _materialesSeleccionados[sistema]
                                          ?.remove(material);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ] else ...[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: TextFormField(
                                controller: _otroSistemaControllers[sistema],
                                decoration: const InputDecoration(
                                  labelText: '¿Cuál?',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              );
            }).toList(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guardarYContinuar,
              child: const Text('Guardar y Continuar'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
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

  void _guardarYContinuar() async {
    // Validar selecciones
    if (!_sistemasSeleccionados.containsValue(true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione al menos un sistema de entrepiso'),
        ),
      );
      return;
    }

    // Validar materiales seleccionados
    for (var sistema in sistemasCubierta) {
      if (_sistemasSeleccionados[sistema] == true) {
        if (sistema == 'Otro' &&
            (_otroSistemaControllers[sistema]?.text.isEmpty ?? true)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Especifique el otro sistema de entrepiso'),
            ),
          );
          return;
        } else if (sistema != 'Otro' &&
            (_materialesSeleccionados[sistema]?.isEmpty ?? true)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Seleccione al menos un material para el sistema $sistema'),
            ),
          );
          return;
        }
      }
    }

    try {
      final db = DatabaseHelper();
      for (var sistema in sistemasCubierta) {
        if (_sistemasSeleccionados[sistema] == true) {
          final materiales = sistema == 'Otro'
              ? _otroSistemaControllers[sistema]?.text
              : _materialesSeleccionados[sistema]?.join(', ');

          await db.insertarSistemaCubierta({
            'evaluacion_edificio_id': widget.evaluacionEdificioId,
            'sistema': sistema,
            'materiales': materiales,
          });
        }
      }

      if (!mounted) return;

      // Navegar a la siguiente pantalla: Sistema Cubierta
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SistemasCubiertaScreen(
            evaluacionEdificioId: widget.evaluacionEdificioId,
            evaluacionId: widget.evaluacionId,
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
}