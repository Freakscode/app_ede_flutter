class TempIdentificacionEvaluacion {
  String fecha;
  String hora;
  String? nombreEvaluador;
  String? dependenciaEntidad;
  String? idGrupo;
  int? eventoId;
  String? firmaPath;
  int? tipoEventoId;
  String? otroEvento;

  TempIdentificacionEvaluacion({
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

  // Convertir a Map
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

  // Crear desde Map
  static TempIdentificacionEvaluacion fromMap(Map<String, dynamic> map) {
    return TempIdentificacionEvaluacion(
      fecha: map['fecha'] ?? '',
      hora: map['hora'] ?? '',
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