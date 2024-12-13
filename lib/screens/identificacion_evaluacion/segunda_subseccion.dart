// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class SegundaSubseccion extends StatefulWidget {
  final Future<void> Function(String, int) onEventoSeleccionado;
  final VoidCallback onContinue;
  final int? selectedEventoId;

  const SegundaSubseccion({
    super.key,
    required this.onEventoSeleccionado,
    required this.onContinue,
    required this.selectedEventoId,
  });

  @override
  _SegundaSubseccionState createState() => _SegundaSubseccionState();
}

class _SegundaSubseccionState extends State<SegundaSubseccion> {
  // No es necesario definir _selectedEventoId aquí

  // Lista de eventos con sus etiquetas e iconos
  final List<Map<String, dynamic>> eventos = [
    {
      'label': 'Inundación',
      'iconPath': 'assets/icons/flood.png',
      'tipoEventoId': 1,
    },
    {
      'label': 'Deslizamiento',
      'iconPath': 'assets/icons/landslide.png',
      'tipoEventoId': 2,
    },
    {
      'label': 'Sismo',
      'iconPath': 'assets/icons/earthquake.png',
      'tipoEventoId': 3,
    },
    {
      'label': 'Viento',
      'iconPath': 'assets/icons/wind.png',
      'tipoEventoId': 4,
    },
    {
      'label': 'Incendio',
      'iconPath': 'assets/icons/fire.png',
      'tipoEventoId': 5,
    },
    {
      'label': 'Explosión',
      'iconPath': 'assets/icons/explosion.png',
      'tipoEventoId': 6,
    },
    {
      'label': 'Estructural',
      'iconPath': 'assets/icons/structural.png',
      'tipoEventoId': 7,
    },
    {
      'label': 'Otro',
      'iconPath': 'assets/icons/other.png',
      'tipoEventoId': 8,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Título del Panel
          const Text(
            'IDENTIFICACIÓN DE EVALUACIÓN',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF002855),
            ),
          ),
          const SizedBox(height: 20),
          // Instrucción
          const Text(
            'Seleccionar un solo evento',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          // Cuadrícula de Eventos
          Expanded(
            child: GridView.count(
              crossAxisCount: 2, // 2 columnas
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.5,
              children: eventos.map((evento) {
                // Verificar si este evento está seleccionado
                final isSelected = widget.selectedEventoId == evento['tipoEventoId'];
                return GestureDetector(
                  onTap: () async {
                    // Simplemente llamar al callback sin validaciones
                    await widget.onEventoSeleccionado(evento['label'], evento['tipoEventoId']);
                    // Forzamos la reconstrucción para reflejar el cambio
                    setState(() {});
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.yellow,
                        width: isSelected ? 3 : 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: isSelected ? Colors.blue[100] : Colors.white,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Ícono del Evento
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              evento['iconPath'],
                              color: isSelected ? Colors.blue : Colors.blue,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        // Etiqueta del Evento
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            evento['label'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.blue : Color(0xFF002855),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          // Botón Continuar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onContinue, // Sin validaciones adicionales
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Continuar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
