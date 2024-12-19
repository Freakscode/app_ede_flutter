// lib/screens/identificacion_edificacion/datos_generales_subseccion.dart

// ignore_for_file: unused_local_variable, unused_import, unused_field, prefer_final_fields, unused_element

import 'package:flutter/material.dart';

class DatosGeneralesSubseccion extends StatefulWidget {
  final TextEditingController nombreEdificacionController;
  final TextEditingController municipioController;
  final TextEditingController barrioVeredaController;
  final TextEditingController tipoPropiedadController;
  final TextEditingController comunaController;
  final TextEditingController departamentoController;

  const DatosGeneralesSubseccion({
    Key? key,
    required this.nombreEdificacionController,
    required this.municipioController,
    required this.comunaController,
    required this.barrioVeredaController,
    required this.tipoPropiedadController,
    required this.departamentoController,
  }) : super(key: key);

  @override
  State<DatosGeneralesSubseccion> createState() =>
      _DatosGeneralesSubseccionState();
}

class _DatosGeneralesSubseccionState extends State<DatosGeneralesSubseccion> {
  bool _tieneComuna = true;

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

  final List<String> departamentos = [
    'Amazonas',
    'Antioquia',
    'Arauca',
    'Atlántico',
    'Bolívar',
    'Boyacá',
    'Caldas',
    'Caquetá',
    'Casanare',
    'Cauca',
    'Cesar',
    'Chocó',
    'Córdoba',
    'Cundinamarca',
    'Guainía',
    'Guaviare',
    'Huila',
    'La Guajira',
    'Magdalena',
    'Meta',
    'Nariño',
    'Norte de Santander',
    'Putumayo',
    'Quindío',
    'Risaralda',
    'San Andrés y Providencia',
    'Santander',
    'Sucre',
    'Tolima',
    'Valle del Cauca',
    'Vaupés',
    'Vichada'
  ];

  final List<String> municipiosAntioquia = [
    'Medellín',
    'Barbosa',
    'Copacabana',
    'Girardota',
    'Bello',
    'Envigado',
    'Itagüí',
    'Sabaneta',
    'La Estrella',
    'Caldas'
  ];

  final List<String> comunasMedellin = [
    'Comuna 1 - Popular',
    'Comuna 2 - Santa Cruz',
    'Comuna 3 - Manrique',
    'Comuna 4 - Aranjuez',
    'Comuna 5 - Castilla',
    'Comuna 6 - Doce de Octubre',
    'Comuna 7 - Robledo',
    'Comuna 8 - Villa Hermosa',
    'Comuna 9 - Buenos Aires',
    'Comuna 10 - La Candelaria',
    'Comuna 11 - Laureles Estadio',
    'Comuna 12 - La América',
    'Comuna 13 - San Javier',
    'Comuna 14 - El Poblado',
    'Comuna 15 - Guayabal',
    'Comuna 16 - Belén',
    'Corregimiento San Sebastián de Palmitas',
    'Corregimiento San Cristóbal',
    'Corregimiento Altavista',
    'Corregimiento San Antonio de Prado',
    'Corregimiento Santa Elena'
  ];

  Widget _buildComunaField() {
    if (widget.departamentoController.text != 'Antioquia') {
      return _tieneComuna
          ? TextFormField(
              controller: widget.comunaController,
              decoration: const InputDecoration(
                labelText: 'Comuna',
                labelStyle: TextStyle(color: Color(0xFF002855)),
                border: OutlineInputBorder(),
                filled: true,
              ),
            )
          : const SizedBox.shrink();
    }

    return widget.municipioController.text == 'Medellín'
        ? DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Comuna *',
              labelStyle: TextStyle(color: Color(0xFF002855)),
              border: OutlineInputBorder(),
              filled: true,
            ),
            value: widget.comunaController.text.isEmpty
                ? null
                : widget.comunaController.text,
            items: comunasMedellin.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                widget.comunaController.text = value ?? '';
              });
            },
          )
        : TextFormField(
            controller: widget.comunaController,
            decoration: const InputDecoration(
              labelText: 'Número de Comuna *',
              labelStyle: TextStyle(color: Color(0xFF002855)),
              border: OutlineInputBorder(),
              filled: true,
            ),
            keyboardType: TextInputType.number,
          );
  }

  Widget _buildDepartamento() {
    return DropdownButtonFormField<String>(
      decoration: decoracionInputBase.copyWith(
        labelText: 'Departamento *',
      ),
      value: widget.departamentoController.text.isEmpty
          ? null
          : widget.departamentoController.text,
      items: departamentos.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: _onDepartamentoChanged,
      validator: (value) =>
          (value?.isEmpty ?? true) ? 'Por favor seleccione un departamento' : null,
    );
  }

  void _onDepartamentoChanged(String? value) {
    setState(() {
      widget.departamentoController.text = value ?? '';
      widget.municipioController.clear();
      widget.comunaController.clear();

      if (value == 'Antioquia') {
        widget.municipioController.text = 'Medellín';
        _tieneComuna = true;
      }
    });
  }

  Widget _buildMunicipio() {
    if (widget.departamentoController.text.isEmpty) return const SizedBox.shrink();

    return widget.departamentoController.text == 'Antioquia'
        ? _buildMunicipioAntioquia()
        : _buildMunicipioOtro();
  }

  Widget _buildMunicipioAntioquia() {
    return DropdownButtonFormField<String>(
      decoration: decoracionInputBase.copyWith(
        labelText: 'Municipio *',
      ),
      value: widget.municipioController.text.isEmpty
          ? null
          : widget.municipioController.text,
      items: municipiosAntioquia.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: _onMunicipioAntioquiaChanged,
    );
  }

  void _onMunicipioAntioquiaChanged(String? value) {
    setState(() {
      widget.municipioController.text = value ?? 'Medellín';
      widget.comunaController.clear();
      _tieneComuna = value == 'Medellín';
    });
  }

  Widget _buildMunicipioOtro() {
    return TextFormField(
      controller: widget.municipioController,
      decoration: decoracionInputBase.copyWith(
        labelText: 'Municipio *',
      ),
    );
  }

  Widget _buildTieneComunaRadios() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '¿El municipio tiene comunas?',
          style: TextStyle(
            color: Color(0xFF002855),
            fontSize: 16,
          ),
        ),
        Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: _tieneComuna,
              onChanged: (bool? value) {
                setState(() {
                  _tieneComuna = value ?? true;
                  widget.comunaController.clear();
                });
              },
            ),
            const Text('Sí'),
            const SizedBox(width: 20),
            Radio<bool>(
              value: false,
              groupValue: _tieneComuna,
              onChanged: (bool? value) {
                setState(() {
                  _tieneComuna = value ?? false;
                  widget.comunaController.clear();
                });
              },
            ),
            const Text('No'),
          ],
        ),
      ],
    );
  }

  Widget _buildComuna() {
    // Si es Antioquia y Medellín
    if (widget.departamentoController.text == 'Antioquia' &&
        widget.municipioController.text == 'Medellín') {
      return DropdownButtonFormField<String>(
        decoration: decoracionInputBase.copyWith(
          labelText: 'Comuna *',
        ),
        value: widget.comunaController.text.isEmpty
            ? null
            : widget.comunaController.text,
        items: comunasMedellin.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            widget.comunaController.text = value ?? '';
          });
        },
      );
    }
    // Si es otro departamento o municipio
    else {
      return Column(
        children: [
          _buildTieneComunaRadios(),
          if (_tieneComuna) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: widget.comunaController,
              decoration: decoracionInputBase.copyWith(
                labelText: 'Comuna',
              ),
            ),
          ],
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final azulOscuro = const Color(0xFF002855);
    final amarillo = const Color(0xFFFAD502);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: azulOscuro,
        title: const Text(
          'IDENTIFICACIÓN DE LA EDIFICACIÓN',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.account_circle, size: 30, color: Colors.white),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              const Icon(
                Icons.home,
                size: 80,
                color: Color(0xFF002855),
              ),
              const SizedBox(height: 20),
              const Text(
                'DATOS GENERALES',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF002855),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: widget.nombreEdificacionController,
                labelText: 'Nombre de la edificación',
              ),
              const SizedBox(height: 16),

              _buildDepartamento(),
              const SizedBox(height: 16),

              if (widget.departamentoController.text.isNotEmpty)
                widget.departamentoController.text == 'Antioquia'
                    ? _buildMunicipioAntioquia()
                    : _buildMunicipioOtro(),
              const SizedBox(height: 16),

              if (widget.departamentoController.text.isNotEmpty)
                _buildComuna(),

              const SizedBox(height: 16),

              _buildTextField(
                controller: widget.barrioVeredaController,
                labelText: 'Barrio / Vereda *',
                requiredField: true,
              ),
              const SizedBox(height: 16),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '*Tipo de propiedad',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF002855),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _buildTipoPropiedadButton(
                      label: 'PÚBLICA',
                      isSelected:
                          widget.tipoPropiedadController.text == 'Pública',
                      onTap: () {
                        setState(() {
                          widget.tipoPropiedadController.text = 'Pública';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTipoPropiedadButton(
                      label: 'PRIVADA',
                      isSelected:
                          widget.tipoPropiedadController.text == 'Privada',
                      onTap: () {
                        setState(() {
                          widget.tipoPropiedadController.text = 'Privada';
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool requiredField = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Color(0xFF002855)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF002855)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF002855), width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: (value) {
        if (requiredField && (value == null || value.isEmpty)) {
          return 'Este campo es obligatorio';
        }
        return null;
      },
    );
  }

  Widget _buildTipoPropiedadButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final azulOscuro = const Color(0xFF002342);
    final amarillo = const Color(0xFFFAD502);
    final blanco = const Color(0xFFFFFFFF);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? azulOscuro : blanco,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? null
              : Border.all(
                  color: amarillo,
                  width: 2,
                ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? blanco : azulOscuro,
          ),
        ),
      ),
    );
  }
}
