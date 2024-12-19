// lib/models/identificacion_evaluacion.dart

class IdentificacionEvaluacion {
  String fecha;
  String hora;
  String? nombreEvaluador;
  String? dependenciaEntidad;
  String? idGrupo;
  int? eventoId;
  String? firmaPath;
  int? tipoEventoId;
  String? otroEvento;

  IdentificacionEvaluacion({
    required this.fecha,
    required this.hora,
    this.nombreEvaluador,
    this.dependenciaEntidad,
    this.idGrupo,
    this.eventoId,
    this.firmaPath,
    this.tipoEventoId,
    this.otroEvento,
  });

  // Métodos para copiar y mapear datos
  IdentificacionEvaluacion copyWith({
    String? fecha,
    String? hora,
    String? nombreEvaluador,
    String? dependenciaEntidad,
    String? idGrupo,
    int? eventoId,
    String? firmaPath,
    int? tipoEventoId,
    String? otroEvento,
  }) {
    return IdentificacionEvaluacion(
      fecha: fecha ?? this.fecha,
      hora: hora ?? this.hora,
      nombreEvaluador: nombreEvaluador ?? this.nombreEvaluador,
      dependenciaEntidad: dependenciaEntidad ?? this.dependenciaEntidad,
      idGrupo: idGrupo ?? this.idGrupo,
      eventoId: eventoId ?? this.eventoId,
      firmaPath: firmaPath ?? this.firmaPath,
      tipoEventoId: tipoEventoId ?? this.tipoEventoId,
      otroEvento: otroEvento ?? this.otroEvento,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fecha': fecha,
      'hora': hora,
      'nombreEvaluador': nombreEvaluador,
      'dependenciaEntidad': dependenciaEntidad,
      'idGrupo': idGrupo,
      'eventoId': eventoId,
      'firmaPath': firmaPath,
      'tipoEventoId': tipoEventoId,
      'otroEvento': otroEvento,
    };
  }

  factory IdentificacionEvaluacion.fromMap(Map<String, dynamic> map) {
    return IdentificacionEvaluacion(
      fecha: map['fecha'],
      hora: map['hora'],
      nombreEvaluador: map['nombreEvaluador'],
      dependenciaEntidad: map['dependenciaEntidad'],
      idGrupo: map['idGrupo'],
      eventoId: map['eventoId'],
      firmaPath: map['firmaPath'],
      tipoEventoId: map['tipoEventoId'],
      otroEvento: map['otroEvento'],
    );
  }
}
