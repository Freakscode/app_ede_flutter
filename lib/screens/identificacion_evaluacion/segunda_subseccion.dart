import 'package:flutter/material.dart';

class SegundaSubseccion extends StatelessWidget {
  final int? evaluacionId;
  final Future<void> Function(String, int) onEventoSeleccionado;
  final VoidCallback onContinue; // Añadido

  // Constructor actualizado
  SegundaSubseccion({
    super.key,
    required this.evaluacionId,
    required this.onEventoSeleccionado,
    required this.onContinue, // Añadido
  });

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
                return GestureDetector(
                  onTap: () async {
                    if (evaluacionId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor guarda los datos generales antes de seleccionar un evento.'),
                        ),
                      );
                      return;
                    }

                    await onEventoSeleccionado(evento['label'], evento['tipoEventoId']);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.yellow, width: 2),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
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
                              color: Colors.blue, // Color azul al ícono
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
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF002855),
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
          // Botón Continuar modificado
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: evaluacionId == null 
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor complete y guarde los datos generales primero'),
                        ),
                      );
                    }
                  : onContinue,
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