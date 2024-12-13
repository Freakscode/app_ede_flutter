// lib/screens/identificacion_edificacion/identificacion_edificacion_screen.dart 

// ignore_for_file: unused_import, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'datos_generales_subseccion.dart';
import 'identificacion_catastral_subseccion.dart';
import 'persona_contacto_subseccion.dart';

class IdentificacionEdificacionScreen extends StatefulWidget {
  final int evaluacionId;

  const IdentificacionEdificacionScreen({Key? key, required this.evaluacionId}) : super(key: key);

  @override
  _IdentificacionEdificacionScreenState createState() => _IdentificacionEdificacionScreenState();
}

class _IdentificacionEdificacionScreenState extends State<IdentificacionEdificacionScreen> {
  int _currentIndex = 0;

  // Controladores para Datos Generales
  final TextEditingController _nombreEdificacionController = TextEditingController();
  final TextEditingController _municipioController = TextEditingController();
  final TextEditingController _barrioVeredaController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _tipoPropiedadController = TextEditingController();

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

  @override
  void dispose() {
    // Dispose de todos los controladores
    _nombreEdificacionController.dispose();
    _municipioController.dispose();
    _barrioVeredaController.dispose();
    _direccionController.dispose();
    _tipoPropiedadController.dispose();
    _medellinController.dispose();
    _areaMetropolitanaController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    _nombreContactoController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    _tipoPersonaController.dispose();
    super.dispose();
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
            barrioVeredaController: _barrioVeredaController,
            direccionController: _direccionController,
            tipoPropiedadController: _tipoPropiedadController,
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
            direccionController: _direccionController,
            tipoPropiedadController: _tipoPropiedadController,
            medellinController: _medellinController,
            areaMetropolitanaController: _areaMetropolitanaController,
            latitudController: _latitudController,
            longitudController: _longitudController,
            evaluacionId: widget.evaluacionId,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Datos Generales',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Catastral',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_mail),
            label: 'Contacto',
          ),
        ],
      ),
    );
  }
}