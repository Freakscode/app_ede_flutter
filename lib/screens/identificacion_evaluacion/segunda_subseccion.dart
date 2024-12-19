import 'package:flutter/material.dart';

class SegundaSubseccion extends StatefulWidget {
  final Future<void> Function(String, int) onEventoSeleccionado;
  final VoidCallback onContinue;
  final int? selectedEventoId;
  final Function(int?, String?) onTipoEventoActualizado;
  final TextEditingController otroEvento;

  const SegundaSubseccion({
    super.key,
    required this.onEventoSeleccionado,
    required this.onContinue,
    required this.selectedEventoId,
    required this.onTipoEventoActualizado,
    required this.otroEvento,

  });

  @override
  _SegundaSubseccionState createState() => _SegundaSubseccionState();
}

class _SegundaSubseccionState extends State<SegundaSubseccion> {
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

  final TextEditingController _otroEventoController = TextEditingController();
  bool _mostrarCampoOtro = false;

  @override
  void dispose() {
    _otroEventoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'IDENTIFICACIÓN DE EVALUACIÓN',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF002855),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Seleccionar un solo evento',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.5,
              children: eventos.map((evento) {
                final isSelected = widget.selectedEventoId == evento['tipoEventoId'];
                return GestureDetector(
                  onTap: () async {
                    if (evento['tipoEventoId'] == 8) { // ID para "Otro"
                      setState(() => _mostrarCampoOtro = true);
                    } else {
                      setState(() => _mostrarCampoOtro = false);
                    }
                    widget.onTipoEventoActualizado(
                      evento['tipoEventoId'],
                      evento['tipoEventoId'] == 8 ? _otroEventoController.text : null
                    );
                    await widget.onEventoSeleccionado(
                      evento['tipoEventoId'] == 8 ? _otroEventoController.text : evento['label'],
                      evento['tipoEventoId']
                    );
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
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              evento['iconPath'],
                              color: Colors.blue,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            evento['label'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.blue : const Color(0xFF002855),
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

          if (_mostrarCampoOtro) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _otroEventoController,
              decoration: const InputDecoration(
                labelText: 'Especifique el tipo de evento',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) async {
                if (widget.selectedEventoId == 8) {
                  await widget.onEventoSeleccionado(value, 8);
                }
              },
            ),
          ],

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (widget.selectedEventoId == 8 && _otroEventoController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor, especifique el tipo de evento'),
                    ),
                  );
                  return;
                }
                widget.onContinue();
              },
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
