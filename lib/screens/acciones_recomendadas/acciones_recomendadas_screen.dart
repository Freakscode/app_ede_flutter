import 'package:flutter/material.dart';
import '../../utils/database_helper.dart';
import '../resumen_evaluacion_screen.dart';

class RecomendacionesMedidasScreen extends StatefulWidget {
  final int evaluacionEdificioId;
  final int evaluacionId;
  final int userId;// Agregar este parámetro

  const RecomendacionesMedidasScreen({
    Key? key,
    required this.evaluacionEdificioId,
    required this.evaluacionId, 
    required this.userId// Agregar al constructor
  }) : super(key: key);

  @override
  _RecomendacionesMedidasScreenState createState() => _RecomendacionesMedidasScreenState();
}

class _RecomendacionesMedidasScreenState extends State<RecomendacionesMedidasScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Recomendaciones
  bool restriccionPasoPeatones = false;
  bool restriccionPasoVehiculos = false;
  bool evacuarParcial = false;
  bool evacuarTotal = false;
  bool evacuarEdificiosVecinos = false;
  bool establecerVigilancia = false;
  bool monitoreoEstructural = false;
  bool aislamiento = false;
  TextEditingController aislamientoController = TextEditingController();
  bool apuntalar = false;
  bool demoler = false;
  bool manejoSustancias = false;
  bool desconectarServicios = false;
  bool seguimiento = false;
  bool intervencionPlaneacion = false;
  bool intervencionBomberos = false;
  bool intervencionPolicia = false;
  bool intervencionEjercito = false;
  bool intervencionTransito = false;
  bool intervencionRescate = false;
  bool intervencionOtro = false;
  TextEditingController intervencionOtroController = TextEditingController();
  bool cual = false;
  TextEditingController cualController = TextEditingController();

  Future<void> _guardarRecomendaciones() async {
    Map<String, dynamic> datos = {
      'evaluacion_edificio_id': widget.evaluacionEdificioId,
      'restriccion_paso_peatones': restriccionPasoPeatones ? 1 : 0,
      'restriccion_paso_vehiculos': restriccionPasoVehiculos ? 1 : 0,
      'evacuar_parcial': evacuarParcial ? 1 : 0,
      'evacuar_total': evacuarTotal ? 1 : 0,
      'evacuar_edificios_vecinos': evacuarEdificiosVecinos ? 1 : 0,
      'establecer_vigilancia': establecerVigilancia ? 1 : 0,
      'monitoreo_estructural': monitoreoEstructural ? 1 : 0,
      'aislamiento': aislamiento ? 1 : 0,
      'detalle_aislamiento': aislamiento ? aislamientoController.text : '',
      'apuntalar': apuntalar ? 1 : 0,
      'demoler': demoler ? 1 : 0,
      'manejo_sustancias': manejoSustancias ? 1 : 0,
      'desconectar_servicios': desconectarServicios ? 1 : 0,
      'seguimiento': seguimiento ? 1 : 0,
      'intervencion_planeacion': intervencionPlaneacion ? 1 : 0,
      'intervencion_bomberos': intervencionBomberos ? 1 : 0,
      'intervencion_policia': intervencionPolicia ? 1 : 0,
      'intervencion_ejercito': intervencionEjercito ? 1 : 0,
      'intervencion_transito': intervencionTransito ? 1 : 0,
      'intervencion_rescate': intervencionRescate ? 1 : 0,
      'intervencion_otro': intervencionOtro ? 1 : 0,
      'detalle_intervencion_otro': intervencionOtro ? intervencionOtroController.text : '',
      'cual': cual ? 1 : 0,
      'detalle_cual': cual ? cualController.text : '',
    };

    await _dbHelper.insertarRecomendacionesMedidas(datos);

    // Mostrar mensaje de éxito
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recomendaciones guardadas correctamente.')),
    );

    // Navegar a ResumenEvaluacionScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResumenEvaluacionScreen(
          evaluacionId: widget.evaluacionId,
          userId: widget.userId,
                    
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recomendaciones y Medidas'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recomendaciones y Medidas de Seguridad',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Lista de recomendaciones
            CheckboxListTile(
              title: const Text('Restringir paso de peatones'),
              value: restriccionPasoPeatones,
              onChanged: (val) {
                setState(() {
                  restriccionPasoPeatones = val!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Restringir paso de vehículos pesados'),
              value: restriccionPasoVehiculos,
              onChanged: (val) {
                setState(() {
                  restriccionPasoVehiculos = val!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Evacuar parcialmente la edificación'),
              value: evacuarParcial,
              onChanged: (val) {
                setState(() {
                  evacuarParcial = val!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Evacuar totalmente la edificación'),
              value: evacuarTotal,
              onChanged: (val) {
                setState(() {
                  evacuarTotal = val!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Evacuar edificaciones vecinas'),
              value: evacuarEdificiosVecinos,
              onChanged: (val) {
                setState(() {
                  evacuarEdificiosVecinos = val!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Establecer vigilancia permanente'),
              value: establecerVigilancia,
              onChanged: (val) {
                setState(() {
                  establecerVigilancia = val!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Monitoreo estructural'),
              value: monitoreoEstructural,
              onChanged: (val) {
                setState(() {
                  monitoreoEstructural = val!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Aislamiento en las siguientes áreas:'),
              value: aislamiento,
              onChanged: (val) {
                setState(() {
                  aislamiento = val!;
                });
              },
            ),
            if (aislamiento)
              TextField(
                controller: aislamientoController,
                decoration: const InputDecoration(
                  labelText: 'Especificar áreas a aislar',
                  border: OutlineInputBorder(),
                ),
              ),
            CheckboxListTile(
              title: const Text('Apuntalar o asegurar elementos en riesgo de caer'),
              value: apuntalar,
              onChanged: (val) {
                setState(() {
                  apuntalar = val!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Demoler elementos en peligro de caer'),
              value: demoler,
              onChanged: (val) {
                setState(() {
                  demoler = val!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Manejo de sustancias peligrosas'),
              value: manejoSustancias,
              onChanged: (val) {
                setState(() {
                  manejoSustancias = val!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Desconectar servicios públicos'),
              value: desconectarServicios,
              onChanged: (val) {
                setState(() {
                  desconectarServicios = val!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Seguimiento'),
              value: seguimiento,
              onChanged: (val) {
                setState(() {
                  seguimiento = val!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Intervención de entidades
            const Text(
              'Intervención de entidades:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            CheckboxListTile(
              title: const Text('Planeación'),
              value: intervencionPlaneacion,
              onChanged: (val) {
                setState(() {
                  intervencionPlaneacion = val!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Bomberos'),
              value: intervencionBomberos,
              onChanged: (val) {
                setState(() {
                  intervencionBomberos = val!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Policía'),
              value: intervencionPolicia,
              onChanged: (val) {
                setState(() {
                  intervencionPolicia = val!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Ejército'),
              value: intervencionEjercito,
              onChanged: (val) {
                setState(() {
                  intervencionEjercito = val!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Tránsito'),
              value: intervencionTransito,
              onChanged: (val) {
                setState(() {
                  intervencionTransito = val!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Entidades de rescate'),
              value: intervencionRescate,
              onChanged: (val) {
                setState(() {
                  intervencionRescate = val!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Otro'),
              value: intervencionOtro,
              onChanged: (val) {
                setState(() {
                  intervencionOtro = val!;
                });
              },
            ),
            if (intervencionOtro)
              TextField(
                controller: intervencionOtroController,
                decoration: const InputDecoration(
                  labelText: 'Especificar otra entidad',
                  border: OutlineInputBorder(),
                ),
              ),
            const SizedBox(height: 16),

            // ¿Cuál?
            CheckboxListTile(
              title: const Text('¿Cuál?'),
              value: cual,
              onChanged: (val) {
                setState(() {
                  cual = val!;
                });
              },
            ),
            if (cual)
              TextField(
                controller: cualController,
                decoration: const InputDecoration(
                  labelText: 'Detalle de acciones específicas adicionales',
                  border: OutlineInputBorder(),
                ),
              ),
            const SizedBox(height: 20),

            // Botón Guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardarRecomendaciones,
                child: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}