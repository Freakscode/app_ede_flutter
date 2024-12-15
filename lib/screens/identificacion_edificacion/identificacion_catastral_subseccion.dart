// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class IdentificacionCatastralSubseccion extends StatefulWidget {
  final TextEditingController medellinController;
  final TextEditingController areaMetropolitanaController;
  final TextEditingController latitudController;
  final TextEditingController longitudController;

  const IdentificacionCatastralSubseccion({
    super.key,
    required this.medellinController,
    required this.areaMetropolitanaController,
    required this.latitudController,
    required this.longitudController,
  });

  @override
  // ignore: library_private_types_in_public_api
  _IdentificacionCatastralSubseccionState createState() =>
      _IdentificacionCatastralSubseccionState();
}

class _IdentificacionCatastralSubseccionState
    extends State<IdentificacionCatastralSubseccion> {
  String _tipoSeleccionado = '';
  GoogleMapController? _mapController;

  final CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(6.244203, -75.581212), // Ejemplo: Medellín
    zoom: 13.0,
  );

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTap(LatLng latLng) {
    setState(() {
      widget.latitudController.text = latLng.latitude.toStringAsFixed(6);
      widget.longitudController.text = latLng.longitude.toStringAsFixed(6);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Coordenadas seleccionadas: ${latLng.latitude}, ${latLng.longitude}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Identificación Catastral'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: _initialPosition,
              onTap: _onMapTap,
              mapType: MapType.normal,
              // Puedes agregar más configuraciones aquí, como marcadores, myLocationEnabled, etc.
            ),
          ),
          _buildFormFields(),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Botones de selección
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _tipoSeleccionado = 'Medellín';
                    widget.areaMetropolitanaController.clear();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _tipoSeleccionado == 'Medellín' ? Colors.blue : Colors.grey,
                ),
                child: const Text('Medellín'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _tipoSeleccionado = 'Área Metropolitana';
                    widget.medellinController.clear();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _tipoSeleccionado == 'Área Metropolitana'
                      ? Colors.blue
                      : Colors.grey,
                ),
                child: const Text('Área Metropolitana'),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
