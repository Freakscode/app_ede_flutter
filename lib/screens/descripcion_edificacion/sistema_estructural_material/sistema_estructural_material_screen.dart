// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import '../../../utils/database_helper.dart';
import '../sistemas_entrepiso/sistema_entrepiso_screen.dart';

class SistemaEstructuralMaterialScreen extends StatefulWidget {
  final int evaluacionId;
  final int evaluacionEdificioId;

  const SistemaEstructuralMaterialScreen({
    super.key,
    required this.evaluacionId,
    required this.evaluacionEdificioId,
  });

  @override
  _SistemaEstructuralMaterialScreenState createState() => _SistemaEstructuralMaterialScreenState();
}

class _SistemaEstructuralMaterialScreenState
    extends State<SistemaEstructuralMaterialScreen> {
  // Definir los sistemas estructurales
  final List<String> sistemasEstructurales = [
    'Muros de carga',
    'Pórticos',
    'Combinado',
    'Dual',
    'Otro',
    'No es claro',
  ];

  // Mapa de materiales por sistema estructural
  final Map<String, List<String>> materialesPorSistema = {
    'Muros de carga': [
      'Mampostería Simple',
      'Mampostería Confinada',
      'Mampostería Reforzada',
      'Mampostería Semi-confinada',
      'Mampostería en adobe',
      'Madera o guadua',
      'Bahareque',
      'Tierra o tapia pisada',
      'Concreto',
      'Concreto prefabricado',
    ],
    'Pórticos': [
      'Concreto no arriostrados',
      'Concreto arriostrados',
      'Acero no arriostrados',
      'Acero arriostrados',
      'Madera o guadua',
      'Concreto prefabricado',
      'Cerchas en acero',
      'Cerchas en madera o guadua',
    ],
    'Combinado': [
      'Concreto',
      'Concreto y acero',
      'Madera o guadua',
    ],
    'Dual': [
      'Concreto',
      'Muros con placa de acero',
      'Mampostería Reforzada',
    ],
    'Otro': [
      'Losa - columna en concreto',
    ],
    'No es claro': [],
  };

  // Estado de los sistemas estructurales seleccionados
  Map<String, bool> _sistemasSeleccionados = {};

  // Estado de los materiales seleccionados por sistema
  Map<String, List<String>> _materialesSeleccionados = {};

  // Controlador para el campo "¿Cuál?" en "Otro"
  Map<String, TextEditingController> _otroMaterialControllers = {};

  @override
  void initState() {
    super.initState();
    // Inicializar el estado de los sistemas estructurales
    for (var sistema in sistemasEstructurales) {
      _sistemasSeleccionados[sistema] = false;
      _materialesSeleccionados[sistema] = [];
      _otroMaterialControllers[sistema] = TextEditingController();
    }
  }

  @override
  void dispose() {
    // Dispose de todos los controladores de texto
    for (var controller in _otroMaterialControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Función para manejar la selección de un sistema estructural
  void _onSistemaSeleccionado(String sistema, bool? isSelected) {
    setState(() {
      _sistemasSeleccionados[sistema] = isSelected ?? false;
      if (!(isSelected ?? false)) {
        // Si se deselecciona, limpiar materiales seleccionados
        _materialesSeleccionados[sistema]?.clear();
        _otroMaterialControllers[sistema]?.clear();
      }
    });
  }

  // Función para manejar la selección de materiales
  void _onMaterialSeleccionado(String sistema, String material, bool? isSelected) {
    setState(() {
      if (isSelected == true) {
        _materialesSeleccionados[sistema]?.add(material);
      } else {
        _materialesSeleccionados[sistema]?.remove(material);
        if (material == '¿Cuál?') {
          _otroMaterialControllers[sistema]?.clear();
        }
      }
    });
  }

  // Función para guardar y continuar
  void _guardarYContinuar() async {
    // Validar que al menos un sistema estructural esté seleccionado
    if (!_sistemasSeleccionados.containsValue(true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor seleccione al menos un sistema estructural')),
      );
      return;
    }

    // Validar que para cada sistema seleccionado, al menos un material esté seleccionado
    for (var sistema in sistemasEstructurales) {
      if (_sistemasSeleccionados[sistema] == true) {
        if (materialesPorSistema[sistema]!.isNotEmpty && (_materialesSeleccionados[sistema]?.isEmpty ?? true)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Por favor seleccione al menos un material para "$sistema"')),
          );
          return;
        }
        if (sistema == 'Otro' && (_materialesSeleccionados[sistema]?.contains('¿Cuál?') ?? false)) {
          if (_otroMaterialControllers[sistema]?.text.isEmpty ?? true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Por favor especifique el otro material')),
            );
            return;
          }
        }
      }
    }

    // Preparar datos para guardar
    List<Map<String, dynamic>> datosGuardar = [];

    for (var sistema in sistemasEstructurales) {
      if (_sistemasSeleccionados[sistema] == true) {
        List<String> materiales = _materialesSeleccionados[sistema] ?? [];
        String materialesGuardados = '';

        if (sistema == 'Otro' && materiales.contains('¿Cuál?')) {
          materialesGuardados = _otroMaterialControllers[sistema]?.text ?? 'Otro';
        } else {
          materialesGuardados = materiales.join(', ');
        }

        datosGuardar.add({
          'evaluacion_edificio_id': widget.evaluacionEdificioId,
          'sistema_estructural': sistema,
          'materiales': materialesGuardados,
        });
      }
    }

    // Insertar en la base de datos
    final db = DatabaseHelper();
    for (var datos in datosGuardar) {
      await db.insertarSistemaEstructuralMaterial(datos);
    }

    // Navegar a la siguiente pantalla
    Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SistemaEntrepisoScreen(
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
        title: const Text('Sistema Estructural y Material'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form( // Agregado Form para validaciones
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sistemas Estructurales',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // Lista de Checkbox para sistemas estructurales
              ...sistemasEstructurales.map((sistema) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CheckboxListTile(
                      title: Text(sistema),
                      value: _sistemasSeleccionados[sistema],
                      onChanged: (bool? value) {
                        _onSistemaSeleccionado(sistema, value);
                      },
                    ),
                    // Si el sistema está seleccionado, mostrar sus materiales
                    if (_sistemasSeleccionados[sistema] == true)
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Materiales disponibles:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            ...materialesPorSistema[sistema]!.map((material) {
                              if (sistema == 'Otro' && material == 'Losa - columna en concreto') {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CheckboxListTile(
                                      title: Text(material),
                                      value: _materialesSeleccionados[sistema]?.contains(material),
                                      onChanged: (bool? value) {
                                        _onMaterialSeleccionado(sistema, material, value);
                                      },
                                    ),
                                    // Campo de texto para "¿Cuál?"
                                    if (_materialesSeleccionados[sistema]?.contains(material) ?? false)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 20.0, bottom: 10.0),
                                        child: TextFormField(
                                          controller: _otroMaterialControllers[sistema],
                                          decoration: const InputDecoration(
                                            labelText: '¿Cuál?',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              } else {
                                return CheckboxListTile(
                                  title: Text(material),
                                  value: _materialesSeleccionados[sistema]?.contains(material),
                                  onChanged: (bool? value) {
                                    _onMaterialSeleccionado(sistema, material, value);
                                  },
                                );
                              }
                            }).toList(),
                            // Si no hay materiales para "No es claro"
                            if (sistema == 'No es claro')
                              const Padding(
                                padding: EdgeInsets.only(left: 20.0, top: 5.0),
                                child: Text(
                                  'No hay materiales listados en esta sección.',
                                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                );
              }).toList(),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _guardarYContinuar,
                child: const Text('Guardar y Continuar'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}