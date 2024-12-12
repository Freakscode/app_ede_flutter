import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import '../utils/database_helper.dart';

Future<void> seedDatabase() async {
  final dbHelper = DatabaseHelper();
  final db = await dbHelper.database;

  // Función para hashear la contraseña
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Verificar si ya existen usuarios
  final List<Map<String, dynamic>> usuarios = await db.query('Usuarios');
  
  if (usuarios.isEmpty) {
    try {
      // Insertar usuarios solo si la tabla está vacía
      await db.insert('Usuarios', {
        'cedula': '1234567890',
        'nombre': 'Evaluador 1',
        'pwd': hashPassword('password123'),
        'dependencia_entidad': 'DAGRD',
        'fecha_registro': DateTime.now().toIso8601String(),
      });

      await db.insert('Usuarios', {
        'cedula': '0987654321',
        'nombre': 'Evaluador 2',
        'pwd': hashPassword('password456'), 
        'dependencia_entidad': 'DAGRD',
        'fecha_registro': DateTime.now().toIso8601String(),
      });

      print('Usuarios de prueba creados exitosamente');

      // Insertar evaluaciones para Evaluador 1 (id: 1)
      List<Map<String, dynamic>> evaluacionesUsuario1 = [
        {
          'eventoId': 1001,
          'tipo_evento_id': 1,
          'usuario_id': 1,
          'fecha_inspeccion': '2023-10-01',
          'hora': '10:00',
          'dependencia_entidad': 'Entidad A',
        },
        {
          'eventoId': 1002,
          'tipo_evento_id': 2,
          'usuario_id': 1,
          'fecha_inspeccion': '2023-10-02',
          'hora': '11:00',
          'dependencia_entidad': 'Entidad B',
        },
        {
          'eventoId': 1003,
          'tipo_evento_id': 3,
          'usuario_id': 1,
          'fecha_inspeccion': '2023-10-03',
          'hora': '12:00',
          'dependencia_entidad': 'Entidad C',
        },
        {
          'eventoId': 1004,
          'tipo_evento_id': 4,
          'usuario_id': 1,
          'fecha_inspeccion': '2023-10-04',
          'hora': '13:00',
          'dependencia_entidad': 'Entidad D',
        },
        {
          'eventoId': 1005,
          'tipo_evento_id': 5,
          'usuario_id': 1,
          'fecha_inspeccion': '2023-10-05',
          'hora': '14:00',
          'dependencia_entidad': 'Entidad E',
        },
      ];

      for (var evaluacion in evaluacionesUsuario1) {
        await db.insert('Evaluaciones', evaluacion,
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }

      // Insertar evaluaciones para Evaluador 2 (id: 2)
      List<Map<String, dynamic>> evaluacionesUsuario2 = [
        {
          'eventoId': 2001,
          'tipo_evento_id': 1,
          'usuario_id': 2,
          'fecha_inspeccion': '2023-10-06',
          'hora': '09:00',
          'dependencia_entidad': 'Entidad F',
        },
        {
          'eventoId': 2002,
          'tipo_evento_id': 2,
          'usuario_id': 2,
          'fecha_inspeccion': '2023-10-07',
          'hora': '10:30',
          'dependencia_entidad': 'Entidad G',
        },
        {
          'eventoId': 2003,
          'tipo_evento_id': 3,
          'usuario_id': 2,
          'fecha_inspeccion': '2023-10-08',
          'hora': '11:45',
          'dependencia_entidad': 'Entidad H',
        },
        {
          'eventoId': 2004,
          'tipo_evento_id': 4,
          'usuario_id': 2,
          'fecha_inspeccion': '2023-10-09',
          'hora': '13:15',
          'dependencia_entidad': 'Entidad I',
        },
        {
          'eventoId': 2005,
          'tipo_evento_id': 5,
          'usuario_id': 2,
          'fecha_inspeccion': '2023-10-10',
          'hora': '14:30',
          'dependencia_entidad': 'Entidad J',
        },
      ];

      for (var evaluacion in evaluacionesUsuario2) {
        await db.insert('Evaluaciones', evaluacion,
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }

      print('Evaluaciones de prueba creadas exitosamente');

      // Insertar EvaluacionEdificio con datos geográficos para cada evaluación
      List<Map<String, dynamic>> evaluacionEdificios = [
        // Evaluaciones de Evaluador 1
        {
          'evaluacion_id': 1,
          'edificio_id': 1, // Asegúrate de que el edificio con id 1 exista
          'codigo_medellin': 'MED1001',
          'codigo_area_metropolitana': 'AMED1001',
          'latitud': 6.244203,
          'longitud': -75.581212,
        },
        {
          'evaluacion_id': 2,
          'edificio_id': 2,
          'codigo_medellin': 'MED1002',
          'codigo_area_metropolitana': 'AMED1002',
          'latitud': 6.263155,
          'longitud': -75.567545,
        },
        {
          'evaluacion_id': 3,
          'edificio_id': 3,
          'codigo_medellin': 'MED1003',
          'codigo_area_metropolitana': 'AMED1003',
          'latitud': 6.252495,
          'longitud': -75.586530,
        },
        {
          'evaluacion_id': 4,
          'edificio_id': 4,
          'codigo_medellin': 'MED1004',
          'codigo_area_metropolitana': 'AMED1004',
          'latitud': 6.240000,
          'longitud': -75.570000,
        },
        {
          'evaluacion_id': 5,
          'edificio_id': 5,
          'codigo_medellin': 'MED1005',
          'codigo_area_metropolitana': 'AMED1005',
          'latitud': 6.230000,
          'longitud': -75.580000,
        },
        // Evaluaciones de Evaluador 2
        {
          'evaluacion_id': 6,
          'edificio_id': 6,
          'codigo_medellin': 'MED2001',
          'codigo_area_metropolitana': 'AMED2001',
          'latitud': 6.270000,
          'longitud': -75.600000,
        },
        {
          'evaluacion_id': 7,
          'edificio_id': 7,
          'codigo_medellin': 'MED2002',
          'codigo_area_metropolitana': 'AMED2002',
          'latitud': 6.280000,
          'longitud': -75.610000,
        },
        {
          'evaluacion_id': 8,
          'edificio_id': 8,
          'codigo_medellin': 'MED2003',
          'codigo_area_metropolitana': 'AMED2003',
          'latitud': 6.290000,
          'longitud': -75.620000,
        },
        {
          'evaluacion_id': 9,
          'edificio_id': 9,
          'codigo_medellin': 'MED2004',
          'codigo_area_metropolitana': 'AMED2004',
          'latitud': 6.300000,
          'longitud': -75.630000,
        },
        {
          'evaluacion_id': 10,
          'edificio_id': 10,
          'codigo_medellin': 'MED2005',
          'codigo_area_metropolitana': 'AMED2005',
          'latitud': 6.310000,
          'longitud': -75.640000,
        },
      ];

      for (var evalEdificio in evaluacionEdificios) {
        await db.insert('EvaluacionEdificio', evalEdificio,
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }

      print('Evaluaciones de edificios de prueba creadas exitosamente');

    } catch (e) {
      print('Error insertando datos de prueba: $e');
    }
  } else {
    print('Ya existen usuarios en la base de datos');
  }
}