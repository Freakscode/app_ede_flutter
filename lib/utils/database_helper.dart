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
        FOREIGN KEY (usuario_id) REFERENCES Usuarios(id),
        FOREIGN KEY (tipo_evento_id) REFERENCES TipoEventos(id)
      )
    ''');

    // Tabla Edificios
    await db.execute('''
      CREATE TABLE Edificios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        municipio TEXT NOT NULL,
        barrio_vereda TEXT,
        direccion TEXT,
        tipo_propiedad TEXT CHECK(tipo_propiedad IN ('Pública', 'Privada'))
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
        latitud REAL,
        longitud REAL,
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

    // Tabla SistemasCubierta
    await db.execute('''
      CREATE TABLE SistemasCubierta (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo_soporte TEXT,
        revestimiento TEXT
      )
    ''');

    // Tabla ElementosNoEstructurales
    await db.execute('''
      CREATE TABLE ElementosNoEstructurales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        muros_divisorios TEXT,
        fachadas TEXT,
        escaleras TEXT
      )
    ''');

    // Tabla DetalleEstructura
    await db.execute('''
      CREATE TABLE DetalleEstructura (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        evaluacion_edificio_id INTEGER NOT NULL,
        sistema_estructural_id INTEGER,
        material_id INTEGER,
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
      CREATE TABLE EvaluacionRiesgos (
        evaluacion_id INTEGER NOT NULL,
        riesgo_id INTEGER NOT NULL,
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
        severidad_danos TEXT CHECK(severidad_danos IN ('Bajo', 'Medio', 'Alto'))
      )
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

    // Tabla EvaluacionAdicional
    await db.execute('''
      CREATE TABLE EvaluacionAdicional (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        evaluacion_id INTEGER NOT NULL,
        tipo_evaluacion TEXT CHECK(tipo_evaluacion IN ('Estructural', 'Geotécnica', 'Otro')),
        FOREIGN KEY (evaluacion_id) REFERENCES Evaluaciones(id)
      )
    ''');

    // Insertar datos iniciales en tablas de referencia (Opcional)
    await _insertInitialData(db);
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

    // Insertar UsosPredominantes
    List<String> usos = [
      'Residencial',
      'Educativo',
      'Industrial',
      'Comercial',
      'Otro',
    ];
    for (var uso in usos) {
      await db.insert('UsosPredominantes', {'descripcion': uso});
    }

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

  // Obtener CaracteristicasGenerales por evaluacion_edificio_id
  Future<Map<String, dynamic>?> obtenerCaracteristicasGenerales(
      int evaluacionEdificioId) async {
    final db = await database;
    List<Map<String, dynamic>> resultados = await db.query(
      'CaracteristicasGenerales',
      where: 'evaluacion_edificio_id = ?',
      whereArgs: [evaluacionEdificioId],
    );
    if (resultados.isNotEmpty) {
      return resultados.first;
    }
    return null;
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

  // Insertar una nueva EvaluacionUso
  Future<int> insertarEvaluacionUso(Map<String, dynamic> evaluacionUso) async {
    final db = await database;
    return await db.insert('EvaluacionUsos', evaluacionUso);
  }

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

  // Insertar una nueva EvaluacionRiesgo
  Future<int> insertarEvaluacionRiesgo(
      Map<String, dynamic> evaluacionRiesgo) async {
    final db = await database;
    return await db.insert('EvaluacionRiesgos', evaluacionRiesgo);
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

  // --------------------
  // Otros métodos que necesites agregar
  // --------------------

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

    // 1. Insertar edificio
    final edificioId = await db.insert('Edificios', {
      'nombre': datosGenerales['nombre_edificacion'],
      'municipio': datosGenerales['municipio'],
      'barrio_vereda': datosGenerales['barrio_vereda'],
      'direccion': datosGenerales['direccion'],
      'tipo_propiedad': datosGenerales['tipo_propiedad'],
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
}
