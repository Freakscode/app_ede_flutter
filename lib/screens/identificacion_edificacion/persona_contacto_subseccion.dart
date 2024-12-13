import 'package:flutter/material.dart';
import '../../utils/database_helper.dart';
import '../descripcion_edificacion/descripcion_edificacion_screen.dart';

class PersonaContactoSubseccion extends StatefulWidget {
  final TextEditingController nombreContactoController;
  final TextEditingController telefonoController;
  final TextEditingController correoController;
  final TextEditingController tipoPersonaController;
  final TextEditingController nombreEdificacionController;
  final TextEditingController municipioController;
  final TextEditingController barrioVeredaController;
  final TextEditingController direccionController;
  final TextEditingController tipoPropiedadController;
  final TextEditingController medellinController;
  final TextEditingController areaMetropolitanaController;
  final TextEditingController latitudController;
  final TextEditingController longitudController;
  final int evaluacionId;

  const PersonaContactoSubseccion({
    Key? key,
    required this.nombreContactoController,
    required this.telefonoController,
    required this.correoController,
    required this.tipoPersonaController,
    required this.nombreEdificacionController,
    required this.municipioController,
    required this.barrioVeredaController,
    required this.direccionController,
    required this.tipoPropiedadController,
    required this.medellinController,
    required this.areaMetropolitanaController,
    required this.latitudController,
    required this.longitudController,
    required this.evaluacionId,
  }) : super(key: key);

  @override
  State<PersonaContactoSubseccion> createState() => _PersonaContactoSubseccionState();
}

class _PersonaContactoSubseccionState extends State<PersonaContactoSubseccion> {
  String _selectedTipo = '';
  final TextEditingController _otroTipoController = TextEditingController();

  @override
  void dispose() {
    _otroTipoController.dispose();
    super.dispose();
  }

  void _selectTipo(String tipo) {
    setState(() {
      _selectedTipo = tipo;
      if (tipo != 'Otro') {
        widget.tipoPersonaController.text = tipo;
        _otroTipoController.clear();
      } else {
        widget.tipoPersonaController.text = '';
      }
    });
  }

  Future<void> _guardarYContinuar() async {
    // Validar tipo de persona
    if (_selectedTipo == 'Otro' && _otroTipoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor especifique el tipo de persona')),
      );
      return;
    }

    try {
      // Validar datos generales
      if (widget.nombreEdificacionController.text.isEmpty ||
          widget.municipioController.text.isEmpty ||
          widget.barrioVeredaController.text.isEmpty ||
          widget.direccionController.text.isEmpty ||
          widget.tipoPropiedadController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complete todos los datos generales')),
        );
        // Opcional: Puedes cambiar la pestaña activa si lo deseas
        return;
      }

      // Validar datos catastrales
      if ((widget.medellinController.text.isEmpty && widget.areaMetropolitanaController.text.isEmpty) ||
          widget.latitudController.text.isEmpty ||
          widget.longitudController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complete los datos catastrales')),
        );
        // Opcional: Puedes cambiar la pestaña activa si lo deseas
        return;
      }

      // Validar datos de contacto
      if (widget.nombreContactoController.text.isEmpty ||
          widget.telefonoController.text.isEmpty ||
          widget.correoController.text.isEmpty ||
          ( _selectedTipo.isEmpty || _selectedTipo == 'Otro' && _otroTipoController.text.isEmpty )) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complete los datos de contacto')),
        );
        // Opcional: Puedes cambiar la pestaña activa si lo deseas
        return;
      }

      // Preparar datos para guardar
      final evaluacionEdificioId = await DatabaseHelper().insertarIdentificacionEdificacion(
        evaluacionId: widget.evaluacionId,
        datosGenerales: {
          'nombre_edificacion': widget.nombreEdificacionController.text,
          'municipio': widget.municipioController.text,
          'barrio_vereda': widget.barrioVeredaController.text,
          'direccion': widget.direccionController.text,
          'tipo_propiedad': widget.tipoPropiedadController.text,
        },
        datosCatastrales: {
          'codigo_medellin': widget.medellinController.text,
          'codigo_area_metropolitana': widget.areaMetropolitanaController.text,
          'latitud': double.parse(widget.latitudController.text),
          'longitud': double.parse(widget.longitudController.text),
        },
        datosContacto: {
          'nombre': widget.nombreContactoController.text,
          'telefono': widget.telefonoController.text,
          'correo': widget.correoController.text,
          'tipo_persona': _selectedTipo == 'Otro' ? _otroTipoController.text : widget.tipoPersonaController.text,
        },
      );

      if (!mounted) return;

      // Navegar a la siguiente pantalla
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DescripcionEdificacionScreen(
            evaluacionId: widget.evaluacionId,
            evaluacionEdificioId: evaluacionEdificioId,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Puedes optar por no usar otro Scaffold si ya está envuelto en uno superior
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre
            TextFormField(
              controller: widget.nombreContactoController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese el nombre';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Teléfono
            TextFormField(
              controller: widget.telefonoController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese el teléfono';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Correo Electrónico
            TextFormField(
              controller: widget.correoController,
              decoration: const InputDecoration(
                labelText: 'Correo Electrónico',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese el correo electrónico';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Ingrese un correo electrónico válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Tipo de Persona
            const Text(
              'Tipo de Persona',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTipoPersonaButton(
              icon: Icons.person,
              label: 'Propietario',
              tipo: 'Propietario',
            ),
            const SizedBox(height: 12),
            _buildTipoPersonaButton(
              icon: Icons.home,
              label: 'Inquilino',
              tipo: 'Inquilino',
            ),
            const SizedBox(height: 12),
            _buildTipoPersonaButton(
              icon: Icons.person_outline,
              label: 'Otro',
              tipo: 'Otro',
            ),
            if (_selectedTipo == 'Otro') ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _otroTipoController,
                decoration: const InputDecoration(
                  labelText: 'Especifique el tipo de persona',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  widget.tipoPersonaController.text = value;
                },
                validator: (value) {
                  if (_selectedTipo == 'Otro' && (value == null || value.isEmpty)) {
                    return 'Por favor especifique el tipo de persona';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 24),
            // Botón "Continuar"
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _guardarYContinuar,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Continuar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002855),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipoPersonaButton({
    required IconData icon,
    required String label,
    required String tipo,
  }) {
    final bool isSelected = _selectedTipo == tipo;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _selectTipo(tipo),
        icon: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey[700],
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue : Colors.grey[200],
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? Colors.blue : Colors.grey,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}