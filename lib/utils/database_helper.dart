// ignore_for_file: unused_import

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // Database instance
  static Database? _database;

  // Getter for the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'app_database.db');
    print('Inicializando base de datos en: $path');

    return await openDatabase(
      path,
      version: 2, // Incrementa la versión para aplicar migraciones
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Create tables
  Future _onCreate(Database db, int version) async {
    // Tabla Usuarios
    await db.execute('''
      CREATE TABLE Usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cedula TEXT NOT NULL UNIQUE,
        nombre TEXT NOT NULL,
        pwd TEXT NOT NULL,
        dependencia_entidad TEXT,
        fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Tabla TipoEventos
    await db.execute('''
      CREATE TABLE TipoEventos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        descripcion TEXT NOT NULL UNIQUE
      )
    ''');

    // Tabla Evaluaciones
    await db.execute('''
    CREATE TABLE Evaluaciones (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      eventoId INTEGER NOT NULL,
      usuario_id INTEGER NOT NULL,
      fecha_inspeccion TEXT NOT NULL,
      hora TEXT NOT NULL,
      dependencia_entidad TEXT,
      id_grupo TEXT,
      firma BLOB,
      tipo_evento_id INTEGER,
      nombre_evaluador TEXT,
      otro_tipo_evento TEXT, -- Agregamos esta columna
      FOREIGN KEY (usuario_id) REFERENCES Usuarios(id),
      FOREIGN KEY (tipo_evento_id) REFERENCES TipoEventos(id)
    );
    ''');

    // Tabla Edificios
    await db.execute('''
      CREATE TABLE Edificios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre_edificacion TEXT,
        municipio TEXT NOT NULL,
        comuna TEXT NOT NULL,
        barrio_vereda TEXT NOT NULL,
        tipo_propiedad TEXT,
        departamento TEXT,
        tipo_via TEXT,
        numero_via TEXT,
        apendice_via TEXT,
        orientacion TEXT,
        numero_cruce TEXT,
        orientacion_cruce TEXT,
        complemento_direccion TEXT
      )
    ''');

    // Tabla EvaluacionEdificio
    await db.execute('''
      CREATE TABLE EvaluacionEdificio (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        evaluacion_id INTEGER NOT NULL,
        edificio_id INTEGER NOT NULL,
        codigo_medellin TEXT,
        codigo_area_metropolitana TEXT,
        latitud REAL NOT NULL,
        longitud REAL NOT NULL,
        FOREIGN KEY (evaluacion_id) REFERENCES Evaluaciones(id),
        FOREIGN KEY (edificio_id) REFERENCES Edificios(id)
      )
    ''');

    // Tabla Contacto
    await db.execute('''
      CREATE TABLE Contacto (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        edificio_id INTEGER NOT NULL,
        nombre TEXT NOT NULL,
        telefono TEXT,
        correo_electronico TEXT,
        tipo_persona TEXT CHECK(tipo_persona IN ('Propietario', 'Inquilino', 'Otro')),
        FOREIGN KEY (edificio_id) REFERENCES Edificios(id)
      )
    ''');

    // Tabla CaracteristicasGenerales
    await db.execute('''
  CREATE TABLE CaracteristicasGenerales (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    evaluacion_edificio_id INTEGER NOT NULL,
    numero_pisos INTEGER,
    numero_sotanos INTEGER,
    frente REAL,
    fondo REAL,
    unidades_residenciales INTEGER,
    unidades_no_habitadas INTEGER,
    unidades_comerciales INTEGER,
    ocupantes INTEGER,
    acceso TEXT CHECK(acceso IN ('Obstruido', 'Libre')),
    muertos INTEGER CHECK(muertos IN (0,1)),
    heridos INTEGER CHECK(heridos IN (0,1)),
    fecha_construccion TEXT,
    FOREIGN KEY (evaluacion_edificio_id) REFERENCES EvaluacionEdificio(id)
  )
''');

    await db.execute('''
  CREATE TABLE TipoSoporteCubierta (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    descripcion TEXT NOT NULL UNIQUE
  )
''');

    await db.execute('''
    CREATE TABLE RevestimientoCubierta (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      descripcion TEXT NOT NULL UNIQUE
    )
  ''');

    await db.execute('''
  CREATE TABLE SistemasCubierta (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    evaluacion_edificio_id INTEGER NOT NULL,
    sistema TEXT NOT NULL,
    materiales TEXT,
    FOREIGN KEY (evaluacion_edificio_id) REFERENCES EvaluacionEdificio(id)
  )
''');

    // Tabla UsosPredominantes
    await db.execute('''
      CREATE TABLE UsosPredominantes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        descripcion TEXT NOT NULL UNIQUE
      )
    ''');

    // Tabla EvaluacionUsos (Relación Muchos a Muchos)
    await db.execute('''
      CREATE TABLE EvaluacionUsos (
        evaluacion_edificio_id INTEGER NOT NULL,
        uso_predominante_id INTEGER NOT NULL,
        fecha_construccion DATE,
        PRIMARY KEY (evaluacion_edificio_id, uso_predominante_id),
        FOREIGN KEY (evaluacion_edificio_id) REFERENCES EvaluacionEdificio(id),
        FOREIGN KEY (uso_predominante_id) REFERENCES UsosPredominantes(id)
      )
    ''');

    // Tabla SistemaEstructural
    await db.execute('''
      CREATE TABLE SistemaEstructural (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        descripcion TEXT NOT NULL UNIQUE
      )
    ''');

    // Tabla Materiales
    await db.execute('''
      CREATE TABLE Materiales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        descripcion TEXT NOT NULL UNIQUE
      )
    ''');

    // Tabla SistemasEntrepiso
    await db.execute('''
      CREATE TABLE SistemasEntrepiso (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        descripcion TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
  CREATE TABLE MurosDivisorios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    descripcion TEXT NOT NULL UNIQUE
  )
''');

    await db.execute('''
  CREATE TABLE Fachadas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    descripcion TEXT NOT NULL UNIQUE
  )
''');

    await db.execute('''
  CREATE TABLE Escaleras (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    descripcion TEXT NOT NULL UNIQUE
  )
''');

    // Crear tabla ElementosNoEstructurales (ejemplo)
    await db.execute('''
    CREATE TABLE ElementosNoEstructurales (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      evaluacion_edificio_id INTEGER NOT NULL,
      muros_divisorios_mamposteria INTEGER DEFAULT 0,
      muros_divisorios_tierra INTEGER DEFAULT 0,
      muros_divisorios_bahareque INTEGER DEFAULT 0,
      muros_divisorios_particiones INTEGER DEFAULT 0,
      muros_divisorios_otro_texto TEXT,
      fachadas_mamposteria INTEGER DEFAULT 0,
      fachadas_tierra INTEGER DEFAULT 0,
      fachadas_paneles INTEGER DEFAULT 0,
      fachadas_flotante INTEGER DEFAULT 0,
      fachadas_otro_texto TEXT,
      escaleras_concreto INTEGER DEFAULT 0,
      escaleras_metalica INTEGER DEFAULT 0,
      escaleras_madera INTEGER DEFAULT 0,
      escaleras_mixtas INTEGER DEFAULT 0,
      escaleras_otro_texto TEXT
    )
    ''');

    // Tabla DetalleEstructura
    await db.execute('''
      CREATE TABLE DetalleEstructura (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        evaluacion_edificio_id INTEGER NOT NULL,
        sistema_estructural_id INTEGER,
        material_id INTEGER,
        otro_sistema TEXT,
        otro_material TEXT,
        sistemas_entrepiso_id INTEGER,
        sistemas_cubierta_id INTEGER,
        elementos_no_estructurales_id INTEGER,
        FOREIGN KEY (evaluacion_edificio_id) REFERENCES EvaluacionEdificio(id),
        FOREIGN KEY (sistema_estructural_id) REFERENCES SistemaEstructural(id),
        FOREIGN KEY (material_id) REFERENCES Materiales(id),
        FOREIGN KEY (sistemas_entrepiso_id) REFERENCES SistemasEntrepiso(id),
        FOREIGN KEY (sistemas_cubierta_id) REFERENCES SistemasCubierta(id),
        FOREIGN KEY (elementos_no_estructurales_id) REFERENCES ElementosNoEstructurales(id)
      )
    ''');

    // Tabla RiesgosExternos
    await db.execute('''
      CREATE TABLE RiesgosExternos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        descripcion TEXT NOT NULL UNIQUE
      )
    ''');

    // Tabla EvaluacionRiesgos (Relación Muchos a Muchos)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS EvaluacionRiesgos (
        evaluacion_id INTEGER NOT NULL,
        riesgo_id INTEGER NOT NULL,
        existe_riesgo INTEGER CHECK(existe_riesgo IN (0,1)) DEFAULT 0,
        compromete_estabilidad INTEGER CHECK(compromete_estabilidad IN (0,1)),
        compromete_accesos INTEGER CHECK(compromete_accesos IN (0,1)),
        PRIMARY KEY (evaluacion_id, riesgo_id),
        FOREIGN KEY (evaluacion_id) REFERENCES Evaluaciones(id),
        FOREIGN KEY (riesgo_id) REFERENCES RiesgosExternos(id)
      )
    ''');

    // Tabla DañosEvaluacion
    await db.execute('''
      CREATE TABLE DañosEvaluacion (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        evaluacion_edificio_id INTEGER NOT NULL,
        porcentaje_afectacion TEXT CHECK(porcentaje_afectacion IN ('Ninguno','<10%','10-40%','40-70%','70%+')),
        colapso_total INTEGER CHECK(colapso_total IN (0,1)),
        colapso_parcial INTEGER CHECK(colapso_parcial IN (0,1)),
        riesgo_caidas INTEGER CHECK(riesgo_caidas IN (0,1)),
        inestabilidad_suelo INTEGER CHECK(inestabilidad_suelo IN (0,1)),
        nivel_dano TEXT CHECK(nivel_dano IN ('Sin Daño', 'Leve', 'Moderado', 'Severo')),
        FOREIGN KEY (evaluacion_edificio_id) REFERENCES EvaluacionEdificio(id)
      )
    ''');

    // Tabla NivelDaño
    await db.execute('''
      CREATE TABLE NivelDaño (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      porcentaje_afectacion TEXT CHECK(porcentaje_afectacion IN ('Ninguno', '<10%', '10-40%', '40-70%', '70%+')),
      severidad_danos TEXT CHECK(severidad_danos IN ('Bajo', 'Medio', 'Alto')),
      categoria TEXT CHECK(categoria IN ('Sin daño','Leve','Moderado','Severo'))
    );
    ''');

    // Tabla EvaluacionNivelDaño (Relación Muchos a Muchos)
    await db.execute('''
      CREATE TABLE EvaluacionNivelDaño (
        evaluacion_id INTEGER NOT NULL,
        nivel_dano_id INTEGER NOT NULL,
        PRIMARY KEY (evaluacion_id, nivel_dano_id),
        FOREIGN KEY (evaluacion_id) REFERENCES Evaluaciones(id),
        FOREIGN KEY (nivel_dano_id) REFERENCES NivelDaño(id)
      )
    ''');

    // Tabla Habitabilidad
    await db.execute('''
      CREATE TABLE Habitabilidad (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        descripcion TEXT CHECK(descripcion IN ('Habitable', 'Acceso Restringido', 'No Habitable')) NOT NULL UNIQUE
      )
    ''');

    // Tabla EvaluacionHabitabilidad
    await db.execute('''
      CREATE TABLE EvaluacionHabitabilidad (
        evaluacion_id INTEGER PRIMARY KEY,
        habitabilidad_id INTEGER NOT NULL,
        FOREIGN KEY (evaluacion_id) REFERENCES Evaluaciones(id),
        FOREIGN KEY (habitabilidad_id) REFERENCES Habitabilidad(id)
      )
    ''');

    // Tabla AccionesRecomendadas
    await db.execute('''
      CREATE TABLE AccionesRecomendadas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        descripcion TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE SistemasEstructurales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        evaluacion_edificio_id INTEGER NOT NULL,
        sistema_estructural TEXT,
        materiales TEXT,
        FOREIGN KEY (evaluacion_edificio_id) REFERENCES EvaluacionEdificio(id)
      )
    ''');

    // Tabla EvaluacionAcciones (Relación Muchos a Muchos)
    await db.execute('''
      CREATE TABLE EvaluacionAcciones (
        evaluacion_id INTEGER NOT NULL,
        accion_recomendada_id INTEGER NOT NULL,
        PRIMARY KEY (evaluacion_id, accion_recomendada_id),
        FOREIGN KEY (evaluacion_id) REFERENCES Evaluaciones(id),
        FOREIGN KEY (accion_recomendada_id) REFERENCES AccionesRecomendadas(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS EvaluacionCondiciones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        evaluacion_edificio_id INTEGER NOT NULL,
        condicion TEXT NOT NULL, -- ej: '5.1', '5.2', etc.
        valor INTEGER CHECK(valor IN (0,1)), -- 0 = No, 1 = Si
        FOREIGN KEY(evaluacion_edificio_id) REFERENCES EvaluacionEdificio(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS EvaluacionElementoDano (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        evaluacion_edificio_id INTEGER NOT NULL,
        elemento TEXT NOT NULL,  -- Ej: '5.7 Muros de carga', '5.8 Sistemas de contención', etc.
        nivel_dano_id INTEGER NOT NULL,
        FOREIGN KEY(evaluacion_edificio_id) REFERENCES EvaluacionEdificio(id),
        FOREIGN KEY(nivel_dano_id) REFERENCES NivelDaño(id)
      )
    ''');

    // Tabla EvaluacionAdicional
    await db.execute('''
      CREATE TABLE EvaluacionAdicional (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        detalle TEXT,
        evaluacion_id INTEGER NOT NULL,
        tipo_evaluacion TEXT CHECK(tipo_evaluacion IN ('Estructural', 'Geotécnica', 'Otro')),
        FOREIGN KEY (evaluacion_id) REFERENCES Evaluaciones(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS EvaluacionSeveridadGlobal (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        evaluacion_id INTEGER NOT NULL,
        severidad_final TEXT CHECK(severidad_final IN ('Sin Daño','Bajo','Medio','Medio Alto','Alto')),
        FOREIGN KEY(evaluacion_id) REFERENCES Evaluaciones(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS AlcanceEvaluacion (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        evaluacion_edificio_id INTEGER NOT NULL,
        exterior TEXT CHECK(exterior IN ('Completa','Parcial','Ninguno')),
        interior TEXT CHECK(interior IN ('No Ingreso','Parcial','Completa','Ninguno')),
        FOREIGN KEY(evaluacion_edificio_id) REFERENCES EvaluacionEdificio(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS EvaluacionAccionDetalle (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        evaluacion_id INTEGER NOT NULL,
        accion_recomendada_id INTEGER NOT NULL,
        detalle TEXT,
        FOREIGN KEY (evaluacion_id) REFERENCES Evaluaciones(id),
        FOREIGN KEY (accion_recomendada_id) REFERENCES AccionesRecomendadas(id)
      )
    ''');

    // Insertar datos iniciales en tablas de referencia (Opcional)
    await _insertInitialData(db);
  }

  Future<Map<String, dynamic>?> getEvaluacionBasica(
      int userId, int evaluacionId) async {
    final db = await database;
    final List<Map<String, dynamic>> evals = await db.rawQuery('''
      SELECT 
        e.*,
        t.descripcion as tipo_evento,
        CASE 
          WHEN t.id = 8 THEN e.otro_tipo_evento || ' (Otro)'
          ELSE t.descripcion 
        END as descripcion_evento
      FROM Evaluaciones e
      LEFT JOIN TipoEventos t ON e.tipo_evento_id = t.id
      WHERE e.id = ? AND e.usuario_id = ?
      LIMIT 1
    ''', [evaluacionId, userId]);

    if (evals.isEmpty) return null;
    return evals.first;
  }

  Future<Map<String, dynamic>?> getEdificacion(
      int userId, int evaluacionId) async {
    final db = await database;

    // Primero, verificar la evaluación
    final evalBasica = await getEvaluacionBasica(userId, evaluacionId);
    if (evalBasica == null) {
      return null;
    }

    // Obtener EvaluacionEdificio
    final List<Map<String, dynamic>> evalEdifList = await db.query(
      'EvaluacionEdificio',
      where: 'evaluacion_id = ?',
      whereArgs: [evaluacionId],
      limit: 1,
    );

    if (evalEdifList.isEmpty) return null;

    final evaluacionEdificio = evalEdifList.first;
    final edificioId = evaluacionEdificio['edificio_id'];

    // Obtener datos del Edificio
    final List<Map<String, dynamic>> edifList = await db.query(
      'Edificios',
      where: 'id = ?',
      whereArgs: [edificioId],
      limit: 1,
    );

    Map<String, dynamic>? edificio;
    if (edifList.isNotEmpty) {
      edificio = edifList.first;
    }

    // Obtener Contacto(s)
    final contacto = await db.query(
      'Contacto',
      where: 'edificio_id = ?',
      whereArgs: [edificioId],
    );

    return {
      'evaluacion_edificio': evaluacionEdificio,
      'edificio': edificio,
      'contacto': contacto,
    };
  }

  Future<Map<String, dynamic>> getCondicionesYElementos(int evaluacionEdificioId) async {
  final db = await database;
  final condiciones = await db.query(
    'EvaluacionCondiciones',
    where: 'evaluacion_edificio_id = ? AND condicion LIKE ?',
    whereArgs: [evaluacionEdificioId, '5.%'],
  );

  final elementos = await db.query(
    'EvaluacionElementoDano',
    where: 'evaluacion_edificio_id = ? AND elemento LIKE ?',
    whereArgs: [evaluacionEdificioId, '5.%'],
  );

  return {
    'condiciones': condiciones,
    'elementos': elementos,
  };
}


  Future<Map<String, dynamic>?> getCaracteristicasGeneralesPorEvaluacion(
      int userId, int evaluacionId) async {
    final db = await database;

    // Verificar evaluación
    final evalBasica = await getEvaluacionBasica(userId, evaluacionId);
    if (evalBasica == null) return null;

    // Obtener EvaluacionEdificio para el evaluacionId
    final List<Map<String, dynamic>> evalEdifList = await db.query(
      'EvaluacionEdificio',
      where: 'evaluacion_id = ?',
      whereArgs: [evaluacionId],
      limit: 1,
    );

    if (evalEdifList.isEmpty) return null;

    final evaluacionEdificioId = evalEdifList.first['id'];

    // Obtener CaracteristicasGenerales
    final List<Map<String, dynamic>> resultados = await db.query(
      'CaracteristicasGenerales',
      where: 'evaluacion_edificio_id = ?',
      whereArgs: [evaluacionEdificioId],
      limit: 1,
    );

    if (resultados.isNotEmpty) {
      return resultados.first;
    }
    return null;
  }

  // Método para obtener las características generales
  Future<Map<String, dynamic>?> obtenerCaracteristicasGenerales(int evaluacionEdificioId) async {
    final db = await database;
    List<Map<String, dynamic>> resultado = await db.query(
      'CaracteristicasGenerales',
      where: 'evaluacion_edificio_id = ?',
      whereArgs: [evaluacionEdificioId],
    );
    if (resultado.isNotEmpty) {
      return resultado.first;
    } else {
      return null;
    }
  }

  // Método para obtener los usos predominantes
  Future<List<Map<String, dynamic>>> obtenerEvaluacionUsos(int evaluacionEdificioId) async {
    final db = await database;
    List<Map<String, dynamic>> resultados = await db.query(
      'EvaluacionUsos',
      where: 'evaluacion_edificio_id = ?',
      whereArgs: [evaluacionEdificioId],
    );
    return resultados;
  }

  Future<List<Map<String, dynamic>>> getUsosPredominantesPorEvaluacion(
      int userId, int evaluacionId) async {
    final db = await database;

    // Verificar evaluación
    final evalBasica = await getEvaluacionBasica(userId, evaluacionId);
    if (evalBasica == null) return [];

    // Obtener evaluacion_edificio_id
    final List<Map<String, dynamic>> evalEdifList = await db.query(
      'EvaluacionEdificio',
      where: 'evaluacion_id = ?',
      whereArgs: [evaluacionId],
      limit: 1,
    );

    if (evalEdifList.isEmpty) return [];

    final evaluacionEdificioId = evalEdifList.first['id'];

    // Obtener Usos
    return await db.rawQuery('''
    SELECT UsosPredominantes.*
    FROM UsosPredominantes
    INNER JOIN EvaluacionUsos ON UsosPredominantes.id = EvaluacionUsos.uso_predominante_id
    WHERE EvaluacionUsos.evaluacion_edificio_id = ?
  ''', [evaluacionEdificioId]);
  }

  Future<Map<String, dynamic>?> getDetalleEstructuraPorEvaluacion(
      int userId, int evaluacionId) async {
    final db = await database;

    final evalBasica = await getEvaluacionBasica(userId, evaluacionId);
    if (evalBasica == null) return null;

    final List<Map<String, dynamic>> evalEdifList = await db.query(
      'EvaluacionEdificio',
      where: 'evaluacion_id = ?',
      whereArgs: [evaluacionId],
      limit: 1,
    );
    if (evalEdifList.isEmpty) return null;
    final evaluacionEdificioId = evalEdifList.first['id'];

    // Obtener DetalleEstructura
    final resultados = await db.query(
      'DetalleEstructura',
      where: 'evaluacion_edificio_id = ?',
      whereArgs: [evaluacionEdificioId],
      limit: 1,
    );

    if (resultados.isNotEmpty) return resultados.first;
    return null;
  }

  Future<Map<String, dynamic>?> getDaniosEvaluacionPorEvaluacion(
      int userId, int evaluacionId) async {
    final db = await database;

    final evalBasica = await getEvaluacionBasica(userId, evaluacionId);
    if (evalBasica == null) return null;

    final List<Map<String, dynamic>> evalEdifList = await db.query(
      'EvaluacionEdificio',
      where: 'evaluacion_id = ?',
      whereArgs: [evaluacionId],
      limit: 1,
    );
    if (evalEdifList.isEmpty) return null;

    final evaluacionEdificioId = evalEdifList.first['id'];

    final resultados = await db.query(
      'DañosEvaluacion',
      where: 'evaluacion_edificio_id = ?',
      whereArgs: [evaluacionEdificioId],
      limit: 1,
    );

    if (resultados.isNotEmpty) return resultados.first;
    return null;
  }

  Future<Map<String, dynamic>?> getHabitabilidadPorEvaluacion(
      int userId, int evaluacionId) async {
    final db = await database;

    // Verificar la evaluación
    final evalBasica = await getEvaluacionBasica(userId, evaluacionId);
    if (evalBasica == null) return null;

    final resultados = await db.query(
      'EvaluacionHabitabilidad',
      where: 'evaluacion_id = ?',
      whereArgs: [evaluacionId],
      limit: 1,
    );

    if (resultados.isEmpty) return null;

    final habId = resultados.first['habitabilidad_id'];
    final habRes = await db.query(
      'Habitabilidad',
      where: 'id = ?',
      whereArgs: [habId],
      limit: 1,
    );
    if (habRes.isNotEmpty) {
      return habRes.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getAccionesRecomendadasPorEvaluacion(
      int userId, int evaluacionId) async {
    final db = await database;

    final evalBasica = await getEvaluacionBasica(userId, evaluacionId);
    if (evalBasica == null) return [];

    return await db.rawQuery('''
    SELECT AccionesRecomendadas.*
    FROM AccionesRecomendadas
    INNER JOIN EvaluacionAcciones ON AccionesRecomendadas.id = EvaluacionAcciones.accion_recomendada_id
    WHERE EvaluacionAcciones.evaluacion_id = ?
  ''', [evaluacionId]);
  }

  Future<List<Map<String, dynamic>>> getRiesgosPorEvaluacion(
      int userId, int evaluacionId) async {
    final db = await database;

    final evalBasica = await getEvaluacionBasica(userId, evaluacionId);
    if (evalBasica == null) return [];

    return await db.rawQuery('''
    SELECT RiesgosExternos.*, EvaluacionRiesgos.compromete_estabilidad, EvaluacionRiesgos.compromete_accesos
    FROM RiesgosExternos
    INNER JOIN EvaluacionRiesgos ON RiesgosExternos.id = EvaluacionRiesgos.riesgo_id
    WHERE EvaluacionRiesgos.evaluacion_id = ?
  ''', [evaluacionId]);
  }

  Future<List<Map<String, dynamic>>> getEvaluacionAdicionalPorEvaluacion(
      int userId, int evaluacionId) async {
    final db = await database;

    final evalBasica = await getEvaluacionBasica(userId, evaluacionId);
    if (evalBasica == null) return [];

    return await db.query(
      'EvaluacionAdicional',
      where: 'evaluacion_id = ?',
      whereArgs: [evaluacionId],
    );
  }

  Future<List<Map<String, dynamic>>> getElementosNoEstructuralesPorEvaluacion(
      int userId, int evaluacionId) async {
    final db = await database;

    final evalBasica = await getEvaluacionBasica(userId, evaluacionId);
    if (evalBasica == null) return [];

    final evalEdifList = await db.query(
      'EvaluacionEdificio',
      where: 'evaluacion_id = ?',
      whereArgs: [evaluacionId],
      limit: 1,
    );
    if (evalEdifList.isEmpty) return [];

    final evaluacionEdificioId = evalEdifList.first['id'];

    return await db.query(
      'ElementosNoEstructurales',
      where: 'evaluacion_edificio_id = ?',
      whereArgs: [evaluacionEdificioId],
    );
  }

  Future<int> insertarOActualizarElementoNoEstructural(
      int evaluacionEdificioId, Map<String, dynamic> datos) async {
    final db = await database;

    // Verificar si ya existe un registro para este evaluacionEdificioId
    final existe = await db.query(
      'ElementosNoEstructurales',
      where: 'evaluacion_edificio_id = ?',
      whereArgs: [evaluacionEdificioId],
      limit: 1,
    );

    if (existe.isEmpty) {
      // Insertar nuevo
      datos['evaluacion_edificio_id'] = evaluacionEdificioId;
      return await db.insert('ElementosNoEstructurales', datos);
    } else {
      // Actualizar existente
      return await db.update(
        'ElementosNoEstructurales',
        datos,
        where: 'evaluacion_edificio_id = ?',
        whereArgs: [evaluacionEdificioId],
      );
    }
  }

  Future<Map<String, dynamic>> obtenerDatosEvaluacion(int evaluacionId) async {
    final db = await database;

    // 1. Obtener la evaluación principal
    final List<Map<String, dynamic>> evals = await db.query(
      'Evaluaciones',
      where: 'id = ?',
      whereArgs: [evaluacionId],
      limit: 1,
    );

    if (evals.isEmpty) {
      return {}; // No se encontró la evaluación
    }

    final evaluacion = evals.first;

    // 2. Obtener EvaluacionEdificio asociado a esta evaluación
    final List<Map<String, dynamic>> evalEdifList = await db.query(
      'EvaluacionEdificio',
      where: 'evaluacion_id = ?',
      whereArgs: [evaluacionId],
      limit: 1,
    );

    Map<String, dynamic>? evaluacionEdificio;
    Map<String, dynamic>? edificio;
    List<Map<String, dynamic>> contacto = [];
    Map<String, dynamic>? caracteristicasGenerales;
    List<Map<String, dynamic>> usosPredominantes = [];
    Map<String, dynamic>? detalleEstructura;
    Map<String, dynamic>? danosEvaluacion;
    Map<String, dynamic>? habitabilidad;
    List<Map<String, dynamic>> accionesRecomendadas = [];
    List<Map<String, dynamic>> riesgosExternos = [];
    List<Map<String, dynamic>> evaluacionAdicional = [];
    List<Map<String, dynamic>> elementosNoEstructurales = [];

    if (evalEdifList.isNotEmpty) {
      evaluacionEdificio = evalEdifList.first;
      int evaluacionEdificioId = evaluacionEdificio['id'];
      int edificioId = evaluacionEdificio['edificio_id'];

      // 3. Obtener datos del Edificio
      final List<Map<String, dynamic>> edifList = await db.query(
        'Edificios',
        where: 'id = ?',
        whereArgs: [edificioId],
        limit: 1,
      );
      if (edifList.isNotEmpty) {
        edificio = edifList.first;
      }

      // 4. Obtener Contacto(s) del edificio
      contacto = await db.query(
        'Contacto',
        where: 'edificio_id = ?',
        whereArgs: [edificioId],
      );

      // 5. Características Generales
      caracteristicasGenerales =
          await obtenerCaracteristicasGenerales(evaluacionEdificioId);

      // 6. Usos Predominantes
      usosPredominantes =
          await obtenerUsosPorEvaluacionEdificio(evaluacionEdificioId);

      // 7. Detalle Estructura
      detalleEstructura = await obtenerDetalleEstructura(evaluacionEdificioId);

      // 8. Daños Evaluacion
      danosEvaluacion = await obtenerDaniosEvaluacion(evaluacionEdificioId);

      // 9. Habitabilidad
      habitabilidad = await obtenerHabitabilidadPorEvaluacion(evaluacionId);

      // 10. Acciones Recomendadas
      accionesRecomendadas = await obtenerAccionesPorEvaluacion(evaluacionId);

      // 11. Riesgos Externos
      riesgosExternos = await obtenerRiesgosPorEvaluacion(evaluacionId);

      // 12. Evaluación Adicional
      evaluacionAdicional = await obtenerEvaluacionAdicional(evaluacionId);

      // 13. Elementos No Estructurales (si quisieras traerlos)
      elementosNoEstructurales = await db.query(
        'ElementosNoEstructurales',
        where: 'evaluacion_edificio_id = ?',
        whereArgs: [evaluacionEdificioId],
      );
    }

    // Combinar todos los datos en un mapa
    Map<String, dynamic> datos = {
      'evaluacion': evaluacion,
      'evaluacion_edificio': evaluacionEdificio,
      'edificio': edificio,
      'contacto': contacto,
      'caracteristicas_generales': caracteristicasGenerales,
      'usos_predominantes': usosPredominantes,
      'detalle_estructura': detalleEstructura,
      'danos_evaluacion': danosEvaluacion,
      'habitabilidad': habitabilidad,
      'acciones_recomendadas': accionesRecomendadas,
      'riesgos_externos': riesgosExternos,
      'evaluacion_adicional': evaluacionAdicional,
      'elementos_no_estructurales': elementosNoEstructurales,
    };

    return datos;
  }

  Future<int?> obtenerIdUsoPorDescripcion(String descripcion) async {
    final db = await database;

    final resultado = await db.query(
      'UsosPredominantes',
      columns: ['id'],
      where: 'descripcion = ?',
      whereArgs: [descripcion],
      limit: 1,
    );
    if (resultado.isNotEmpty) {
      return resultado.first['id'] as int;
    } else {
      return null;
    }
  }

  // Insertar EvaluacionUso
  Future<int> insertarEvaluacionUso(Map<String, dynamic> evaluacionUso) async {
    final db = await database;
    return await db.insert('EvaluacionUsos', evaluacionUso);
  }

  // Agregar Uso a la Evaluación
  Future<void> agregarUsoEvaluacion(int evaluacionEdificioId,
      String usoDescripcion, String fechaConstruccion) async {
    final usoId =
        await obtenerIdUsoPorDescripcion(usoDescripcion.toLowerCase());
    if (usoId == null) {
      // Si no existe, se crea el nuevo uso
      final nuevoId = await insertarUsoPredominante(
          {'descripcion': usoDescripcion.toLowerCase()});
      await insertarEvaluacionUso({
        'evaluacion_edificio_id': evaluacionEdificioId,
        'uso_predominante_id': nuevoId,
        'fecha_construccion': fechaConstruccion,
      });
    } else {
      await insertarEvaluacionUso({
        'evaluacion_edificio_id': evaluacionEdificioId,
        'uso_predominante_id': usoId,
        'fecha_construccion': fechaConstruccion,
      });
    }
  }

  // Migraciones de la base de datos
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Si es necesario agregar nuevas tablas o columnas en futuras versiones
      print('Actualizando base de datos a la versión $newVersion');
      // Ejemplo: agregar una nueva tabla
      // await db.execute('CREATE TABLE NuevaTabla (...)');
    }
    // Agrega más condiciones de actualización según las versiones futuras
  }

  Future<void> deleteDatabaseFile() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'app_database.db');
    print('Eliminando base de datos en: $path');
    await deleteDatabase(path);
    print('Base de datos eliminada exitosamente');
  }

  // Insertar datos iniciales en tablas de referencia
  Future<void> _insertInitialData(Database db) async {
    // Insertar TipoEventos
    List<String> eventos = [
      'Inundación',
      'Deslizamiento',
      'Sismo',
      'Viento',
      'Incendio',
      'Explosión',
      'Estructural',
      'Otro',
    ];
    for (var evento in eventos) {
      await db.insert('TipoEventos', {'descripcion': evento});
    }

    await db.insert('UsosPredominantes', {'descripcion': 'residencial'});
    await db.insert('UsosPredominantes', {'descripcion': 'educativo'});
    await db.insert('UsosPredominantes', {'descripcion': 'comercial'});
    await db.insert('UsosPredominantes', {'descripcion': 'industrial'});
    await db.insert('UsosPredominantes', {'descripcion': 'almacenamiento'});
    await db.insert('UsosPredominantes', {'descripcion': 'reunion'});
    await db.insert('UsosPredominantes', {'descripcion': 'parqueaderos'});
    await db.insert('UsosPredominantes', {'descripcion': 'servicios_publicos'});
    await db.insert('UsosPredominantes', {'descripcion': 'otro'});

    // Insertar RiesgosExternos
    List<String> riesgos = [
      'Caída de objetos',
      'Falla de servicios',
      // Agrega más riesgos según sea necesario
    ];
    for (var riesgo in riesgos) {
      await db.insert('RiesgosExternos', {'descripcion': riesgo});
    }

    // Insertar Habitabilidad
    List<String> habitabilidad = [
      'Habitable',
      'Acceso Restringido',
      'No Habitable',
    ];
    for (var habi in habitabilidad) {
      await db.insert('Habitabilidad', {'descripcion': habi});
    }

    // Insertar AccionesRecomendadas
    List<String> acciones = [
      'Restringir paso',
      'Evacuación',
      'Monitoreo',
      'Otro',
    ];
    for (var accion in acciones) {
      await db.insert('AccionesRecomendadas', {'descripcion': accion});
    }

    // Insertar NivelDaño
    await db.insert('NivelDaño',
        {'porcentaje_afectacion': 'Ninguno', 'severidad_danos': 'Bajo'});
    await db.insert('NivelDaño',
        {'porcentaje_afectacion': '<10%', 'severidad_danos': 'Bajo'});
    await db.insert('NivelDaño',
        {'porcentaje_afectacion': '10-40%', 'severidad_danos': 'Medio'});
    await db.insert('NivelDaño',
        {'porcentaje_afectacion': '40-70%', 'severidad_danos': 'Medio'});
    await db.insert('NivelDaño',
        {'porcentaje_afectacion': '70%+', 'severidad_danos': 'Alto'});
  }

  // --------------------
  // Métodos CRUD para Usuarios
  // --------------------

  // Insertar un nuevo usuario
  Future<int> insertarUsuario(Map<String, dynamic> usuario) async {
    final db = await database;
    return await db.insert('Usuarios', usuario);
  }

  // Obtener un usuario por cédula
  Future<Map<String, dynamic>?> obtenerUsuario(String cedula) async {
    final db = await database;
    List<Map<String, dynamic>> resultados = await db.query(
      'Usuarios',
      where: 'cedula = ?',
      whereArgs: [cedula],
    );
    if (resultados.isNotEmpty) {
      return resultados.first;
    }
    return null;
  }

  // Actualizar usuario
  Future<int> actualizarUsuario(int id, Map<String, dynamic> usuario) async {
    final db = await database;
    return await db.update(
      'Usuarios',
      usuario,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Eliminar usuario
  Future<int> eliminarUsuario(int id) async {
    final db = await database;
    return await db.delete(
      'Usuarios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --------------------
  // Métodos CRUD para TipoEventos
  // --------------------

  // Insertar un nuevo tipo de evento
  Future<int> insertarTipoEvento(Map<String, dynamic> tipoEvento) async {
    final db = await database;
    return await db.insert('TipoEventos', tipoEvento);
  }

  // Obtener todos los tipos de eventos
  Future<List<Map<String, dynamic>>> obtenerTiposEventos() async {
    final db = await database;
    return await db.query('TipoEventos');
  }

  // Actualizar tipo de evento
  Future<int> actualizarTipoEvento(
      int id, Map<String, dynamic> tipoEvento) async {
    final db = await database;
    return await db.update(
      'TipoEventos',
      tipoEvento,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Eliminar tipo de evento
  Future<int> eliminarTipoEvento(int id) async {
    final db = await database;
    return await db.delete(
      'TipoEventos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertarTipoEventoOtro(String descripcion) async {
    final db = await database;
    // Insertar nuevo tipo de evento "Otro" con la descripción específica
    return await db.insert('TipoEventos', {'descripcion': descripcion});
  }

  Future<Map<String, dynamic>?> obtenerTipoEvento(int id) async {
    final db = await database;
    final result = await db.query(
      'TipoEventos',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // --------------------
  // Métodos CRUD para Evaluaciones
  // --------------------

  // Insertar una nueva evaluación
  Future<int> insertarEvaluacion(Map<String, dynamic> evaluacion) async {
    final db = await database;
    return await db.insert('Evaluaciones', evaluacion);
  }

  // Obtener todas las evaluaciones
  Future<List<Map<String, dynamic>>> obtenerEvaluaciones() async {
    final db = await database;
    return await db.rawQuery('''
    SELECT 
      e.*,
      t.descripcion as tipo_evento
    FROM Evaluaciones e
    LEFT JOIN TipoEventos t ON e.tipo_evento_id = t.id
    ORDER BY e.fecha_inspeccion DESC, e.hora DESC
  ''');
  }

  // Actualizar evaluación
  Future<int> actualizarEvaluacion(
      int id, Map<String, dynamic> evaluacion) async {
    final db = await database;
    return await db.update(
      'Evaluaciones',
      evaluacion,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Eliminar evaluación
  Future<int> eliminarEvaluacion(int id) async {
    final db = await database;
    return await db.delete(
      'Evaluaciones',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --------------------
  // Métodos CRUD para Edificios
  // --------------------

  // Insertar un nuevo edificio
  Future<int> insertarEdificio(Map<String, dynamic> edificio) async {
    final db = await database;
    return await db.insert('Edificios', edificio);
  }

  // Obtener todos los edificios
  Future<List<Map<String, dynamic>>> obtenerEdificios() async {
    final db = await database;
    return await db.query('Edificios');
  }

  // Actualizar edificio
  Future<int> actualizarEdificio(int id, Map<String, dynamic> edificio) async {
    final db = await database;
    return await db.update(
      'Edificios',
      edificio,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Eliminar edificio
  Future<int> eliminarEdificio(int id) async {
    final db = await database;
    return await db.delete(
      'Edificios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --------------------
  // Métodos CRUD para Contacto
  // --------------------

  // Insertar un nuevo contacto
  Future<int> insertarContacto(Map<String, dynamic> contacto) async {
    final db = await database;
    return await db.insert('Contacto', contacto);
  }

  // Obtener contactos por edificio_id
  Future<List<Map<String, dynamic>>> obtenerContactosPorEdificio(
      int edificioId) async {
    final db = await database;
    return await db.query(
      'Contacto',
      where: 'edificio_id = ?',
      whereArgs: [edificioId],
    );
  }

  // Actualizar contacto
  Future<int> actualizarContacto(int id, Map<String, dynamic> contacto) async {
    final db = await database;
    return await db.update(
      'Contacto',
      contacto,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Eliminar contacto
  Future<int> eliminarContacto(int id) async {
    final db = await database;
    return await db.delete(
      'Contacto',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --------------------
  // Métodos CRUD para EvaluacionEdificio
  // --------------------

  // Insertar una nueva EvaluacionEdificio
  Future<int> insertarEvaluacionEdificio(
      Map<String, dynamic> evaluacionEdificio) async {
    final db = await database;
    return await db.insert('EvaluacionEdificio', evaluacionEdificio);
  }

  // Obtener EvaluacionEdificio por evaluacion_id
  Future<List<Map<String, dynamic>>> obtenerEvaluacionEdificioPorEvaluacion(
      int evaluacionId) async {
    final db = await database;
    return await db.query(
      'EvaluacionEdificio',
      where: 'evaluacion_id = ?',
      whereArgs: [evaluacionId],
    );
  }

  // Actualizar EvaluacionEdificio
  Future<int> actualizarEvaluacionEdificio(
      int id, Map<String, dynamic> evaluacionEdificio) async {
    final db = await database;
    return await db.update(
      'EvaluacionEdificio',
      evaluacionEdificio,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Eliminar EvaluacionEdificio
  Future<int> eliminarEvaluacionEdificio(int id) async {
    final db = await database;
    return await db.delete(
      'EvaluacionEdificio',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --------------------
  // Métodos CRUD para CaracteristicasGenerales
  // --------------------

  // Insertar una nueva CaracteristicasGenerales
  Future<int> insertarCaracteristicasGenerales(
      Map<String, dynamic> caracteristicas) async {
    final db = await database;
    return await db.insert('CaracteristicasGenerales', caracteristicas);
  }

  // Actualizar CaracteristicasGenerales
  Future<int> actualizarCaracteristicasGenerales(
      int id, Map<String, dynamic> caracteristicas) async {
    final db = await database;
    return await db.update(
      'CaracteristicasGenerales',
      caracteristicas,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Eliminar CaracteristicasGenerales
  Future<int> eliminarCaracteristicasGenerales(int id) async {
    final db = await database;
    return await db.delete(
      'CaracteristicasGenerales',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --------------------
  // Métodos CRUD para UsosPredominantes
  // --------------------

  // Insertar un nuevo UsoPredominante
  Future<int> insertarUsoPredominante(Map<String, dynamic> uso) async {
    final db = await database;
    return await db.insert('UsosPredominantes', uso);
  }

  // Obtener todos los UsosPredominantes
  Future<List<Map<String, dynamic>>> obtenerUsosPredominantes() async {
    final db = await database;
    return await db.query('UsosPredominantes');
  }

  // --------------------
  // Métodos CRUD para EvaluacionUsos
  // --------------------

  // Obtener UsosPredominantes por evaluacion_edificio_id
  Future<List<Map<String, dynamic>>> obtenerUsosPorEvaluacionEdificio(
      int evaluacionEdificioId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT UsosPredominantes.*
      FROM UsosPredominantes
      INNER JOIN EvaluacionUsos ON UsosPredominantes.id = EvaluacionUsos.uso_predominante_id
      WHERE EvaluacionUsos.evaluacion_edificio_id = ?
    ''', [evaluacionEdificioId]);
  }

  // --------------------
  // Métodos CRUD para SistemaEstructural
  // --------------------

  // Insertar un nuevo SistemaEstructural
  Future<int> insertarSistemaEstructural(Map<String, dynamic> sistema) async {
    final db = await database;
    return await db.insert('SistemaEstructural', sistema);
  }

  Future<void> insertarSistemaEstructuralMaterial(
      Map<String, dynamic> datosSistema) async {
    final db = await database;

    // Insertar en la tabla SistemasEstructurales
    await db.insert('SistemasEstructurales', {
      'evaluacion_edificio_id': datosSistema['evaluacion_edificio_id'],
      'sistema_estructural': datosSistema['sistema_estructural'],
      'materiales': datosSistema['materiales'],
    });
  }

  // Obtener todos los SistemasEstructurales
  Future<List<Map<String, dynamic>>> obtenerSistemasEstructurales() async {
    final db = await database;
    return await db.query('SistemaEstructural');
  }

  // --------------------
  // Métodos CRUD para Materiales
  // --------------------

  // Insertar un nuevo Material
  Future<int> insertarMaterial(Map<String, dynamic> material) async {
    final db = await database;
    return await db.insert('Materiales', material);
  }

  // Obtener todos los Materiales
  Future<List<Map<String, dynamic>>> obtenerMateriales() async {
    final db = await database;
    return await db.query('Materiales');
  }

  // --------------------
  // Métodos CRUD para SistemasEntrepiso
  // --------------------

  // Insertar un nuevo SistemaEntrepiso
  Future<int> insertarSistemaEntrepiso(
      Map<String, dynamic> sistemaEntrepiso) async {
    final db = await database;
    return await db.insert('SistemasEntrepiso', sistemaEntrepiso);
  }

  // Obtener todos los SistemasEntrepiso
  Future<List<Map<String, dynamic>>> obtenerSistemasEntrepiso() async {
    final db = await database;
    return await db.query('SistemasEntrepiso');
  }

  // --------------------
  // Métodos CRUD para SistemasCubierta
  // --------------------

  // Insertar una nueva SistemaCubierta
  Future<int> insertarSistemaCubierta(
      Map<String, dynamic> sistemaCubierta) async {
    final db = await database;
    return await db.insert('SistemasCubierta', sistemaCubierta);
  }

  // Obtener todos los SistemasCubierta
  Future<List<Map<String, dynamic>>> obtenerSistemasCubierta() async {
    final db = await database;
    return await db.query('SistemasCubierta');
  }

  // --------------------
  // Métodos CRUD para ElementosNoEstructurales
  // --------------------

  // Insertar un nuevo ElementoNoEstructural
  Future<int> insertarElementoNoEstructural(
      Map<String, dynamic> elemento) async {
    final db = await database;
    return await db.insert('ElementosNoEstructurales', elemento);
  }

  // Obtener todos los ElementosNoEstructurales
  Future<List<Map<String, dynamic>>> obtenerElementosNoEstructurales() async {
    final db = await database;
    return await db.query('ElementosNoEstructurales');
  }

  // --------------------
  // Métodos CRUD para DetalleEstructura
  // --------------------

  // Insertar un nuevo DetalleEstructura
  Future<int> insertarDetalleEstructura(Map<String, dynamic> detalle) async {
    final db = await database;
    return await db.insert('DetalleEstructura', detalle);
  }

  // Obtener DetalleEstructura por evaluacion_edificio_id
  Future<Map<String, dynamic>?> obtenerDetalleEstructura(
      int evaluacionEdificioId) async {
    final db = await database;
    List<Map<String, dynamic>> resultados = await db.query(
      'DetalleEstructura',
      where: 'evaluacion_edificio_id = ?',
      whereArgs: [evaluacionEdificioId],
    );
    if (resultados.isNotEmpty) {
      return resultados.first;
    }
    return null;
  }

  // Actualizar DetalleEstructura
  Future<int> actualizarDetalleEstructura(
      int id, Map<String, dynamic> detalle) async {
    final db = await database;
    return await db.update(
      'DetalleEstructura',
      detalle,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Eliminar DetalleEstructura
  Future<int> eliminarDetalleEstructura(int id) async {
    final db = await database;
    return await db.delete(
      'DetalleEstructura',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --------------------
  // Métodos CRUD para RiesgosExternos
  // --------------------

  // Insertar un nuevo RiesgoExterno
  Future<int> insertarRiesgoExterno(Map<String, dynamic> riesgo) async {
    final db = await database;
    return await db.insert('RiesgosExternos', riesgo);
  }

  // Obtener todos los RiesgosExternos
  Future<List<Map<String, dynamic>>> obtenerRiesgosExternos() async {
    final db = await database;
    return await db.query('RiesgosExternos');
  }

  // Actualizar RiesgoExterno
  Future<int> actualizarRiesgoExterno(
      int id, Map<String, dynamic> riesgo) async {
    final db = await database;
    return await db.update(
      'RiesgosExternos',
      riesgo,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Eliminar RiesgoExterno
  Future<int> eliminarRiesgoExterno(int id) async {
    final db = await database;
    return await db.delete(
      'RiesgosExternos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --------------------
  // Métodos CRUD para EvaluacionRiesgos
  // --------------------

  // Ejemplo de método para insertar en EvaluacionRiesgos
  Future<void> insertarEvaluacionRiesgo(Map<String, dynamic> datos) async {
    final db = await database;
    await db.insert(
      'EvaluacionRiesgos',
      datos,
      conflictAlgorithm: ConflictAlgorithm.replace, // Opcional según tu lógica
    );
  }
  // Obtener Riesgos por evaluacion_id
  Future<List<Map<String, dynamic>>> obtenerRiesgosPorEvaluacion(
      int evaluacionId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT RiesgosExternos.*, EvaluacionRiesgos.compromete_estabilidad, EvaluacionRiesgos.compromete_accesos
      FROM RiesgosExternos
      INNER JOIN EvaluacionRiesgos ON RiesgosExternos.id = EvaluacionRiesgos.riesgo_id
      WHERE EvaluacionRiesgos.evaluacion_id = ?
    ''', [evaluacionId]);
  }

  // --------------------
  // Métodos CRUD para DañosEvaluacion
  // --------------------

  // Insertar una nueva DañosEvaluacion
  Future<int> insertarDaniosEvaluacion(Map<String, dynamic> danios) async {
    final db = await database;
    return await db.insert('DañosEvaluacion', danios);
  }

  // Obtener DañosEvaluacion por evaluacion_edificio_id
  Future<Map<String, dynamic>?> obtenerDaniosEvaluacion(
      int evaluacionEdificioId) async {
    final db = await database;
    List<Map<String, dynamic>> resultados = await db.query(
      'DañosEvaluacion',
      where: 'evaluacion_edificio_id = ?',
      whereArgs: [evaluacionEdificioId],
    );
    if (resultados.isNotEmpty) {
      return resultados.first;
    }
    return null;
  }

  // Actualizar DañosEvaluacion
  Future<int> actualizarDaniosEvaluacion(
      int id, Map<String, dynamic> danios) async {
    final db = await database;
    return await db.update(
      'DañosEvaluacion',
      danios,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Eliminar DañosEvaluacion
  Future<int> eliminarDaniosEvaluacion(int id) async {
    final db = await database;
    return await db.delete(
      'DañosEvaluacion',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --------------------
  // Métodos CRUD para NivelDaño
  // --------------------

  // Insertar un nuevo NivelDaño
  Future<int> insertarNivelDanio(Map<String, dynamic> nivelDanio) async {
    final db = await database;
    return await db.insert('NivelDaño', nivelDanio);
  }

  // Obtener todos los NivelDaño
  Future<List<Map<String, dynamic>>> obtenerNivelDanio() async {
    final db = await database;
    return await db.query('NivelDaño');
  }

  // --------------------
  // Métodos CRUD para EvaluacionNivelDaño
  // --------------------

  // Insertar una nueva EvaluacionNivelDanio
  Future<int> insertarEvaluacionNivelDanio(
      Map<String, dynamic> evaluacionNivelDanio) async {
    final db = await database;
    return await db.insert('EvaluacionNivelDaño', evaluacionNivelDanio);
  }

  // Obtener NivelDaño por evaluacion_id
  Future<List<Map<String, dynamic>>> obtenerNivelDanioPorEvaluacion(
      int evaluacionId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT NivelDaño.*
      FROM NivelDaño
      INNER JOIN EvaluacionNivelDaño ON NivelDaño.id = EvaluacionNivelDaño.nivel_dano_id
      WHERE EvaluacionNivelDaño.evaluacion_id = ?
    ''', [evaluacionId]);
  }

  // --------------------
  // Métodos CRUD para Habitabilidad
  // --------------------

  // Insertar una nueva Habitabilidad
  Future<int> insertarHabitabilidad(Map<String, dynamic> habitabilidad) async {
    final db = await database;
    return await db.insert('Habitabilidad', habitabilidad);
  }

  // Obtener todas las Habitabilidad
  Future<List<Map<String, dynamic>>> obtenerHabitabilidad() async {
    final db = await database;
    return await db.query('Habitabilidad');
  }

  // --------------------
  // Métodos CRUD para EvaluacionHabitabilidad
  // --------------------

  // Insertar una nueva EvaluacionHabitabilidad
  Future<int> insertarEvaluacionHabitabilidad(
      Map<String, dynamic> evaluacionHabitabilidad) async {
    final db = await database;
    return await db.insert('EvaluacionHabitabilidad', evaluacionHabitabilidad);
  }

  // Obtener Habitabilidad por evaluacion_id
  Future<Map<String, dynamic>?> obtenerHabitabilidadPorEvaluacion(
      int evaluacionId) async {
    final db = await database;
    List<Map<String, dynamic>> resultados = await db.query(
      'EvaluacionHabitabilidad',
      where: 'evaluacion_id = ?',
      whereArgs: [evaluacionId],
    );
    if (resultados.isNotEmpty) {
      return resultados.first;
    }
    return null;
  }

  // Actualizar EvaluacionHabitabilidad
  Future<int> actualizarEvaluacionHabitabilidad(
      int evaluacionId, Map<String, dynamic> evaluacionHabitabilidad) async {
    final db = await database;
    return await db.update(
      'EvaluacionHabitabilidad',
      evaluacionHabitabilidad,
      where: 'evaluacion_id = ?',
      whereArgs: [evaluacionId],
    );
  }

  Future<void> insertarOActualizarEvaluacionCondicion(int evaluacionEdificioId, String condicion, int valor) async {
  final db = await database;

  // Verificar si ya existe el registro
  final existe = await db.query(
    'EvaluacionCondiciones',
    where: 'evaluacion_edificio_id = ? AND condicion = ?',
    whereArgs: [evaluacionEdificioId, condicion],
    limit: 1,
  );

  if (existe.isEmpty) {
    // Insertar nuevo
    await db.insert('EvaluacionCondiciones', {
      'evaluacion_edificio_id': evaluacionEdificioId,
      'condicion': condicion,
      'valor': valor,
    });
  } else {
    // Actualizar existente
    await db.update('EvaluacionCondiciones', {
      'valor': valor,
    },
    where: 'evaluacion_edificio_id = ? AND condicion = ?',
    whereArgs: [evaluacionEdificioId, condicion]);
  }
}

Future<void> insertarOActualizarEvaluacionElementoDano(int evaluacionEdificioId, String elemento, int nivelDanoId) async {
  final db = await database;

  // Verificar si ya existe el registro
  final existe = await db.query(
    'EvaluacionElementoDano',
    where: 'evaluacion_edificio_id = ? AND elemento = ?',
    whereArgs: [evaluacionEdificioId, elemento],
    limit: 1,
  );

  if (existe.isEmpty) {
    await db.insert('EvaluacionElementoDano', {
      'evaluacion_edificio_id': evaluacionEdificioId,
      'elemento': elemento,
      'nivel_dano_id': nivelDanoId,
    });
  } else {
    await db.update('EvaluacionElementoDano', {
      'nivel_dano_id': nivelDanoId,
    },
    where: 'evaluacion_edificio_id = ? AND elemento = ?',
    whereArgs: [evaluacionEdificioId, elemento]);
  }
}

  Future<void> eliminarEvaluacionRiesgosPorEvaluacion(int evaluacionId) async {
    final db = await database;
    await db.delete(
      'EvaluacionRiesgos',
      where: 'evaluacion_id = ?',
      whereArgs: [evaluacionId],
    );
  }

  // Eliminar EvaluacionHabitabilidad
  Future<int> eliminarEvaluacionHabitabilidad(int evaluacionId) async {
    final db = await database;
    return await db.delete(
      'EvaluacionHabitabilidad',
      where: 'evaluacion_id = ?',
      whereArgs: [evaluacionId],
    );
  }

  // --------------------
  // Métodos CRUD para AccionesRecomendadas
  // --------------------


  // Insertar una nueva AccionRecomendada
  Future<int> insertarAccionRecomendada(Map<String, dynamic> accion) async {
    final db = await database;
    return await db.insert('AccionesRecomendadas', accion);
  }

  // Obtener todas las AccionesRecomendadas
  Future<List<Map<String, dynamic>>> obtenerAccionesRecomendadas() async {
    final db = await database;
    return await db.query('AccionesRecomendadas');
  }

  // --------------------
  // Métodos CRUD para EvaluacionAcciones
  // --------------------

  // Insertar una nueva EvaluacionAccion
  Future<int> insertarEvaluacionAccion(
      Map<String, dynamic> evaluacionAccion) async {
    final db = await database;
    return await db.insert('EvaluacionAcciones', evaluacionAccion);
  }

  // Obtener AccionesRecomendadas por evaluacion_id
  Future<List<Map<String, dynamic>>> obtenerAccionesPorEvaluacion(
      int evaluacionId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT AccionesRecomendadas.*
      FROM AccionesRecomendadas
      INNER JOIN EvaluacionAcciones ON AccionesRecomendadas.id = EvaluacionAcciones.accion_recomendada_id
      WHERE EvaluacionAcciones.evaluacion_id = ?
    ''', [evaluacionId]);
  }

  // --------------------
  // Métodos CRUD para EvaluacionAdicional
  // --------------------

  // Insertar una nueva EvaluacionAdicional
  Future<int> insertarEvaluacionAdicional(
      Map<String, dynamic> evaluacionAdicional) async {
    final db = await database;
    return await db.insert('EvaluacionAdicional', evaluacionAdicional);
  }

  // Obtener EvaluacionAdicional por evaluacion_id
  Future<List<Map<String, dynamic>>> obtenerEvaluacionAdicional(
      int evaluacionId) async {
    final db = await database;
    return await db.query(
      'EvaluacionAdicional',
      where: 'evaluacion_id = ?',
      whereArgs: [evaluacionId],
    );
  }

  // Actualizar EvaluacionAdicional
  Future<int> actualizarEvaluacionAdicional(
      int id, Map<String, dynamic> evaluacionAdicional) async {
    final db = await database;
    return await db.update(
      'EvaluacionAdicional',
      evaluacionAdicional,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Eliminar EvaluacionAdicional
  Future<int> eliminarEvaluacionAdicional(int id) async {
    final db = await database;
    return await db.delete(
      'EvaluacionAdicional',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --------------------
  // Métodos CRUD para Habitabilidad
  // --------------------
  // Ya implementados arriba

  // --------------------
  // Métodos CRUD para DetalleEstructura y demás tablas
  // --------------------
  // Similar al patrón de los anteriores métodos CRUD

  Future<void> insertarAlcanceEvaluacion(Map<String, dynamic> datos) async {
    final db = await database;

    await db.insert(
      'AlcanceEvaluacion',
      datos,
      conflictAlgorithm: ConflictAlgorithm.replace, // Reemplaza si existe
    );
  }

  // Cierra la base de datos
  Future<void> cerrarBaseDeDatos() async {
    final db = await database;
    db.close();
  }

  // Agregar este método para insertar evaluaciones de prueba
  Future<void> insertarEvaluacionesPrueba() async {
    final db = await database;

    // Inserta tipos de eventos si no existen
    List<Map<String, dynamic>> tiposEventos = [
      {'id': 1, 'descripcion': 'Tipo 1'},
      {'id': 2, 'descripcion': 'Tipo 2'},
      {'id': 3, 'descripcion': 'Tipo 3'},
      {'id': 4, 'descripcion': 'Tipo 4'},
      {'id': 5, 'descripcion': 'Tipo 5'},
    ];
    for (var tipo in tiposEventos) {
      await db.insert('TipoEventos', tipo,
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // Lista de evaluaciones de prueba
    List<Map<String, dynamic>> evaluaciones = [
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

    for (var evaluacion in evaluaciones) {
      await db.insert('Evaluaciones', evaluacion,
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  /// Inserta una nueva evaluación con firma en la base de datos.
  ///
  /// [evaluacion] debe ser un mapa que contenga las claves correspondientes a las columnas de la tabla Evaluaciones,
  /// incluyendo el campo 'firma' como List<int> (bytes del archivo).
  Future<int> insertEvaluacionConFirma(Map<String, dynamic> evaluacion) async {
    final db = await database;
    return await db.insert(
      'Evaluaciones',
      evaluacion,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Actualiza la firma de una evaluación existente.
  ///
  /// [id] es el ID de la evaluación que se actualizará.
  /// [firma] es la firma en formato de bytes (List<int>).
  Future<int> updateFirmaEvaluacion(int id, List<int> firma) async {
    final db = await database;
    return await db.update(
      'Evaluaciones',
      {'firma': firma},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Recupera la firma de una evaluación específica.
  ///
  /// [id] es el ID de la evaluación de la cual se desea obtener la firma.
  /// Retorna un List<int> con los bytes de la firma o null si no se encuentra.
  Future<List<int>?> getFirmaEvaluacion(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Evaluaciones',
      columns: ['firma'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return maps.first['firma'] as List<int>?;
    } else {
      return null;
    }
  }

  // Agregar este nuevo método
  Future<int> insertarIdentificacionEdificacion({
    required int evaluacionId,
    required Map<String, dynamic> datosGenerales,
    required Map<String, dynamic> datosCatastrales,
    required Map<String, dynamic> datosContacto,
  }) async {
    final db = await database;

    /// 1. Insertar edificio - Corregir nombre de columna
    final edificioId = await db.insert('Edificios', {
      'nombre_edificacion': datosGenerales['nombre_edificacion'],
      'municipio': datosGenerales['municipio'],
      'comuna': datosGenerales['comuna'], // Agregar comuna
      'barrio_vereda': datosGenerales['barrio_vereda'],
      'tipo_propiedad': datosGenerales['tipo_propiedad'],
      'departamento': datosGenerales['departamento'],
      'tipo_via': datosGenerales['tipo_via'],
      'numero_via': datosGenerales['numero_via'],
      'apendice_via': datosGenerales['apendice_via'],
      'orientacion': datosGenerales['orientacion'],
      'numero_cruce': datosGenerales['numero_cruce'],
      'orientacion_cruce': datosGenerales['orientacion_cruce'],
      'complemento_direccion': datosGenerales['complemento_direccion'],
    });

    // 2. Insertar evaluación edificio
    final evaluacionEdificioId = await db.insert('EvaluacionEdificio', {
      'evaluacion_id': evaluacionId,
      'edificio_id': edificioId,
      'codigo_medellin': datosCatastrales['codigo_medellin'],
      'codigo_area_metropolitana':
          datosCatastrales['codigo_area_metropolitana'],
      'latitud': datosCatastrales['latitud'],
      'longitud': datosCatastrales['longitud'],
    });

    // 3. Insertar contacto
    await db.insert('Contacto', {
      'edificio_id': edificioId,
      'nombre': datosContacto['nombre'],
      'telefono': datosContacto['telefono'],
      'correo_electronico': datosContacto['correo'],
      'tipo_persona': datosContacto['tipo_persona'],
    });

    return evaluacionEdificioId;
  }

  /// Inserta una evaluación con firma utilizando datos separados.
  ///
  /// [eventoId], [usuarioId], [fechaInspeccion], [hora], [dependenciaEntidad],
  /// [idGrupo], [tipoEventoId], y [firma] son los datos de la evaluación.
  Future<int> insertEvaluacion({
    required int eventoId,
    required int usuarioId,
    required String fechaInspeccion,
    required String hora,
    String? dependenciaEntidad,
    String? idGrupo,
    required int tipoEventoId,
    required List<int> firma, // Firma como bytes
  }) async {
    final db = await database;
    Map<String, dynamic> evaluacion = {
      'eventoId': eventoId,
      'usuario_id': usuarioId,
      'fecha_inspeccion': fechaInspeccion,
      'hora': hora,
      'dependencia_entidad': dependenciaEntidad,
      'id_grupo': idGrupo,
      'tipo_evento_id': tipoEventoId,
      'firma': firma,
    };

    return await db.insert(
      'Evaluaciones',
      evaluacion,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Método existente para loguear usuarios (puedes personalizarlo según necesidades)
  Future<void> logUsuarios() async {
    final db = await database;
    final List<Map<String, dynamic>> usuarios = await db.query('Usuarios');

    if (usuarios.isNotEmpty) {
      print('--- Usuarios en la Base de Datos ---');
      for (var usuario in usuarios) {
        print('Cédula: ${usuario['cedula']}, Pwd: ${usuario['pwd']}');
      }
      print('-----------------------------------');
    } else {
      print('No hay usuarios en la base de datos.');
    }
  }

  // ... Puedes añadir más métodos según las necesidades de tu aplicación ...

  Future<void> insertarDatosSeccion3() async {
    final db = await database;

    // 3.2 Usos Predominantes
    await db.insert('UsosPredominantes', {'descripcion': 'Residencial'});
    await db.insert('UsosPredominantes', {'descripcion': 'Educativo'});
    await db.insert('UsosPredominantes', {'descripcion': 'Institucional'});
    await db.insert('UsosPredominantes', {'descripcion': 'Industrial'});
    await db.insert('UsosPredominantes', {'descripcion': 'Comercial'});
    await db.insert('UsosPredominantes', {'descripcion': 'Oficina'});
    await db.insert('UsosPredominantes', {'descripcion': 'Salud'});
    await db.insert('UsosPredominantes', {'descripcion': 'Seguridad'});
    await db.insert('UsosPredominantes', {'descripcion': 'Almacenamiento'});
    await db.insert('UsosPredominantes', {'descripcion': 'Reunión'});
    await db.insert('UsosPredominantes', {'descripcion': 'Parqueaderos'});
    await db.insert('UsosPredominantes', {'descripcion': 'Servicios Públicos'});

    // 3.3.1 Sistema Estructural
    await db.insert('SistemaEstructural', {'descripcion': 'Muros de carga'});
    await db.insert('SistemaEstructural', {'descripcion': 'Pórticos'});
    await db.insert('SistemaEstructural', {'descripcion': 'Combinado'});
    await db.insert('SistemaEstructural', {'descripcion': 'Dual'});
    await db.insert('SistemaEstructural', {'descripcion': 'No es claro'});

    // 3.3.2 Materiales
    await db.insert('Materiales', {'descripcion': 'Mampostería simple'});
    await db.insert('Materiales', {'descripcion': 'Mampostería confinada'});
    await db.insert('Materiales', {'descripcion': 'Mampostería reforzada'});
    await db
        .insert('Materiales', {'descripcion': 'Mampostería semi-confinada'});
    await db.insert('Materiales', {'descripcion': 'Mampostería en adobe'});
    await db.insert('Materiales', {'descripcion': 'Madera'});
    await db.insert('Materiales', {'descripcion': 'Guadua'});
    await db.insert('Materiales', {'descripcion': 'Bahareque'});
    await db.insert('Materiales', {'descripcion': 'Tierra o tapia pisada'});
    await db.insert('Materiales', {'descripcion': 'Concreto prefabricado'});
    await db.insert('Materiales', {'descripcion': 'Concreto no arriostrado'});
    await db.insert('Materiales', {'descripcion': 'Concreto arriostrado'});
    await db.insert('Materiales', {'descripcion': 'Acero no arriostrado'});
    await db.insert('Materiales', {'descripcion': 'Acero arriostrado'});

    // 3.4 Sistemas de Entrepiso
    await db.insert('SistemasEntrepiso', {'descripcion': 'Losa maciza'});
    await db.insert('SistemasEntrepiso', {'descripcion': 'Vigas de acero'});
    await db.insert('SistemasEntrepiso', {'descripcion': 'Vigas de madera'});
    await db.insert('SistemasEntrepiso', {'descripcion': 'Viguetas'});
    await db.insert('SistemasEntrepiso', {'descripcion': 'Cerchas'});
    await db.insert('SistemasEntrepiso', {'descripcion': 'Viga con tabla'});
    await db.insert('SistemasEntrepiso', {'descripcion': 'Loseta'});

    // 3.5.1 Sistema de Soporte de Cubierta
    await db.insert('TipoSoporteCubierta', {'descripcion': 'Vigas de madera'});
    await db.insert('TipoSoporteCubierta', {'descripcion': 'Vigas de acero'});
    await db
        .insert('TipoSoporteCubierta', {'descripcion': 'Vigas de concreto'});
    await db
        .insert('TipoSoporteCubierta', {'descripcion': 'Cerchas de madera'});
    await db
        .insert('TipoSoporteCubierta', {'descripcion': 'Cerchas metálicas'});

    // 3.5.2 Revestimiento de Cubierta
    await db.insert('RevestimientoCubierta', {'descripcion': 'Teja de zinc'});
    await db.insert('RevestimientoCubierta', {'descripcion': 'Teja de barro'});
    await db.insert(
        'RevestimientoCubierta', {'descripcion': 'Teja de asbesto cemento'});
    await db.insert('RevestimientoCubierta', {'descripcion': 'Teja plástica'});
    await db
        .insert('RevestimientoCubierta', {'descripcion': 'Losa de concreto'});

    // 3.6.1 Muros Divisorios
    await db.insert('MurosDivisorios', {'descripcion': 'Mampostería'});
    await db.insert('MurosDivisorios', {'descripcion': 'Tierra'});
    await db.insert('MurosDivisorios', {'descripcion': 'Bahareque'});
    await db.insert('MurosDivisorios', {'descripcion': 'Particiones livianas'});

    // 3.6.2 Fachadas
    await db.insert('Fachadas', {'descripcion': 'Mampostería'});
    await db.insert('Fachadas', {'descripcion': 'Paneles'});
    await db.insert('Fachadas', {'descripcion': 'Vidrio'});
    await db.insert('Fachadas', {'descripcion': 'Madera'});

    // 3.6.3 Escaleras
    await db.insert('Escaleras', {'descripcion': 'Concreto'});
    await db.insert('Escaleras', {'descripcion': 'Metálica'});
    await db.insert('Escaleras', {'descripcion': 'Madera'});
    await db.insert('Escaleras', {'descripcion': 'Mixta'});
  }
}
