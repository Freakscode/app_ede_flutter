// lib/providers/ede_provider.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/identificacion_evaluacion.dart';
import 'identificacion_edificacion.dart';

class EDEProvider with ChangeNotifier {
  // Estado existente
  IdentificacionEvaluacion _identificacionEvaluacion = IdentificacionEvaluacion(
    fecha: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    hora: DateFormat('HH:mm').format(DateTime.now()),
    nombreEvaluador: '',
    dependenciaEntidad: '',
    idGrupo: '',
    eventoId: null,
    firmaPath: '',
    tipoEventoId: null,
    otroEvento: '',
  );

  // Nuevo estado para Identificación Edificación
  IdentificacionEdificacion _identificacionEdificacion = IdentificacionEdificacion();

  // Getters
  IdentificacionEvaluacion get identificacionEvaluacion => _identificacionEvaluacion;
  IdentificacionEdificacion get identificacionEdificacion => _identificacionEdificacion;

  // Métodos existentes
  void updateIdentificacionEvaluacion(IdentificacionEvaluacion newData) {
    _identificacionEvaluacion = newData;
    notifyListeners();
  }

  // Nuevos métodos para Identificación Edificación
  void updateIdentificacionEdificacion(IdentificacionEdificacion newData) {
    _identificacionEdificacion = newData;
    notifyListeners();
  }

  // Métodos específicos para cada sección
  void updateDatosGenerales({
    String? nombreEdificacion,
    String? municipio,
    String? barrioVereda,
    String? comuna,
    String? tipoPropiedad,
    String? departamento,
  }) {
    _identificacionEdificacion = _identificacionEdificacion.copyWith(
      nombreEdificacion: nombreEdificacion,
      municipio: municipio,
      barrioVereda: barrioVereda,
      comuna: comuna,
      tipoPropiedad: tipoPropiedad,
      departamento: departamento,
    );
    notifyListeners();
  }

  void updateDireccion({
    String? tipoVia,
    String? numeroVia,
    String? apendiceVia,
    String? orientacion,
    String? numeroCruce,
    String? orientacionCruce,
    String? numero,
    String? complementoDireccion,
  }) {
    _identificacionEdificacion = _identificacionEdificacion.copyWith(
      tipoVia: tipoVia,
      numeroVia: numeroVia,
      apendiceVia: apendiceVia,
      orientacion: orientacion,
      numeroCruce: numeroCruce,
      orientacionCruce: orientacionCruce,
      numero: numero,
      complementoDireccion: complementoDireccion,
    );
    notifyListeners();
  }

  void updateIdentificacionCatastral({
    String? codigoMedellin,
    String? codigoAreaMetropolitana,
    double? latitud,
    double? longitud,
  }) {
    _identificacionEdificacion = _identificacionEdificacion.copyWith(
      codigoMedellin: codigoMedellin,
      codigoAreaMetropolitana: codigoAreaMetropolitana,
      latitud: latitud,
      longitud: longitud,
    );
    notifyListeners();
  }

  void updatePersonaContacto({
    String? nombreContacto,
    String? telefono,
    String? correo,
    String? tipoPersona,
  }) {
    _identificacionEdificacion = _identificacionEdificacion.copyWith(
      nombreContacto: nombreContacto,
      telefono: telefono,
      correo: correo,
      tipoPersona: tipoPersona,
    );
    notifyListeners();
  }

  // Método para reiniciar datos
  void resetIdentificacionEdificacion() {
    _identificacionEdificacion = IdentificacionEdificacion();
    notifyListeners();
  }

  // Método para cargar datos existentes
  void loadIdentificacionEdificacion(Map<String, dynamic> data) {
    _identificacionEdificacion = IdentificacionEdificacion.fromMap(data);
    notifyListeners();
  }

  // Método para limpiar todos los datos si es necesario
  void clearAllData() {
    _identificacionEvaluacion = IdentificacionEvaluacion(
      fecha: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      hora: DateFormat('HH:mm').format(DateTime.now()),
      nombreEvaluador: '',
      dependenciaEntidad: '',
      idGrupo: '',
      eventoId: null,
      firmaPath: '',
      tipoEventoId: null,
      otroEvento: '',
    );
    _identificacionEdificacion = IdentificacionEdificacion();
    notifyListeners();
  }

  // Métodos para mapear datos si es necesario
  Map<String, dynamic> toMap() {
    return {
      'identificacionEvaluacion': _identificacionEvaluacion.toMap(),
      'identificacionEdificacion': _identificacionEdificacion.toMap(),
    };
  }

  void fromMap(Map<String, dynamic> map) {
    if (map['identificacionEvaluacion'] != null) {
      _identificacionEvaluacion = IdentificacionEvaluacion.fromMap(map['identificacionEvaluacion']);
    }
    if (map['identificacionEdificacion'] != null) {
      _identificacionEdificacion = IdentificacionEdificacion.fromMap(map['identificacionEdificacion']);
    }
    notifyListeners();
  }
}
