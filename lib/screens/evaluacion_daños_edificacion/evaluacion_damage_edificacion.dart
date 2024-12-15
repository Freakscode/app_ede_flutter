import 'package:flutter/material.dart';
import '../../utils/database_helper.dart'; 
import '../damage_assessment/damage_assessment_screen.dart'; 


class EvaluacionDamagesEdificacionScreen extends StatefulWidget {
  final int evaluacionId;
  final int evaluacionEdificioId;

  const EvaluacionDamagesEdificacionScreen({
    Key? key,
    required this.evaluacionId,
    required this.evaluacionEdificioId,
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
        // Si no eligió nada, podrías asumir No (0) o simplemente no guardar.
        // Asumamos valor = 0 si no se seleccionó.
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
        // Si no eligió nada, podríamos asumir 'Sin daño' = 1
        await _insertarOActualizarEvaluacionElementoDano(db, elemento, 1);
      } else {
        final nivelDanoId = _mapearTextoANivelDanoId(nivelDanoTexto);
        await _insertarOActualizarEvaluacionElementoDano(db, elemento, nivelDanoId);
      }
    }

    // Luego de guardar, navegar a la nueva pantalla.
    // Ajusta el nombre de la pantalla a la que deseas navegar (DamageAssessmentScreen es un ejemplo)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DamageAssessmentScreen(
          evaluacionId: widget.evaluacionId,
          evaluacionEdificioId: widget.evaluacionEdificioId,
        ),
      ),
    );
  }

  int _mapearTextoANivelDanoId(String nivel) {
    // Mapeo arbitrario. Asegúrate de que en la BD tengas correspondencia.
    // Por ejemplo, puedes asumir que ya tienes 4 registros en NivelDaño que correspondan a estos.
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
    } else {
      await database.update('EvaluacionCondiciones', {
        'valor': valor,
      },
      where: 'evaluacion_edificio_id = ? AND condicion = ?',
      whereArgs: [widget.evaluacionEdificioId, condicion]);
    }
  }

  Future<void> _insertarOActualizarEvaluacionElementoDano(DatabaseHelper db, String elemento, int nivelDanoId) async {
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
    } else {
      await database.update('EvaluacionElementoDano', {
        'nivel_dano_id': nivelDanoId,
      },
      where: 'evaluacion_edificio_id = ? AND elemento = ?',
      whereArgs: [widget.evaluacionEdificioId, elemento]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('5. Evaluación de Daños en la Edificación'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '5.1 - 5.6'),
            Tab(text: '5.7 - 5.11'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSubseccionCondiciones(),
                _buildSubseccionElementos(),
              ],
            ),
          ),
          // Botón para guardar datos y continuar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _guardarDatos,
              child: const Text('Guardar y Continuar'),
            ),
          ),
        ],
      ),
    );
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

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$codigo $descripcion',
                style: const TextStyle(fontWeight: FontWeight.bold),
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

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$codigo $descripcion',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: opcionesDanio.map((opcion) {
                  return ChoiceChip(
                    label: Text(opcion),
                    selected: valor == opcion,
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
        );
      },
    );
  }
}
