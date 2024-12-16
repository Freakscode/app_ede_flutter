import 'package:flutter/material.dart';
import '../../utils/database_helper.dart'; // Asegúrate de colocar la ruta correcta de tu DatabaseHelper
import '../evaluacion_daños_edificacion/evaluacion_damage_edificacion.dart';

class IdentificacionRiesgosExternosScreen extends StatefulWidget {
  final int evaluacionId;
  final int evaluacionEdificioId;

  const IdentificacionRiesgosExternosScreen({
    Key? key,
    required this.evaluacionId,
    required this.evaluacionEdificioId,
  }) : super(key: key);

  @override
  _IdentificacionRiesgosExternosScreenState createState() =>
      _IdentificacionRiesgosExternosScreenState();
}

class _IdentificacionRiesgosExternosScreenState
    extends State<IdentificacionRiesgosExternosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Lista de ítems a evaluar. Idealmente, estos deberían ser cargados desde la BD,
  // pero aquí los dejamos fijos como ejemplo.
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('4. Identificación de Riesgos Externos'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'a) Existe Riesgo Externo'),
            Tab(text: 'b) Compromete Acceso y/o Ocupantes'),
            Tab(text: 'c) Compromete Estabilidad de la Edificación'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabContent('a'),
          _buildTabContent('b'),
          _buildLastTabContent('c'), // La última subsección
        ],
      ),
    );
  }

  Widget _buildTabContent(String seccion) {
    List<String> itemsFiltrados = items;

    if (seccion != 'a') {
      itemsFiltrados = items.where((item) {
        return respuestas[item]?['a'] == true;
      }).toList();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: itemsFiltrados.length,
      itemBuilder: (context, index) {
        final pregunta = itemsFiltrados[index];
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
                    child: seccion == 'b'
                        ? Container(
                            color: respuestas[pregunta]?['b'] == true
                                ? Colors.yellow
                                : Colors.white,
                            child: RadioListTile<bool>(
                              title: const Text('Sí'),
                              value: true,
                              groupValue: valorActual,
                              onChanged: (val) {
                                setState(() {
                                  respuestas[pregunta]?[seccion] = val;
                                });
                              },
                            ),
                          )
                        : RadioListTile<bool>(
                            title: const Text('Sí'),
                            value: true,
                            groupValue: valorActual,
                            onChanged: (val) {
                              setState(() {
                                respuestas[pregunta]?[seccion] = val;
                              });
                            },
                          ),
                  ),
                  Expanded(
                    child: seccion == 'c'
                        ? Container(
                            color: respuestas[pregunta]?['c'] == true
                                ? Colors.red
                                : Colors.white,
                            child: RadioListTile<bool>(
                              title: const Text('Sí'),
                              value: true,
                              groupValue: valorActual,
                              onChanged: (val) {
                                setState(() {
                                  respuestas[pregunta]?[seccion] = val;
                                });
                              },
                            ),
                          )
                        : RadioListTile<bool>(
                            title: const Text('No'),
                            value: false,
                            groupValue: valorActual,
                            onChanged: (val) {
                              setState(() {
                                respuestas[pregunta]?[seccion] = val;
                              });
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
    List<String> itemsFiltrados = items.where((item) {
      return respuestas[item]?['a'] == true;
    }).toList();

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: itemsFiltrados.length,
            itemBuilder: (context, index) {
              final pregunta = itemsFiltrados[index];
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
                          child: seccion == 'b'
                              ? Container(
                                  color: respuestas[pregunta]?['b'] == true
                                      ? Colors.yellow
                                      : Colors.white,
                                  child: RadioListTile<bool>(
                                    title: const Text('Sí'),
                                    value: true,
                                    groupValue: valorActual,
                                    onChanged: (val) {
                                      setState(() {
                                        respuestas[pregunta]?[seccion] = val;
                                      });
                                    },
                                  ),
                                )
                              : RadioListTile<bool>(
                                  title: const Text('Sí'),
                                  value: true,
                                  groupValue: valorActual,
                                  onChanged: (val) {
                                    setState(() {
                                      respuestas[pregunta]?[seccion] = val;
                                    });
                                  },
                                ),
                        ),
                        Expanded(
                          child: seccion == 'c'
                              ? Container(
                                  color: respuestas[pregunta]?['c'] == true
                                      ? Colors.red
                                      : Colors.white,
                                  child: RadioListTile<bool>(
                                    title: const Text('Sí'),
                                    value: true,
                                    groupValue: valorActual,
                                    onChanged: (val) {
                                      setState(() {
                                        respuestas[pregunta]?[seccion] = val;
                                      });
                                    },
                                  ),
                                )
                              : RadioListTile<bool>(
                                  title: const Text('No'),
                                  value: false,
                                  groupValue: valorActual,
                                  onChanged: (val) {
                                    setState(() {
                                      respuestas[pregunta]?[seccion] = val;
                                    });
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
            onPressed: _guardarDatos,
            child: const Text('CONTINUAR'),
          ),
        )
      ],
    );
  }

  Future<void> _guardarDatos() async {
    final db = DatabaseHelper();
    final database = await db.database;

    try {
      await database.transaction((txn) async {
        // Eliminar entradas anteriores
        await txn.delete(
          'EvaluacionRiesgos',
          where: 'evaluacion_id = ?',
          whereArgs: [widget.evaluacionId],
        );

        // Guardar las respuestas
        int riesgoId = 1;
        for (var entry in respuestas.entries) {
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
      });

      // Imprimir en consola los valores guardados
      print('Datos guardados:');
      print(respuestas);

      // Navegar a la siguiente pantalla
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EvaluacionDamagesEdificacionScreen(
            evaluacionId: widget.evaluacionId,
            evaluacionEdificioId: widget.evaluacionEdificioId,
          ),
        ),
      );
    } catch (e) {
      print('Error al guardar datos: $e');
    }
  }
}
