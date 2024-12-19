class TempIdentificacionEdificacion {
  // Datos Generales
  String? nombreEdificacion;
  String? municipio;
  String? barrioVereda;
  String? tipoPropiedad;
  String? comuna;
  String? departamento;

  // Dirección
  String? tipoVia;
  String? numeroVia;
  String? apendiceVia;
  String? orientacion;
  String? numeroCruce;
  String? numero;
  String? orientacionCruce;
  String? complemento;

  // Identificación Catastral
  String? codigoMedellin;
  String? codigoAreaMetropolitana;
  double? latitud;
  double? longitud;

  // Persona de Contacto
  String? nombreContacto;
  String? telefono;
  String? correo;
  String? tipoPersona;

  TempIdentificacionEdificacion({
    this.nombreEdificacion,
    this.municipio,
    this.barrioVereda,
    this.tipoPropiedad,
    this.comuna,
    this.departamento,
    this.tipoVia,
    this.numeroVia,
    this.apendiceVia,
    this.orientacion,
    this.numeroCruce,
    this.orientacionCruce,
    this.complemento,
    this.numero,
    this.codigoMedellin,
    this.codigoAreaMetropolitana,
    this.latitud,
    this.longitud,
    this.nombreContacto,
    this.telefono,
    this.correo,
    this.tipoPersona,
  });

  Map<String, dynamic> toMap() {
    return {
      'datosGenerales': {
        'nombre_edificacion': nombreEdificacion,
        'municipio': municipio,
        'comuna': comuna,
        'barrio_vereda': barrioVereda,
        'tipo_propiedad': tipoPropiedad,
        'departamento': departamento,
      },
      'direccion': {
        'tipo_via': tipoVia,
        'numero_via': numeroVia,
        'apendice_via': apendiceVia,
        'orientacion': orientacion,
        'numero_cruce': numeroCruce,
        'numero': numero,
        'orientacion_cruce': orientacionCruce,
        'complemento': complemento,
      },
      'datosCatastrales': {
        'codigo_medellin': codigoMedellin,
        'codigo_area_metropolitana': codigoAreaMetropolitana,
        'latitud': latitud,
        'longitud': longitud,
      },
      'datosContacto': {
        'nombre': nombreContacto,
        'telefono': telefono,
        'correo': correo,
        'tipo_persona': tipoPersona,
      },
    };
  }

  static TempIdentificacionEdificacion fromMap(Map<String, dynamic> map) {
    final datosGenerales = map['datosGenerales'] as Map<String, dynamic>;
    final direccion = map['direccion'] as Map<String, dynamic>;
    final datosCatastrales = map['datosCatastrales'] as Map<String, dynamic>;
    final datosContacto = map['datosContacto'] as Map<String, dynamic>;

    return TempIdentificacionEdificacion(
      // Datos Generales
      nombreEdificacion: datosGenerales['nombre_edificacion'],
      municipio: datosGenerales['municipio'],
      comuna: datosGenerales['comuna'],
      barrioVereda: datosGenerales['barrio_vereda'],
      tipoPropiedad: datosGenerales['tipo_propiedad'],
      departamento: datosGenerales['departamento'],
      
      // Dirección
      tipoVia: direccion['tipo_via'],
      numeroVia: direccion['numero_via'],
      apendiceVia: direccion['apendice_via'],
      orientacion: direccion['orientacion'],
      numeroCruce: direccion['numero_cruce'],
      numero: direccion['numero'],
      orientacionCruce: direccion['orientacion_cruce'],
      complemento: direccion['complemento'],
      
      // Datos Catastrales
      codigoMedellin: datosCatastrales['codigo_medellin'],
      codigoAreaMetropolitana: datosCatastrales['codigo_area_metropolitana'],
      latitud: datosCatastrales['latitud'],
      longitud: datosCatastrales['longitud'],
      
      // Datos de Contacto
      nombreContacto: datosContacto['nombre'],
      telefono: datosContacto['telefono'],
      correo: datosContacto['correo'],
      tipoPersona: datosContacto['tipo_persona'],
    );
  }

  bool validarDatosGenerales() {
    return nombreEdificacion?.isNotEmpty == true &&
           municipio?.isNotEmpty == true &&
           barrioVereda?.isNotEmpty == true &&
           tipoPropiedad?.isNotEmpty == true;
  }

  bool validarDireccion() {
    return tipoVia?.isNotEmpty == true &&
           numeroVia?.isNotEmpty == true &&
           numeroCruce?.isNotEmpty == true &&
           numero?.isNotEmpty == true;
  }

  bool validarDatosCatastrales() {
    return codigoMedellin?.isNotEmpty == true &&
           codigoAreaMetropolitana?.isNotEmpty == true &&
           latitud != null &&
           longitud != null;
  }

  bool validarDatosContacto() {
    return nombreContacto?.isNotEmpty == true &&
           telefono?.isNotEmpty == true;
  }

  TempIdentificacionEdificacion copyWith({
    String? nombreEdificacion,
    String? municipio,
    String? barrioVereda,
    String? tipoPropiedad,
    String? comuna,
    String? departamento,
    String? tipoVia,
    String? numeroVia,
    String? apendiceVia,
    String? orientacion,
    String? numeroCruce,
    String? numero,
    String? orientacionCruce,
    String? complemento,
    String? codigoMedellin,
    String? codigoAreaMetropolitana,
    double? latitud,
    double? longitud,
    String? nombreContacto,
    String? telefono,
    String? correo,
    String? tipoPersona,
  }) {
    return TempIdentificacionEdificacion(
      nombreEdificacion: nombreEdificacion ?? this.nombreEdificacion,
      municipio: municipio ?? this.municipio,
      barrioVereda: barrioVereda ?? this.barrioVereda,
      tipoPropiedad: tipoPropiedad ?? this.tipoPropiedad,
      comuna: comuna ?? this.comuna,
      departamento: departamento ?? this.departamento,
      tipoVia: tipoVia ?? this.tipoVia,
      numeroVia: numeroVia ?? this.numeroVia,
      apendiceVia: apendiceVia ?? this.apendiceVia,
      orientacion: orientacion ?? this.orientacion,
      numeroCruce: numeroCruce ?? this.numeroCruce,
      numero: numero ?? this.numero,
      orientacionCruce: orientacionCruce ?? this.orientacionCruce,
      complemento: complemento ?? this.complemento,
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

  String construirDireccionCompleta() {
    final List<String> partesDireccion = [];
  
    // Tipo de vía y número de vía
    if (tipoVia != null) partesDireccion.add(tipoVia!);
    if (numeroVia != null) partesDireccion.add(numeroVia!);
    if (apendiceVia != null) partesDireccion.add(apendiceVia!);
    if (orientacion != null) partesDireccion.add(orientacion!);
    
    // Número de cruce y su orientación
    if (numeroCruce != null) {
      partesDireccion.add("#");
      partesDireccion.add(numeroCruce!);
      if (orientacionCruce != null) {
        partesDireccion.add(orientacionCruce!);
      }
    }
  
    // Número específico de la edificación
    if (numero != null) {
      partesDireccion.add("-");
      partesDireccion.add(numero!);
    }
  
    // Complemento adicional
    if (complemento != null) {
      partesDireccion.add("($complemento)");
    }
  
    return partesDireccion.join(" ");
  }
}