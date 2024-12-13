import 'package:flutter/material.dart';

class DatosGeneralesSubseccion extends StatelessWidget {
  final TextEditingController nombreEdificacionController;
  final TextEditingController municipioController;
  final TextEditingController barrioVeredaController;
  final TextEditingController direccionController;
  final TextEditingController tipoPropiedadController;

  const DatosGeneralesSubseccion({
    super.key,
    required this.nombreEdificacionController,
    required this.municipioController,
    required this.barrioVeredaController,
    required this.direccionController,
    required this.tipoPropiedadController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Nombre de la Edificación
          TextFormField(
            controller: nombreEdificacionController,
            decoration: const InputDecoration(
              labelText: 'Nombre de la Edificación',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese el nombre de la edificación';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Municipio
          TextFormField(
            controller: municipioController,
            decoration: const InputDecoration(
              labelText: 'Municipio',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese el municipio';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Barrio / Vereda
          TextFormField(
            controller: barrioVeredaController,
            decoration: const InputDecoration(
              labelText: 'Barrio / Vereda',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese el barrio o vereda';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Dirección
          TextFormField(
            controller: direccionController,
            decoration: const InputDecoration(
              labelText: 'Dirección',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese la dirección';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Tipo de Propiedad
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  tipoPropiedadController.text = 'Pública';
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: tipoPropiedadController.text == 'Pública'
                      ? Colors.blue
                      : Colors.grey,
                ),
                child: const Text('Pública'),
              ),
              ElevatedButton(
                onPressed: () {
                  tipoPropiedadController.text = 'Privada';
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: tipoPropiedadController.text == 'Privada'
                      ? Colors.blue
                      : Colors.grey,
                ),
                child: const Text('Privada'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}