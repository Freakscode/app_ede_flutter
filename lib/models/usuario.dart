class Usuario {
  final int id;
  final String cedula;
  final String nombre;
  final String pwd;
  final String dependenciaEntidad;
  final String fechaRegistro;

  Usuario({
    required this.id,
    required this.cedula,
    required this.nombre,
    required this.pwd,
    required this.dependenciaEntidad,
    required this.fechaRegistro,
  });

  Map<String, dynamic> toMap() {
    return {
      'cedula': cedula,
      'nombre': nombre,
      'pwd': pwd,
      'dependencia_entidad': dependenciaEntidad,
      'fecha_registro': fechaRegistro,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      cedula: map['cedula'],
      nombre: map['nombre'],
      pwd: map['pwd'],
      dependenciaEntidad: map['dependencia_entidad'],
      fechaRegistro: map['fecha_registro'],
    );
  }
}