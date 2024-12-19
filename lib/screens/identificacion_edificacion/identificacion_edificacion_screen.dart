// lib/screens/identificacion_edificacion/identificacion_edificacion_screen.dart

// ignore_for_file: unused_import, library_private_types_in_public_api, unused_local_variable, unused_element

import 'package:flutter/material.dart';
import 'datos_generales_subseccion.dart';
import 'identificacion_catastral_subseccion.dart';
import 'persona_contacto_subseccion.dart';
import 'direccion_subseccion.dart';
import '../../utils/database_helper.dart';
import '../../widgets/floating_navigation_menu.dart'; // Importar el menú flotante

class IdentificacionEdificacionScreen extends StatefulWidget {
  final int evaluacionId;
  final int userId;

  const IdentificacionEdificacionScreen({
    Key? key,
    required this.evaluacionId,
    required this.userId,
  }) : super(key: key);

  @override
  _IdentificacionEdificacionScreenState createState() =>
      _IdentificacionEdificacionScreenState();
}

class _IdentificacionEdificacionScreenState
    extends State<IdentificacionEdificacionScreen> {
  int _currentIndex = 0;

  // Controladores para Datos Generales
  final TextEditingController _nombreEdificacionController =
      TextEditingController();
  final TextEditingController _municipioController = TextEditingController();
  final TextEditingController _barrioVeredaController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _tipoPropiedadController =
      TextEditingController();

  // Nuevos controladores para dirección
  final TextEditingController _departamentoController = TextEditingController();
  final TextEditingController _tipoViaController = TextEditingController();
  final TextEditingController _numeroViaController = TextEditingController();
  final TextEditingController _apendiceViaController = TextEditingController();
  final TextEditingController _orientacionController = TextEditingController();
  final TextEditingController _numeroCruceController = TextEditingController();
  final TextEditingController _orientacionCruceController =
      TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _complementoController = TextEditingController();
  final TextEditingController _comunaController = TextEditingController();

  // Controladores para Identificación Catastral
  final TextEditingController _medellinController = TextEditingController();
  final TextEditingController _areaMetropolitanaController =
      TextEditingController();
  final TextEditingController _latitudController = TextEditingController();
  final TextEditingController _longitudController = TextEditingController();

  // Controladores para Persona de Contacto
  final TextEditingController _nombreContactoController =
      TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _tipoPersonaController = TextEditingController();

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onSectionSelected(int section) {
    setState(() {
      _currentIndex = section - 1; // Asumiendo que las secciones empiezan en 1
    });
  }

  @override
  void dispose() {
    // Dispose de todos los controladores
    // Controladores Datos Generales
    _nombreEdificacionController.dispose();
    _municipioController.dispose();
    _barrioVeredaController.dispose();
    _direccionController.dispose();
    _tipoPropiedadController.dispose();

    // Nuevos controladores para dirección
    _departamentoController.dispose();
    _tipoViaController.dispose();
    _numeroViaController.dispose();
    _apendiceViaController.dispose();
    _orientacionController.dispose();
    _numeroCruceController.dispose();
    _orientacionCruceController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _comunaController.dispose();

    // Controles para Identificación Catastral
    _medellinController.dispose();
    _areaMetropolitanaController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();

    // Controles para Persona de Contacto
    _nombreContactoController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    _tipoPersonaController.dispose();

    // Llamar al dispose del padre
    super.dispose();
  }

  String _construirDireccionCompleta() {
    final List<String> partesDireccion = [];

    // Tipo de vía y número
    if (_tipoViaController.text.isNotEmpty) {
      partesDireccion.add(_tipoViaController.text);
    }
    if (_numeroViaController.text.isNotEmpty) {
      partesDireccion.add(_numeroViaController.text);
    }
    if (_apendiceViaController.text.isNotEmpty) {
      partesDireccion.add(_apendiceViaController.text);
    }

    // Orientación
    if (_orientacionController.text.isNotEmpty) {
      partesDireccion.add(_orientacionController.text);
    }

    // Número de cruce y su orientación
    if (_numeroCruceController.text.isNotEmpty) {
      partesDireccion.add("#");
      partesDireccion.add(_numeroCruceController.text);
      if (_orientacionCruceController.text.isNotEmpty) {
        partesDireccion.add(_orientacionCruceController.text);
      }
    }

    // Complemento
    if (_complementoController.text.isNotEmpty) {
      partesDireccion.add("(${_complementoController.text})");
    }

    return partesDireccion.join(" ");
  }

  final Map<String, List<Map<String, dynamic>>> secciones = {
    'IDENTIFICACIÓN DE EVALUACIÓN': [
      {
        'id': 1,
        'title': 'Datos Generales',
        'route': '/identificacion_evaluacion',
        'args': {}
      },
      {
        'id': 2,
        'title': 'Tipo de Evento',
        'route': '/identificacion_evaluacion',
        'args': {'tipo': 'evento'}
      },
    ],
    'IDENTIFICACIÓN DE LA EDIFICACIÓN': [
      {
        'id': 3,
        'title': 'Datos Generales',
        'route': '/identificacion_edificacion',
        'args': {}
      },
      {
        'id': 4,
        'title': 'Identificación Catastral (CBML) y Localización',
        'route': '/identificacion_edificacion',
        'args': {'tipo': 'catastral'}
      },
      {
        'id': 5,
        'title': 'Persona de Contacto',
        'route': '/identificacion_edificacion',
        'args': {'tipo': 'contacto'}
      },
    ],
    'DESCRIPCIÓN DE LA EDIFICACIÓN': [
      {
        'id': 6,
        'title': 'Características Generales',
        'route': '/descripcion_edificacion',
        'args': {}
      },
      {
        'id': 7,
        'title': 'Usos Predominantes',
        'route': '/descripcion_edificacion',
        'args': {'tipo': 'usos'}
      },
      {
        'id': 8,
        'title': 'Sistema Estructural y Material',
        'route': '/descripcion_edificacion',
        'args': {'tipo': 'sistema_estructural'}
      },
      {
        'id': 9,
        'title': 'Sistema de Entrepiso',
        'route': '/descripcion_edificacion',
        'args': {'tipo': 'entrepiso'}
      },
      {
        'id': 10,
        'title': 'Sistema de Cubierta',
        'route': '/descripcion_edificacion',
        'args': {'tipo': 'cubierta'}
      },
      {
        'id': 11,
        'title': 'Elementos no Estructurales Adicionales',
        'route': '/descripcion_edificacion',
        'args': {'tipo': 'elementos_no_estructurales'}
      },
    ],
    'IDENTIFICACIÓN DE RIESGOS EXTERNOS': [
      {
        'id': 12,
        'title': 'Riesgo Externo',
        'route': '/identificacion_riesgos_externos',
        'args': {}
      },
      {
        'id': 13,
        'title': 'Compromete Acceso',
        'route': '/identificacion_riesgos_externos',
        'args': {'tipo': 'acceso'}
      },
      {
        'id': 14,
        'title': 'Compromete Estabilidad',
        'route': '/identificacion_riesgos_externos',
        'args': {'tipo': 'estabilidad'}
      },
    ],
    'EVALUACIÓN DE DAÑOS EN LA EDIFICACIÓN': [
      {
        'id': 15,
        'title': 'Determinar existencia de condiciones',
        'route': '/evaluacion_danos',
        'args': {}
      },
      {
        'id': 16,
        'title': 'Establecer nivel de daño',
        'route': '/evaluacion_danos',
        'args': {'tipo': 'nivel_dano'}
      },
    ],
    'ALCANCE DE LA EVALUACIÓN REALIZADA': [
      {
        'id': 17,
        'title': 'Evaluación Interior/Exterior',
        'route': '/alcance_evaluacion',
        'args': {}
      },
    ],
    'HABITABILIDAD DE LA EDIFICACIÓN': [
      {
        'id': 18,
        'title': 'Evaluación de Habitabilidad',
        'route': '/habitabilidad',
        'args': {}
      },
    ],
    'ACCIONES RECOMENDADAS': [
      {
        'id': 19,
        'title': 'Evaluación Adicional',
        'route': '/acciones_recomendadas',
        'args': {}
      },
      {
        'id': 20,
        'title': 'Recomendaciones y Medidas',
        'route': '/acciones_recomendadas',
        'args': {'tipo': 'medidas'}
      },
    ],
  };

  Future<void> _guardarYContinuar() async {
    try {
      // Validar datos generales
      if (_nombreEdificacionController.text.isEmpty ||
          _municipioController.text.isEmpty ||
          _barrioVeredaController.text.isEmpty ||
          _tipoPropiedadController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complete todos los datos generales')),
        );
        setState(() => _currentIndex = 0);
        return;
      }

      // Validar datos de dirección obligatorios
      if (_tipoViaController.text.isEmpty ||
          _numeroViaController.text.isEmpty ||
          _numeroCruceController.text.isEmpty ||
          _numeroController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Complete los datos obligatorios de la dirección')),
        );
        setState(() => _currentIndex = 1);
        return;
      }

      // Preparar datos generales (sin incluir datos de dirección)
      final datosGenerales = {
        'nombre_edificacion': _nombreEdificacionController.text,
        'municipio': _municipioController.text,
        'comuna': _comunaController.text,
        'barrio_vereda': _barrioVeredaController.text,
        'tipo_propiedad': _tipoPropiedadController.text,
        'departamento': _departamentoController.text,
      };

      // Preparar datos de dirección
      final datosDireccion = obtenerDatosDireccion();

      // Preparar datos catastrales
      final datosCatastrales = {
        'codigo_medellin': _medellinController.text,
        'codigo_area_metropolitana': _areaMetropolitanaController.text,
        'latitud': double.parse(_latitudController.text),
        'longitud': double.parse(_longitudController.text),
      };

      // Preparar datos de contacto
      final datosContacto = {
        'nombre': _nombreContactoController.text,
        'telefono': _telefonoController.text,
        'correo': _correoController.text,
        'tipo_persona': _tipoPersonaController.text,
      };

      // Llamar al método de inserción con los nuevos parámetros
      final evaluacionEdificioId =
          await DatabaseHelper().insertarIdentificacionEdificacion(
        evaluacionId: widget.evaluacionId,
        datosGenerales: datosGenerales,
        datosDireccion: datosDireccion,
        datosCatastrales: datosCatastrales,
        datosContacto: datosContacto,
      );

      // Navegar a la siguiente pantalla o mostrar mensaje si es necesario
      // ...
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  // Agregar método para obtener datos de dirección
  Map<String, dynamic> obtenerDatosDireccion() {
    return {
      'tipo_via': _tipoViaController.text,
      'numero_via': _numeroViaController.text,
      'apendice_via': _apendiceViaController.text,
      'orientacion': _orientacionController.text,
      'numero_cruce': _numeroCruceController.text,
      'orientacion_cruce': _orientacionCruceController.text,
      'numero': _numeroController.text,
      'complemento_direccion': _complementoController.text,
    };
  }

  // 1. Método para mostrar el menú de secciones
  void _mostrarSecciones() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: secciones.keys.map((seccionTitulo) {
            return ExpansionTile(
              title: Text(seccionTitulo,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              children: secciones[seccionTitulo]!.map((pantalla) {
                return ListTile(
                  title: Text(pantalla['title']),
                  onTap: () async {
                    Navigator.pop(context);
                    

                    // Convertir explícitamente el mapa de args
                    final Map<String, dynamic> navigationArgs = {
                      'userId': widget.userId,
                      'evaluacionId': widget.evaluacionId,
                      ...Map<String, dynamic>.from(pantalla['args'] as Map),
                    };

                    _navigateToSection(
                        pantalla['route'] as String, navigationArgs);
                  },
                );
              }).toList(),
            );
          }).toList(),
        );
      },
    );
  }

// Actualizar también el método _navigateToSection
  void _navigateToSection(String routeName, Map<String, dynamic> args) {
    Navigator.pushNamed(
      context,
      routeName,
      arguments: args,
    );
  }

  // 3. Método para guardar datos actuales
  Future<void> _saveCurrentData() async {
    try {
      // Guardar datos generales y dirección
      final datosGenerales = {
        'nombre_edificacion': _nombreEdificacionController.text,
        'municipio': _municipioController.text,
        'comuna': _comunaController.text,
        'barrio_vereda': _barrioVeredaController.text,
        'tipo_propiedad': _tipoPropiedadController.text,
        'departamento': _departamentoController.text,
      };

      final datosDireccion = obtenerDatosDireccion();

      await DatabaseHelper().insertarIdentificacionEdificacion(
        evaluacionId: widget.evaluacionId,
        datosGenerales: datosGenerales,
        datosDireccion: datosDireccion,
        datosCatastrales: {
          'codigo_medellin': _medellinController.text,
          'codigo_area_metropolitana': _areaMetropolitanaController.text,
          'latitud': double.tryParse(_latitudController.text) ?? 0.0,
          'longitud': double.tryParse(_longitudController.text) ?? 0.0,
        },
        datosContacto: {
          'nombre': _nombreContactoController.text,
          'telefono': _telefonoController.text,
          'correo': _correoController.text,
          'tipo_persona': _tipoPersonaController.text,
        },
      );
    } catch (e) {
      print('Error al guardar datos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener datos de dirección
    final datosDireccion = obtenerDatosDireccion();

    void _handleSectionSelected(int sectionId) {
      // Encontrar la pantalla correspondiente por ID
      String? routeName;
      Map<String, dynamic>? args;

      secciones.forEach((seccion, pantallas) {
        for (var pantalla in pantallas) {
          if (pantalla['id'] == sectionId) {
            routeName = pantalla['route'];
            args = {
              'userId': widget.userId,
              'evaluacionId': widget.evaluacionId,
              ...pantalla['args'], // Combinar argumentos extra si hay
            };
            break;
          }
        }
      });

      if (routeName != null && args != null) {
        Navigator.pushNamed(
          context,
          routeName!,
          arguments: args,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Identificación de la Edificación'),
        backgroundColor: const Color(0xFF002855),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DatosGeneralesSubseccion(
            nombreEdificacionController: _nombreEdificacionController,
            municipioController: _municipioController,
            comunaController: _comunaController,
            barrioVeredaController: _barrioVeredaController,
            tipoPropiedadController: _tipoPropiedadController,
            departamentoController: _departamentoController,
          ),
          DireccionSubseccion(
            departamentoController: _departamentoController,
            tipoViaController: _tipoViaController,
            numeroViaController: _numeroViaController,
            apendiceViaController: _apendiceViaController,
            orientacionController: _orientacionController,
            numeroCruceController: _numeroCruceController,
            orientacionCruceController: _orientacionCruceController,
            numeroController: _numeroController,
            complementoController: _complementoController,
          ),
          IdentificacionCatastralSubseccion(
            medellinController: _medellinController,
            areaMetropolitanaController: _areaMetropolitanaController,
            latitudController: _latitudController,
            longitudController: _longitudController,
          ),
          PersonaContactoSubseccion(
            datosDireccion: datosDireccion,
            nombreContactoController: _nombreContactoController,
            telefonoController: _telefonoController,
            correoController: _correoController,
            tipoPersonaController: _tipoPersonaController,
            nombreEdificacionController: _nombreEdificacionController,
            municipioController: _municipioController,
            barrioVeredaController: _barrioVeredaController,
            comunaController: _comunaController,
            tipoPropiedadController: _tipoPropiedadController,
            medellinController: _medellinController,
            areaMetropolitanaController: _areaMetropolitanaController,
            latitudController: _latitudController,
            longitudController: _longitudController,
            evaluacionId: widget.evaluacionId,
            userId: widget.userId,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarSecciones,
        child: const Icon(Icons.menu),
        backgroundColor: const Color(0xFF002855),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF002855), // Azul oscuro corporativo
        selectedItemColor:
            const Color(0xFFFAD502), // Amarillo para ítem seleccionado
        unselectedItemColor: Colors.white, // Blanco para ítems no seleccionados
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Datos Generales',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Dirección',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Catastral',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_phone),
            label: 'Contacto',
          ),
        ],
      ),
    );
  }
}
