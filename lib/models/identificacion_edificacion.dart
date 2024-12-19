class IdentificacionEdificacion {
  // Datos Generales
  String? nombreEdificacion;
  String? municipio;
  String? barrioVereda;
  String? comuna;
  String? tipoPropiedad;
  String? departamento;

  // Dirección
  String? tipoVia;
  String? numeroVia;
  String? apendiceVia;
  String? orientacion;
  String? numeroCruce;
  String? orientacionCruce;
  String? numero;
  String? complementoDireccion;

  // Identificación Catastral
  String? codigoMedellin;
  String? codigoAreaMetropolitana;
  double? latitud;
  double? longitud;

  // Persona Contacto
  String? nombreContacto;
  String? telefono;
  String? correo;
  String? tipoPersona;

  IdentificacionEdificacion({
    // Datos Generales
    this.nombreEdificacion,
    this.municipio,
    this.barrioVereda,
    this.comuna,
    this.tipoPropiedad,
    this.departamento,
    
    // Dirección
    this.tipoVia,
    this.numeroVia,
    this.apendiceVia,
    this.orientacion,
    this.numeroCruce,
    this.orientacionCruce,
    this.numero,
    this.complementoDireccion,
    
    // Identificación Catastral
    this.codigoMedellin,
    this.codigoAreaMetropolitana,
    this.latitud,
    this.longitud,
    
    // Persona Contacto
    this.nombreContacto,
    this.telefono,
    this.correo,
    this.tipoPersona,
  });

  // Método para crear una copia del objeto con campos actualizados
  IdentificacionEdificacion copyWith({
    String? nombreEdificacion,
    String? municipio,
    String? barrioVereda,
    String? comuna,
    String? tipoPropiedad,
    String? departamento,
    String? tipoVia,
    String? numeroVia,
    String? apendiceVia,
    String? orientacion,
    String? numeroCruce,
    String? orientacionCruce,
    String? numero,
    String? complementoDireccion,
    String? codigoMedellin,
    String? codigoAreaMetropolitana,
    double? latitud,
    double? longitud,
    String? nombreContacto,
    String? telefono,
    String? correo,
    String? tipoPersona,
  }) {
    return IdentificacionEdificacion(
      nombreEdificacion: nombreEdificacion ?? this.nombreEdificacion,
      municipio: municipio ?? this.municipio,
      barrioVereda: barrioVereda ?? this.barrioVereda,
      comuna: comuna ?? this.comuna,
      tipoPropiedad: tipoPropiedad ?? this.tipoPropiedad,
      departamento: departamento ?? this.departamento,
      tipoVia: tipoVia ?? this.tipoVia,
      numeroVia: numeroVia ?? this.numeroVia,
      apendiceVia: apendiceVia ?? this.apendiceVia,
      orientacion: orientacion ?? this.orientacion,
      numeroCruce: numeroCruce ?? this.numeroCruce,
      orientacionCruce: orientacionCruce ?? this.orientacionCruce,
      numero: numero ?? this.numero,
      complementoDireccion: complementoDireccion ?? this.complementoDireccion,
      codigoMedellin: codigoMedellin ?? this.codigoMedellin,
      codigoAreaMetropolitana: codigoAreaMetropolitana ?? this.codigoAreaMetropolitana,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      nombreContacto: nombreContacto ?? this.nombreContacto,
      telefono: telefono ?? this.telefono,
      correo: correo ?? this.correo,
      tipoPersona: tipoPersona ?? this.tipoPersona,
    );
  }

  // Convertir a Map
  Map<String, dynamic> toMap() {
    return {
      'nombreEdificacion': nombreEdificacion,
      'municipio': municipio,
      'barrioVereda': barrioVereda,
      'comuna': comuna,
      'tipoPropiedad': tipoPropiedad,
      'departamento': departamento,
      'tipoVia': tipoVia,
      'numeroVia': numeroVia,
      'apendiceVia': apendiceVia,
      'orientacion': orientacion,
      'numeroCruce': numeroCruce,
      'orientacionCruce': orientacionCruce,
      'numero': numero,
      'complementoDireccion': complementoDireccion,
      'codigoMedellin': codigoMedellin,
      'codigoAreaMetropolitana': codigoAreaMetropolitana,
      'latitud': latitud,
      'longitud': longitud,
      'nombreContacto': nombreContacto,
      'telefono': telefono,
      'correo': correo,
      'tipoPersona': tipoPersona,
    };
  }

  // Crear desde Map
  factory IdentificacionEdificacion.fromMap(Map<String, dynamic> map) {
    return IdentificacionEdificacion(
      nombreEdificacion: map['nombreEdificacion'],
      municipio: map['municipio'],
      barrioVereda: map['barrioVereda'],
      comuna: map['comuna'],
      tipoPropiedad: map['tipoPropiedad'],
      departamento: map['departamento'],
      tipoVia: map['tipoVia'],
      numeroVia: map['numeroVia'],
      apendiceVia: map['apendiceVia'],
      orientacion: map['orientacion'],
      numeroCruce: map['numeroCruce'],
      orientacionCruce: map['orientacionCruce'],
      numero: map['numero'],
      complementoDireccion: map['complementoDireccion'],
      codigoMedellin: map['codigoMedellin'],
      codigoAreaMetropolitana: map['codigoAreaMetropolitana'],
      latitud: map['latitud'],
      longitud: map['longitud'],
      nombreContacto: map['nombreContacto'],
      telefono: map['telefono'],
      correo: map['correo'],
      tipoPersona: map['tipoPersona'],
    );
  }

  // Métodos auxiliares para validación
  bool get isDatosGeneralesCompletos {
    return nombreEdificacion?.isNotEmpty == true &&
           municipio?.isNotEmpty == true &&
           barrioVereda?.isNotEmpty == true &&
           tipoPropiedad?.isNotEmpty == true;
  }

  bool get isDireccionCompleta {
    return tipoVia?.isNotEmpty == true &&
           numeroVia?.isNotEmpty == true &&
           numeroCruce?.isNotEmpty == true &&
           numero?.isNotEmpty == true;
  }

  bool get isDatosCatastralesCompletos {
    return (codigoMedellin?.isNotEmpty == true || 
            codigoAreaMetropolitana?.isNotEmpty == true) &&
           latitud != null &&
           longitud != null;
  }

  bool get isContactoCompleto {
    return nombreContacto?.isNotEmpty == true &&
           telefono?.isNotEmpty == true &&
           correo?.isNotEmpty == true &&
           tipoPersona?.isNotEmpty == true;
  }
}