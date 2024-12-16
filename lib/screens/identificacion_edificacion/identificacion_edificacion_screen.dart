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
  final TextEditingController _nombreEdificacionController = TextEditingController();
  final TextEditingController _municipioController = TextEditingController();
  final TextEditingController _barrioVeredaController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _tipoPropiedadController = TextEditingController();

  // Nuevos controladores para dirección
  final TextEditingController _departamentoController = TextEditingController();
  final TextEditingController _tipoViaController = TextEditingController();
  final TextEditingController _numeroViaController = TextEditingController();
  final TextEditingController _apendiceViaController = TextEditingController();
  final TextEditingController _orientacionController = TextEditingController();
  final TextEditingController _numeroCruceController = TextEditingController();
  final TextEditingController _orientacionCruceController = TextEditingController();
  final TextEditingController _complementoController = TextEditingController();
  final TextEditingController _comunaController = TextEditingController();

  // Controladores para Identificación Catastral
  final TextEditingController _medellinController = TextEditingController();
  final TextEditingController _areaMetropolitanaController = TextEditingController();
  final TextEditingController _latitudController = TextEditingController();
  final TextEditingController _longitudController = TextEditingController();

  // Controladores para Persona de Contacto
  final TextEditingController _nombreContactoController = TextEditingController();
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

      // Validar datos de dirección
      if (_tipoViaController.text.isEmpty ||
          _numeroViaController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complete los datos básicos de la dirección')),
        );
        setState(() => _currentIndex = 1);
        return;
      }

      // Construir la dirección completa
      final direccionCompleta = _construirDireccionCompleta();

      // Preparar datos para guardar
      final evaluacionEdificioId = await DatabaseHelper().insertarIdentificacionEdificacion(
        evaluacionId: widget.evaluacionId,
        datosGenerales: {
          'nombre_edificacion': _nombreEdificacionController.text,
          'municipio': _municipioController.text,
          'comuna': _comunaController.text,
          'barrio_vereda': _barrioVeredaController.text,
          'tipo_propiedad': _tipoPropiedadController.text,
          'direccion': direccionCompleta,
          'departamento': _departamentoController.text,
        },
        datosCatastrales: {
          'codigo_medellin': _medellinController.text,
          'codigo_area_metropolitana': _areaMetropolitanaController.text,
          'latitud': double.parse(_latitudController.text),
        },
        datosContacto: {
          'nombre': _nombreContactoController.text,
          'telefono': _telefonoController.text,
          'correo': _correoController.text,
          'tipo_persona': _tipoPersonaController.text,
        },
      );

      // ... resto del código de navegación ...
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            complementoController: _complementoController,
          ),
          IdentificacionCatastralSubseccion(
            medellinController: _medellinController,
            areaMetropolitanaController: _areaMetropolitanaController,
            latitudController: _latitudController,
            longitudController: _longitudController,
          ),
          PersonaContactoSubseccion(
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
      floatingActionButton: FloatingSectionsMenu(
        currentSection: _currentIndex + 1, // Convertir a 1-indexado
        onSectionSelected: _onSectionSelected,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF002855), // Azul oscuro corporativo
        selectedItemColor: const Color(0xFFFAD502), // Amarillo para ítem seleccionado
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