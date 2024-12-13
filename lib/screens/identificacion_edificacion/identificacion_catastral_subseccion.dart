import 'package:flutter/material.dart';

class IdentificacionCatastralSubseccion extends StatefulWidget {
  final TextEditingController medellinController;
  final TextEditingController areaMetropolitanaController;
  final TextEditingController latitudController;
  final TextEditingController longitudController;

  const IdentificacionCatastralSubseccion({
    Key? key,
    required this.medellinController,
    required this.areaMetropolitanaController,
    required this.latitudController,
    required this.longitudController,
  }) : super(key: key);

  @override
  _IdentificacionCatastralSubseccionState createState() => _IdentificacionCatastralSubseccionState();
}

class _IdentificacionCatastralSubseccionState extends State<IdentificacionCatastralSubseccion> {
  String _tipoSeleccionado = ''; // Inicialmente ningún tipo seleccionado

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Botones de selección
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Botón Medellín
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _tipoSeleccionado = 'Medellín';
                    // Limpiar el controlador de Área Metropolitana para evitar datos inconsistentes
                    widget.areaMetropolitanaController.clear();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _tipoSeleccionado == 'Medellín' ? Colors.blue : Colors.grey,
                ),
                child: const Text('Medellín'),
              ),
              const SizedBox(width: 16),
              // Botón Área Metropolitana
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _tipoSeleccionado = 'Área Metropolitana';
                    // Limpiar el controlador de Medellín para evitar datos inconsistentes
                    widget.medellinController.clear();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _tipoSeleccionado == 'Área Metropolitana' ? Colors.blue : Colors.grey,
                ),
                child: const Text('Área Metropolitana'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Mostrar campo según selección
          if (_tipoSeleccionado == 'Medellín')
            TextFormField(
              controller: widget.medellinController,
              decoration: const InputDecoration(
                labelText: 'Medellín (11 dígitos)',
              ),
              keyboardType: TextInputType.number,
              maxLength: 11,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese el código de Medellín';
                }
                if (value.length != 11) {
                  return 'El código debe tener 11 dígitos';
                }
                return null;
              },
            )
          else if (_tipoSeleccionado == 'Área Metropolitana')
            TextFormField(
              controller: widget.areaMetropolitanaController,
              decoration: const InputDecoration(
                labelText: 'Área Metropolitana (19 dígitos)',
              ),
              keyboardType: TextInputType.number,
              maxLength: 19,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese el código del Área Metropolitana';
                }
                if (value.length != 19) {
                  return 'El código debe tener 19 dígitos';
                }
                return null;
              },
            ),
          const SizedBox(height: 16),
          // Coordenadas GPS - Latitud
          TextFormField(
            controller: widget.latitudController,
            decoration: const InputDecoration(
              labelText: 'Coordenadas GPS - Latitud',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese la latitud';
              }
              final lat = double.tryParse(value);
              if (lat == null || lat < -90 || lat > 90) {
                return 'Ingrese una latitud válida (-90 a 90)';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Coordenadas GPS - Longitud
          TextFormField(
            controller: widget.longitudController,
            decoration: const InputDecoration(
              labelText: 'Coordenadas GPS - Longitud',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese la longitud';
              }
              final lon = double.tryParse(value);
              if (lon == null || lon < -180 || lon > 180) {
                return 'Ingrese una longitud válida (-180 a 180)';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}