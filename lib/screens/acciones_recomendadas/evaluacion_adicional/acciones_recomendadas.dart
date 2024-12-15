import 'package:flutter/material.dart';
import '../../../utils/database_helper.dart';
import 'acciones_recomendadas_2.dart';

class AccionesRecomendadasScreenParte1 extends StatefulWidget {
  final int evaluacionId;
  final int evaluacionEdificioId;

  const AccionesRecomendadasScreenParte1({
    Key? key,
    required this.evaluacionId,
    required this.evaluacionEdificioId,
  }) : super(key: key);

  @override
  _AccionesRecomendadasScreenParte1State createState() => _AccionesRecomendadasScreenParte1State();
}

class _AccionesRecomendadasScreenParte1State extends State<AccionesRecomendadasScreenParte1> {
  List<Map<String, dynamic>> acciones = []; 
  // Estas deben venir de la BD. Ej: Restricción de paso, Evacuar parcialmente...

  Map<int, bool> seleccion = {};

  @override
  void initState() {
    super.initState();
    _cargarAcciones();
  }

  Future<void> _cargarAcciones() async {
    final db = DatabaseHelper();
    final todas = await db.obtenerAccionesRecomendadas();
    // Suponiendo que "parte 1" son las primeras N acciones
    // Por ejemplo, las primeras 4
    acciones = todas.length > 4 ? todas.sublist(0,4) : todas;
    for (var a in acciones) {
      seleccion[a['id']] = false;
    }
    setState(() {});
  }

  Future<void> _guardarSeleccion() async {
    final db = DatabaseHelper();
    for (var a in acciones) {
      if (seleccion[a['id']] == true) {
        await db.insertarEvaluacionAccion({
          'evaluacion_id': widget.evaluacionId,
          'accion_recomendada_id': a['id']
        });
      }
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccionesRecomendadasScreenParte2(
          evaluacionId: widget.evaluacionId,
          evaluacionEdificioId: widget.evaluacionEdificioId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('8.2 Recomendaciones y Medidas (Parte 1)'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          ...acciones.map((a) => CheckboxListTile(
            title: Text(a['descripcion']),
            value: seleccion[a['id']],
            onChanged: (val) {
              setState(() {
                seleccion[a['id']] = val ?? false;
              });
            },
          )).toList(),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _guardarSeleccion,
            child: Text('Guardar y Continuar a Parte 2'),
          )
        ],
      ),
    );
  }
}
