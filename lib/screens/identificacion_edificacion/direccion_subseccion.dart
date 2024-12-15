import 'package:flutter/material.dart';

class DireccionSubseccion extends StatefulWidget {
  final TextEditingController departamentoController;
  final TextEditingController tipoViaController;
  final TextEditingController numeroViaController;
  final TextEditingController apendiceViaController;
  final TextEditingController orientacionController;
  final TextEditingController numeroCruceController;
  final TextEditingController orientacionCruceController;
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
    required this.complementoController,
  }) : super(key: key);

  @override
  State<DireccionSubseccion> createState() => _DireccionSubseccionState();
}

class _DireccionSubseccionState extends State<DireccionSubseccion> {
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tipo de vía
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Tipo de vía *',
              border: OutlineInputBorder(),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
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

          // Número de vía
          TextFormField(
            controller: widget.numeroViaController,
            decoration: const InputDecoration(
              labelText: 'Número de vía *',
              border: OutlineInputBorder(),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese el número de vía';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Apéndice de vía
          TextFormField(
            controller: widget.apendiceViaController,
            decoration: const InputDecoration(
              labelText: 'Apéndice de vía *',
              border: OutlineInputBorder(),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese el apéndice de vía';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Orientación
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Orientación',
              border: OutlineInputBorder(),
            ),
            items: orientaciones.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              widget.orientacionController.text = value ?? '';
            },
          ),
          const SizedBox(height: 16),

          // Número de cruce
          TextFormField(
            controller: widget.numeroCruceController,
            decoration: const InputDecoration(
              labelText: 'Número de cruce *',
              border: OutlineInputBorder(),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese el número de cruce';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Orientación de cruce
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Orientación de cruce',
              border: OutlineInputBorder(),
            ),
            items: orientaciones.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              widget.orientacionCruceController.text = value ?? '';
            },
          ),
          const SizedBox(height: 16),

          // Complemento
          TextFormField(
            controller: widget.complementoController,
            decoration: const InputDecoration(
              labelText: 'Complemento de la dirección',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}