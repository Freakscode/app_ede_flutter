// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'package:flutter/material.dart';
import '../../utils/database_helper.dart'; // Asegúrate de ajustar la ruta si es necesario
import '../acciones_recomendadas/evaluacion_adicional/evaluacion_adicional.dart'; // Asegúrate de ajustar la ruta

class HabitabilidadScreen extends StatefulWidget {
  final int evaluacionId;
  final int evaluacionEdificioId;
  final String nivelDanioGlobal; // Pasamos el nivel de daño global desde Sección 6

  const HabitabilidadScreen({
    Key? key,
    required this.evaluacionId,
    required this.evaluacionEdificioId,
    required this.nivelDanioGlobal,
  }) : super(key: key);

  @override
  _HabitabilidadScreenState createState() => _HabitabilidadScreenState();
}

class _HabitabilidadScreenState extends State<HabitabilidadScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Lista de ítems a evaluar.
  final List<String> items = [
    '4.1 Caída de objetos de edificios adyacentes.',
    '4.2 Colapso o probable colapso de edificios adyacentes.',
    '4.3 Falla en sistemas de distribución de servicios públicos (energía, gas, etc.).',
    '4.4 Inestabilidad del terreno, movimientos en masa en el área.',
    '4.5 Accesos y salidas.',
    '4.6 Otro',
  ];

  // Estructura: respuestas[item] = {'a': bool?, 'b': bool?, 'c': bool?}
  Map<String, Map<String, bool?>> respuestas = {};

  String _habitabilidad = 'Desconocida'; // Habitable, Acceso Restringido, No Habitable

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    for (var item in items) {
      respuestas[item] = {
        'a': null, // Existe riesgo externo
        'b': null, // Compromete estabilidad
        'c': null, // Compromete accesos/ocupantes
      };
    }

    _determinarHabitabilidad();
  }

  void _determinarHabitabilidad() {
    bool todosNoA = true;
    bool algunSiAyc = false;
    bool algunSiAyb = false;

    for (var r in respuestas.values) {
      bool? a = r['a'];
      bool? b = r['b'];
      bool? c = r['c'];

      if (a == true) todosNoA = false;
      if (a == true && c == true) algunSiAyc = true;
      if (a == true && b == true) algunSiAyb = true;
    }

    // Nivel daño global, por ejemplo: 'bajo','medio','alto','sin daño'
    String ndg = widget.nivelDanioGlobal.toLowerCase();

    // Lógica basada en la matriz de nivel de daño
    if (todosNoA && (ndg == 'sin daño' || ndg == 'bajo')) {
      _habitabilidad = 'Habitable';
    } else if (todosNoA && ndg == 'medio') {
      _habitabilidad = 'Acceso Restringido'; // R1 - Áreas inseguras
    } else if (algunSiAyc && ndg == 'medio') {
      _habitabilidad = 'Acceso Restringido'; // R2 - Entrada limitada
    } else if (algunSiAyb) {
      _habitabilidad = 'No Habitable';
    } else {
      _habitabilidad = 'No Habitable'; // Caso por defecto si no encaja en las condiciones
    }

    setState(() {});
  }

  Future<void> _guardarHabitabilidadYRiesgos() async {
    final db = DatabaseHelper();
    final database = await db.database;

    try {
      await database.transaction((txn) async {
        // Insertar o actualizar EvaluacionRiesgos
        // Primero, eliminar entradas anteriores
        await txn.delete(
          'EvaluacionRiesgos',
          where: 'evaluacion_id = ?',
          whereArgs: [widget.evaluacionId],
        );

        // Guardar las respuestas de riesgos externos
        int riesgoId = 1;
        for (var entry in respuestas.entries) {
          final item = entry.key;
          final valores = entry.value;
          final existeRiesgo = (valores['a'] == true) ? 1 : 0;
          final comprometeEstabilidad = (valores['b'] == true) ? 1 : 0;
          final comprometeAccesos = (valores['c'] == true) ? 1 : 0;

          await txn.insert(
            'EvaluacionRiesgos',
            {
              'evaluacion_id': widget.evaluacionId,
              'riesgo_id': riesgoId,
              'existe_riesgo': existeRiesgo,
              'compromete_estabilidad': comprometeEstabilidad,
              'compromete_accesos': comprometeAccesos,
            },
          );

          riesgoId++;
        }

        // Insertar EvaluacionHabitabilidad
        int habitabilidadId = await _getHabitabilidadId(_habitabilidad);

        await txn.insert(
          'EvaluacionHabitabilidad',
          {
            'evaluacion_id': widget.evaluacionId,
            'habitabilidad_id': habitabilidadId,
          },
        );
      });

      // Imprimir en consola los valores guardados
      print('Datos de Riesgos Externos y Habitabilidad guardados:');
      print(respuestas);
      print('Habitabilidad: $_habitabilidad');

      // Navegar a sección 8
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EvaluacionAdicionalScreen(
            evaluacionId: widget.evaluacionId,
            evaluacionEdificioId: widget.evaluacionEdificioId,
          ),
        ),
      );
    } catch (e) {
      print('Error al guardar datos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  Future<int> _getHabitabilidadId(String habitabilidadDesc) async {
    final db = DatabaseHelper();
    final res = await db.obtenerHabitabilidad();
    // Filtrar la que coincida con habitabilidadDesc
    for (var h in res) {
      if (h['descripcion'].toString().toLowerCase() == habitabilidadDesc.toLowerCase()) {
        return h['id'];
      }
    }
    // Si no la encuentra, asumir 'No Habitable'
    for (var h in res) {
      if (h['descripcion'].toString().toLowerCase() == 'no habitable') {
        return h['id'];
      }
    }
    return 3; // Asegúrate de que este ID corresponda a 'No Habitable'
  }

  Widget _buildTabContent(String seccion) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final pregunta = items[index];
        final valorActual = respuestas[pregunta]?[seccion];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pregunta,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Sí'),
                      value: true,
                      groupValue: valorActual,
                      onChanged: (val) {
                        setState(() {
                          respuestas[pregunta]?[seccion] = val;
                        });
                        _determinarHabitabilidad();
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('No'),
                      value: false,
                      groupValue: valorActual,
                      onChanged: (val) {
                        setState(() {
                          respuestas[pregunta]?[seccion] = val;
                        });
                        _determinarHabitabilidad();
                      },
                    ),
                  ),
                ],
              ),
              const Divider(),
            ],
          ),
        );
      },
    );
  }

  // En la última subsección agregamos el botón para continuar
  Widget _buildLastTabContent(String seccion) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final pregunta = items[index];
              final valorActual = respuestas[pregunta]?[seccion];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pregunta,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('Sí'),
                            value: true,
                            groupValue: valorActual,
                            onChanged: (val) {
                              setState(() {
                                respuestas[pregunta]?[seccion] = val;
                              });
                              _determinarHabitabilidad();
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('No'),
                            value: false,
                            groupValue: valorActual,
                            onChanged: (val) {
                              setState(() {
                                respuestas[pregunta]?[seccion] = val;
                              });
                              _determinarHabitabilidad();
                            },
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _guardarHabitabilidadYRiesgos,
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
              textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            child: const Text('Guardar y Continuar'),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('7. Habitabilidad'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'a) Existe Riesgo'),
            Tab(text: 'b) Estabilidad'),
            Tab(text: 'c) Accesos/Ocupantes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabContent('a'),
          _buildTabContent('b'),
          _buildLastTabContent('c'), // La última subsección con botón
        ],
      ),
    );
  }
}
