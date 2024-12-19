class Comentario {
  final int id;
  final int usuarioId;
  final int evaluacionId;
  final String nombreSeccion;
  String? texto;
  final String fecha;
  final List<ComentarioRecurso> recursos;

  Comentario({
    required this.id,
    required this.usuarioId,
    required this.evaluacionId,
    required this.nombreSeccion,
    this.texto,
    required this.fecha,
    required this.recursos,
  });

  factory Comentario.fromMap(Map<String, dynamic> map, List<ComentarioRecurso> recursos) {
    return Comentario(
      id: map['id'],
      usuarioId: map['usuario_id'],
      evaluacionId: map['evaluacion_id'],
      nombreSeccion: map['nombre_seccion'],
      texto: map['texto'],
      fecha: map['fecha'] ?? DateTime.now().toIso8601String(),
      recursos: recursos,
    );
  }
}

class ComentarioRecurso {
  final int id;
  final int comentarioId;
  final String tipo;
  final String pathArchivo;

  ComentarioRecurso({
    required this.id,
    required this.comentarioId,
    required this.tipo,
    required this.pathArchivo,
  });

  factory ComentarioRecurso.fromMap(Map<String, dynamic> map) {
    return ComentarioRecurso(
      id: map['id'],
      comentarioId: map['comentario_id'],
      tipo: map['tipo'],
      pathArchivo: map['path_archivo'],
    );
  }
}