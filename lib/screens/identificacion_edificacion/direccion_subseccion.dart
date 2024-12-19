// ignore_for_file: unused_field

import 'package:flutter/material.dart';

class DireccionSubseccion extends StatefulWidget {
  final TextEditingController departamentoController;
  final TextEditingController tipoViaController;
  final TextEditingController numeroViaController;
  final TextEditingController apendiceViaController;
  final TextEditingController orientacionController;
  final TextEditingController numeroCruceController;
  final TextEditingController orientacionCruceController;
  final TextEditingController numeroController;
  final TextEditingController complementoController;

  const DireccionSubseccion({
    Key? key,
    required this.departamentoController,
    required this.tipoViaController,
    required this.numeroViaController,
    required this.apendiceViaController,
    required this.orientacionController,
    required this.numeroCruceController,
    required this.orientacionCruceController,
    required this.numeroController,
    required this.complementoController,
  }) : super(key: key);

  // Agregar este método para obtener los datos de dirección
  Map<String, String> obtenerDatosDireccion() {
    return {
      'tipo_via': tipoViaController.text,
      'numero_via': numeroViaController.text,
      'apendice_via': apendiceViaController.text,
      'orientacion': orientacionController.text,
      'numero_cruce': numeroCruceController.text,
      'orientacion_cruce': orientacionCruceController.text,
      'numero': numeroController.text,
      'complemento_direccion': complementoController.text,
    };
  }

  @override
  State<DireccionSubseccion> createState() => _DireccionSubseccionState();
}

class _DireccionSubseccionState extends State<DireccionSubseccion> {
  // Constantes de estilo
  static const colorAzulOscuro = Color(0xFF002855);
  static const colorAmarillo = Color(0xFFFAD502);
  static const colorBlanco = Color(0xFFFFFFFF);

  final decoracionInputBase = InputDecoration(
    labelStyle: const TextStyle(color: colorAzulOscuro),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: colorAzulOscuro),
    ),
    filled: true,
    fillColor: Colors.grey[100],
  );

  // Mapeos
  final Map<String, String> tiposViaAbrev = {
    'Calle': 'CL',
    'Carrera': 'CR',
    'Circular': 'CQ',
    'Transversal': 'TV',
    'Diagonal': 'DG'
  };

  final Map<String, List<String>> orientacionesPorTipoVia = {
    'Calle': ['Sur'],
    'Carrera': ['Este'],
    'Circular': [],
    'Transversal': [],
    'Diagonal': [],
  };

  // Validadores
  bool _validarNumeroVia(String value) {
    if (value.isEmpty) return false;
    final numero = int.tryParse(value.replaceAll(RegExp(r'^0+'), ''));
    return numero != null && numero > 0 && numero <= 999;
  }

  bool _validarApendice(String value) {
    if (value.isEmpty) return true;
    final regex = RegExp(r'^[A-H]{1,2}$');
    return regex.hasMatch(value);
  }

  // Widgets personalizados
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? helperText,
    bool requiredField = false,
    Function(String)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: decoracionInputBase.copyWith(
        labelText: requiredField ? '$labelText *' : labelText,
        helperText: helperText,
      ),
      validator: (value) {
        if (requiredField && (value == null || value.isEmpty)) {
          return 'Este campo es obligatorio';
        }
        if (validator != null) {
          return validator(value ?? '');
        }
        return null;
      },
    );
  }

  Widget _buildOrientacionDropdown({
    required String label,
    required TextEditingController controller,
    required List<String> orientaciones,
  }) {
    return DropdownButtonFormField<String>(
      decoration: decoracionInputBase.copyWith(labelText: label),
      value: controller.text.isEmpty ? null : controller.text,
      items: orientaciones.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? value) {
        setState(() {
          controller.text = value ?? '';
        });
      },
    );
  }

  // Ejemplo de dirección
  Widget _buildEjemploDireccion() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorAzulOscuro),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Ejemplos de dirección:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorAzulOscuro,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'CL 44 B SUR 72 A SUR 23\nCR 52 A ESTE 65 B ESTE 12',
            style: TextStyle(
              color: colorAzulOscuro,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  final List<String> departamentos = [
    'Amazonas', 'Antioquia', 'Arauca', 'Atlántico', 'Bolívar',
    'Boyacá', 'Caldas', 'Caquetá', 'Casanare', 'Cauca',
    'Cesar', 'Chocó', 'Córdoba', 'Cundinamarca', 'Guainía',
    'Guaviare', 'Huila', 'La Guajira', 'Magdalena', 'Meta',
    'Nariño', 'Norte de Santander', 'Putumayo', 'Quindío',
    'Risaralda', 'San Andrés y Providencia', 'Santander', 'Sucre',
    'Tolima', 'Valle del Cauca', 'Vaupés', 'Vichada'
  ];

  final List<String> tiposVia = [
    'Calle', 'Carrera', 'Circular', 'Transversal', 'Diagonal'
  ];

  final List<String> orientaciones = ['Sur', 'Este'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBlanco,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tipo de vía (Obligatorio)
            DropdownButtonFormField<String>(
              decoration: decoracionInputBase.copyWith(
                labelText: 'Tipo de vía *',
              ),
              items: tiposVia.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor seleccione un tipo de vía';
                }
                return null;
              },
              onChanged: (value) {
                widget.tipoViaController.text = value ?? '';
              },
            ),
            const SizedBox(height: 16),

            // Número de vía (Obligatorio)
            _buildTextField(
              controller: widget.numeroViaController,
              labelText: 'Número de vía',
              requiredField: true,
              validator: (value) {
                if (value.isEmpty) {
                  return 'El número de vía es obligatorio';
                }
                if (!_validarNumeroVia(value)) {
                  return 'Número de vía no válido (1-999)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Apéndice de vía (Opcional)
            _buildTextField(
              controller: widget.apendiceViaController,
              labelText: 'Apéndice de vía',
              requiredField: false,
              validator: (value) {
                if (value.isNotEmpty && !_validarApendice(value)) {
                  return 'Apéndice de vía no válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Orientación
            _buildOrientacionDropdown(
              label: 'Orientación',
              controller: widget.orientacionController,
              orientaciones: orientaciones,
            ),
            const SizedBox(height: 16),

            // Número de cruce (Obligatorio)
            _buildTextField(
              controller: widget.numeroCruceController,
              labelText: 'Número de cruce',
              requiredField: true,
              validator: (value) {
                if (value.isEmpty) {
                  return 'El número de cruce es obligatorio';
                }
                if (!_validarNumeroVia(value)) {
                  return 'Número de cruce no válido (1-999)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Número específico (Obligatorio)
            _buildTextField(
              controller: widget.numeroController,
              labelText: 'Número específico',
              requiredField: true,
              validator: (value) {
                if (value.isEmpty) {
                  return 'El número específico es obligatorio';
                }
                if (!_validarNumeroVia(value)) {
                  return 'Número no válido (1-999)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Orientación de cruce
            _buildOrientacionDropdown(
              label: 'Orientación de cruce',
              controller: widget.orientacionCruceController,
              orientaciones: orientaciones,
            ),
            const SizedBox(height: 16),

            // Complemento
            _buildTextField(
              controller: widget.complementoController,
              labelText: 'Complemento de la dirección',
              helperText: 'Ej: Apto 101, Torre 2',
            ),
            const SizedBox(height: 16),

            // Ejemplo de dirección
            _buildEjemploDireccion(),
          ],
        ),
      ),
    );
  }
}