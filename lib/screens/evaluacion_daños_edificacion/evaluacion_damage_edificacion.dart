// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import '../../utils/database_helper.dart';
import '../alcance_evaluacion/alcance_evaluacion_screen.dart'; // Importar la siguiente pantalla
import '../../widgets/floating_navigation_menu.dart'; // Importar el menú flotante

class EvaluacionDamagesEdificacionScreen extends StatefulWidget {
  final int evaluacionId;
  final int evaluacionEdificioId;
  final int userId;

  const EvaluacionDamagesEdificacionScreen({
    Key? key,
    required this.evaluacionId,
    required this.evaluacionEdificioId,
    required this.userId,
  }) : super(key: key);

  @override
  _EvaluacionDamagesEdificacionScreenState createState() =>
      _EvaluacionDamagesEdificacionScreenState();
}

class _EvaluacionDamagesEdificacionScreenState
    extends State<EvaluacionDamagesEdificacionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Primera subsección (5.1 - 5.6) con opciones Sí/No
  final List<Map<String, String>> condiciones = [
    {'codigo': '5.1', 'descripcion': 'Colapso total'},
    {'codigo': '5.2', 'descripcion': 'Colapso parcial'},
    {'codigo': '5.3', 'descripcion': 'Asentamiento severo en elementos estructurales'},
    {'codigo': '5.4', 'descripcion': 'Inclinación o desviación importante de la edificación o de un piso'},
    {
      'codigo': '5.5',
      'descripcion':
          'Problemas de inestabilidad en el suelo de cimentación (Mov. en masa, licuefacción, subsistencia, cambios volumétricos, asentamientos)'
    },
    {
      'codigo': '5.6',
      'descripcion':
          'Riesgo de caídas de elementos (antepechos, fachadas, ventanas, etc.)'
    },
  ];

  // Segunda subsección (5.7 - 5.11) con opciones Sin daño, Leve, Moderado, Severo
  final List<Map<String, String>> elementos = [
    {
      'codigo': '5.7',
      'descripcion':
          'Daño en muros de carga, columnas, y otros elementos estructurales primordiales'
    },
    {
      'codigo': '5.8',
      'descripcion':
          'Daño en sistemas de contrapisos, entrepisos, muros estructurales'
    },
    {
      'codigo': '5.9',
      'descripcion':
          'Daño en muros divisorios, muros de fachada, antepechos, barandas'
    },
    {
      'codigo': '5.10',
      'descripcion': 'Cubierta (revestimiento y estructura de soporte)'
    },
    {
      'codigo': '5.11',
      'descripcion':
          'Cielo rasos, luminarias, instalaciones y otros elementos no estructurales diferentes de muros'
    },
  ];

  // Respuestas de la primera subsección (Sí/No)
  // Estructura: {'5.1': true/false, '5.2': true/false, ...} (true=Sí, false=No)
  Map<String, bool?> respuestasCondiciones = {};

  // Respuestas de la segunda subsección (Sin daño, Leve, Moderado, Severo)
  // Estructura: {'5.7': 'Sin daño'/'Leve'/'Moderado'/'Severo', ...}
  Map<String, String?> respuestasElementos = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Inicializar respuestas
    for (var c in condiciones) {
      respuestasCondiciones[c['codigo']!] = null;
    }

    for (var e in elementos) {
      respuestasElementos[e['codigo']!] = null;
    }
  }

  Future<void> _guardarDatos() async {
    // Aquí guardamos los datos en la BD
    final db = DatabaseHelper();

    // Guardar condiciones (5.1 - 5.6)
    for (var entry in respuestasCondiciones.entries) {
      final condicion = entry.key; // Ej: '5.1'
      final valorBool = entry.value;
      if (valorBool == null) {
        // Asumimos valor = 0 si no se seleccionó
        await _insertarOActualizarEvaluacionCondicion(db, condicion, 0);
      } else {
        final valorInt = valorBool ? 1 : 0;
        await _insertarOActualizarEvaluacionCondicion(db, condicion, valorInt);
      }
    }

    // Guardar elementos (5.7 - 5.11)
    for (var entry in respuestasElementos.entries) {
      final elemento = entry.key;
      final nivelDanoTexto = entry.value;
      if (nivelDanoTexto == null) {
        // Asumimos 'Sin daño' = 1
        await _insertarOActualizarEvaluacionElementoDano(db, elemento, 1);
      } else {
        final nivelDanoId = _mapearTextoANivelDanoId(nivelDanoTexto);
        await _insertarOActualizarEvaluacionElementoDano(db, elemento, nivelDanoId);
      }
    }

    // Luego de guardar, navegar a la nueva pantalla.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlcanceEvaluacionScreen(
          evaluacionId: widget.evaluacionId,
          evaluacionEdificioId: widget.evaluacionEdificioId,
          userId: widget.userId,
        ),
      ),
    );
  }

  int _mapearTextoANivelDanoId(String nivel) {
    // Mapeo arbitrario. Asegúrate de que en la BD tengas correspondencia.
    switch (nivel) {
      case 'Sin daño':
        return 1;
      case 'Leve':
        return 2;
      case 'Moderado':
        return 3;
      case 'Severo':
        return 4;
      default:
        return 1;
    }
  }

  Future<void> _insertarOActualizarEvaluacionCondicion(DatabaseHelper db, String condicion, int valor) async {
    try {
      final database = await db.database;
      final existe = await database.query(
        'EvaluacionCondiciones',
        where: 'evaluacion_edificio_id = ? AND condicion = ?',
        whereArgs: [widget.evaluacionEdificioId, condicion],
        limit: 1,
      );

      if (existe.isEmpty) {
        await database.insert('EvaluacionCondiciones', {
          'evaluacion_edificio_id': widget.evaluacionEdificioId,
          'condicion': condicion,
          'valor': valor,
        });
        print('Insertada condición $condicion con valor $valor');
      } else {
        await database.update(
          'EvaluacionCondiciones',
          {'valor': valor},
          where: 'evaluacion_edificio_id = ? AND condicion = ?',
          whereArgs: [widget.evaluacionEdificioId, condicion],
        );
        print('Actualizada condición $condicion a valor $valor');
      }
    } catch (e) {
      print('Error al insertar/actualizar condición $condicion: $e');
    }
  }

  Future<void> _insertarOActualizarEvaluacionElementoDano(DatabaseHelper db, String elemento, int nivelDanoId) async {
    try {
      final database = await db.database;
      final existe = await database.query(
        'EvaluacionElementoDano',
        where: 'evaluacion_edificio_id = ? AND elemento = ?',
        whereArgs: [widget.evaluacionEdificioId, elemento],
        limit: 1,
      );

      if (existe.isEmpty) {
        await database.insert('EvaluacionElementoDano', {
          'evaluacion_edificio_id': widget.evaluacionEdificioId,
          'elemento': elemento,
          'nivel_dano_id': nivelDanoId,
        });
        print('Insertado daño en elemento $elemento con nivel $nivelDanoId');
      } else {
        await database.update(
          'EvaluacionElementoDano',
          {'nivel_dano_id': nivelDanoId},
          where: 'evaluacion_edificio_id = ? AND elemento = ?',
          whereArgs: [widget.evaluacionEdificioId, elemento],
        );
        print('Actualizado daño en elemento $elemento a nivel $nivelDanoId');
      }
    } catch (e) {
      print('Error al insertar/actualizar daño en elemento $elemento: $e');
    }
  }

  Color _detectarColorCondicion(String codigo, bool? respuesta) {
    if (respuesta == null) return Colors.white;

    if (['5.1', '5.2', '5.3', '5.4'].contains(codigo)) {
      return respuesta ? Colors.red : Colors.green;
    } else if (['5.5', '5.6'].contains(codigo)) {
      return respuesta ? Colors.orange : Colors.green;
    } else {
      return Colors.white;
    }
  }

  Color _detectarColorElemento(String codigo, String? respuesta) {
    if (respuesta == null) return Colors.white;

    switch (respuesta) {
      case 'Sin daño':
        return Colors.white;
      case 'Leve':
        return Colors.green;
      case 'Moderado':
        return codigo == '5.7' ? Colors.orange : Colors.yellow;
      case 'Severo':
        return codigo == '5.7' ? Colors.red : Colors.orange;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluación de Daños Edificación'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Condiciones'),
            Tab(text: 'Elementos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSubseccionCondiciones(),
          _buildSubseccionElementos(),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingSectionsMenu(
            currentSection: _tabController.index + 1,
            onSectionSelected: _onSectionSelected,
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            onPressed: _guardarDatos,
            label: const Text('Guardar y Continuar'),
            icon: const Icon(Icons.save),
            backgroundColor: const Color(0xFF002855),
          ),
        ],
      ),
    );
  }

  void _onSectionSelected(int section) {
    setState(() {
      _tabController.animateTo(section - 1); // Navegar a la pestaña correspondiente
    });
  }

  Widget _buildSubseccionCondiciones() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: condiciones.length,
      itemBuilder: (context, index) {
        final item = condiciones[index];
        final codigo = item['codigo']!;
        final descripcion = item['descripcion']!;
        final valor = respuestasCondiciones[codigo];

        return Card(
          color: _detectarColorCondicion(codigo, valor),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$codigo - $descripcion',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Sí'),
                        value: true,
                        groupValue: valor,
                        onChanged: (val) {
                          setState(() {
                            respuestasCondiciones[codigo] = val;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('No'),
                        value: false,
                        groupValue: valor,
                        onChanged: (val) {
                          setState(() {
                            respuestasCondiciones[codigo] = val;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const Divider(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubseccionElementos() {
    final opcionesDanio = ['Sin daño', 'Leve', 'Moderado', 'Severo'];

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: elementos.length,
      itemBuilder: (context, index) {
        final item = elementos[index];
        final codigo = item['codigo']!;
        final descripcion = item['descripcion']!;
        final valor = respuestasElementos[codigo];

        return Card(
          color: _detectarColorElemento(codigo, valor),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$codigo - $descripcion',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: opcionesDanio.map((opcion) {
                    return ChoiceChip(
                      label: Text(opcion),
                      selected: valor == opcion,
                      selectedColor: _detectarColorElemento(codigo, valor).withOpacity(0.7),
                      onSelected: (selected) {
                        setState(() {
                          respuestasElementos[codigo] = selected ? opcion : null;
                        });
                      },
                    );
                  }).toList(),
                ),
                const Divider(),
              ],
            ),
          ),
        );
      },
    );
  }
}