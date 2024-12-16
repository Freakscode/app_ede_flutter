// ignore_for_file: constant_identifier_names, unreachable_switch_default

import 'package:flutter/material.dart';
import '../../utils/database_helper.dart';
import '../acciones_recomendadas/evaluacion_completa.dart'; // Importar la pantalla de Recomendaciones y Medidas

enum CriterioHabitabilidad {
  H_Segura,
  R1_AreasInseguras,
  R2_EntradaLimitada,
  I1_RiesgoExternos,
  I2_AfectacionFuncion,
  I3_SevereDamage,
  Desconocida,
}

class HabitabilidadScreen extends StatefulWidget {
  final int evaluacionId;
  final int evaluacionEdificioId;
  final String severidadDanio;
  final String porcentajeAfectacion;

  const HabitabilidadScreen({
    Key? key,
    required this.evaluacionId,
    required this.evaluacionEdificioId,
    required this.severidadDanio,
    required this.porcentajeAfectacion,
  }) : super(key: key);

  @override
  _HabitabilidadScreenState createState() => _HabitabilidadScreenState();
}

class _HabitabilidadScreenState extends State<HabitabilidadScreen> {
  CriterioHabitabilidad criterioHabitabilidad = CriterioHabitabilidad.Desconocida;
  Color colorHabitabilidad = Colors.grey;

  // Datos recuperados
  final Map<String, bool> respuestasRiesgos = {};

  @override
  void initState() {
    super.initState();
    _recuperarDatos();
  }

  Future<void> _recuperarDatos() async {
    final db = DatabaseHelper();

    // 1. Recuperar respuestas de Identificación de Riesgos Externos
    List<Map<String, dynamic>> riesgos = await db.obtenerEvaluacionRiesgos(widget.evaluacionId);
    for (var riesgo in riesgos) {
      respuestasRiesgos['4.${riesgo['riesgo_id']}'] = riesgo['existe_riesgo'] == 1;
    }

    print('Respuestas Riesgos: $respuestasRiesgos');
    print('Severidad de Daño: ${widget.severidadDanio}');
    print('Porcentaje de Afectación: ${widget.porcentajeAfectacion}');

    // 2. Calcular habitabilidad usando los argumentos pasados
    _calcularHabitabilidad();
  }

  void _calcularHabitabilidad() {
    // Verificar si hay riesgos externos
    bool tieneRiesgosExternos = respuestasRiesgos.values.any((respuesta) => respuesta == true);

    // Obtener severidad y porcentaje en minúsculas para facilitar las comparaciones
    String severidad = widget.severidadDanio.toLowerCase();
    String porcentaje = widget.porcentajeAfectacion.toLowerCase();

    // Debugging: Verificar los valores recibidos
    print('Calculando Habitabilidad con Severidad: $severidad y Porcentaje: $porcentaje');

    // Reiniciar criterio y color
    criterioHabitabilidad = CriterioHabitabilidad.Desconocida;
    colorHabitabilidad = Colors.grey;

    // **Casos Especiales**
    if (severidad == 'medio alto') {
      if (porcentaje == '40-70%') {
        criterioHabitabilidad = CriterioHabitabilidad.I2_AfectacionFuncion;
        colorHabitabilidad = Colors.redAccent;
      } else if (porcentaje == '>70%') {
        criterioHabitabilidad = CriterioHabitabilidad.I3_SevereDamage;
        colorHabitabilidad = Colors.red;
      } else if (porcentaje == '<10%' || porcentaje == '10-40%') {
        criterioHabitabilidad = CriterioHabitabilidad.R1_AreasInseguras;
        colorHabitabilidad = Colors.orange;
      }
    } 
    else if (severidad == 'medio' && porcentaje == '>70%') {
      criterioHabitabilidad = CriterioHabitabilidad.I2_AfectacionFuncion;
      colorHabitabilidad = Colors.redAccent;
    }
    else if (tieneRiesgosExternos) {
      if (severidad == 'alto') {
        criterioHabitabilidad = CriterioHabitabilidad.I3_SevereDamage;
        colorHabitabilidad = Colors.red;
      } else if (severidad == 'medio alto') {
        criterioHabitabilidad = CriterioHabitabilidad.I2_AfectacionFuncion;
        colorHabitabilidad = Colors.redAccent;
      } else {
        criterioHabitabilidad = CriterioHabitabilidad.I1_RiesgoExternos;
        colorHabitabilidad = Colors.redAccent;
      }
    } else {
      switch (severidad) {
        case 'bajo':
          if (porcentaje == '<10%' || porcentaje == '10-40%') {
            criterioHabitabilidad = CriterioHabitabilidad.H_Segura;
            colorHabitabilidad = Colors.green;
          } else {
            criterioHabitabilidad = CriterioHabitabilidad.R1_AreasInseguras;
            colorHabitabilidad = Colors.orange;
          }
          break;
        case 'medio':
          if (porcentaje == '10-40%' || porcentaje == '40-70%') {
            criterioHabitabilidad = CriterioHabitabilidad.R1_AreasInseguras;
            colorHabitabilidad = Colors.orange;
          }
          break;
        case 'alto':
          criterioHabitabilidad = CriterioHabitabilidad.I3_SevereDamage;
          colorHabitabilidad = Colors.red;
          break;
        default:
          criterioHabitabilidad = CriterioHabitabilidad.Desconocida;
          colorHabitabilidad = Colors.grey;
      }
    }

    // Debugging: Verificar el criterio asignado
    print('Categoría de Habitabilidad Asignada: $criterioHabitabilidad');

    setState(() {});
  }

  Future<void> _guardarHabitabilidad() async {
    final db = DatabaseHelper();
    
    // Mapear CriterioHabitabilidad a habitabilidad_id
    int habitabilidadId;
    switch (criterioHabitabilidad) {
      case CriterioHabitabilidad.H_Segura:
        habitabilidadId = 1; // Habitable
        break;
      case CriterioHabitabilidad.R1_AreasInseguras:
      case CriterioHabitabilidad.R2_EntradaLimitada:
        habitabilidadId = 2; // Acceso Restringido
        break;
      case CriterioHabitabilidad.I1_RiesgoExternos:
      case CriterioHabitabilidad.I2_AfectacionFuncion:
      case CriterioHabitabilidad.I3_SevereDamage:
        habitabilidadId = 3; // No Habitable
        break;
      case CriterioHabitabilidad.Desconocida:
      default:
        habitabilidadId = 4; // No Determinado
    }

    await db.insertarEvaluacionHabitabilidad({
      'evaluacion_id': widget.evaluacionId,
      'habitabilidad_id': habitabilidadId,
    });

    // Mostrar un mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Evaluación de Habitabilidad guardada correctamente.')),
    );

    // Navegar a Recomendaciones y Medidas
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EvaluacionCompletaScreen(
          evaluacionEdificioId: widget.evaluacionEdificioId,
          evaluacionId: widget.evaluacionId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('7. Habitabilidad'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Mostrar datos recuperados
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Severidad de Daño: ${widget.severidadDanio}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text('Porcentaje de Afectación: ${widget.porcentajeAfectacion}'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Mostrar resultado de Habitabilidad
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              color: colorHabitabilidad,
              child: Text(
                'Categoría de Habitabilidad: ${_obtenerDescripcionCriterio(criterioHabitabilidad)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _colorTextoHabitabilidad(),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            // Botón para guardar
            ElevatedButton(
              onPressed: _guardarHabitabilidad,
              child: const Text('Guardar y Continuar'),
            ),
          ],
        ),
      ),
    );
  }

  String _obtenerDescripcionCriterio(CriterioHabitabilidad criterio) {
    switch (criterio) {
      case CriterioHabitabilidad.H_Segura:
        return 'Habitabilidad Segura';
      case CriterioHabitabilidad.R1_AreasInseguras:
        return 'R1 - Áreas Inseguras';
      case CriterioHabitabilidad.R2_EntradaLimitada:
        return 'R2 - Entrada Limitada';
      case CriterioHabitabilidad.I1_RiesgoExternos:
        return 'I1 - Riesgo por Factores Externos';
      case CriterioHabitabilidad.I2_AfectacionFuncion:
        return 'I2 - Afectación Funcional';
      case CriterioHabitabilidad.I3_SevereDamage:
        return 'I3 - Daño Severo en la Edificación';
      case CriterioHabitabilidad.Desconocida:
      default:
        return 'No Determinado';
    }
  }

  Color _colorTextoHabitabilidad() {
    if (criterioHabitabilidad == CriterioHabitabilidad.H_Segura ||
        criterioHabitabilidad == CriterioHabitabilidad.R1_AreasInseguras ||
        criterioHabitabilidad == CriterioHabitabilidad.R2_EntradaLimitada) {
      return Colors.black;
    } else {
      return Colors.white;
    }
  }
}