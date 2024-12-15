import 'package:flutter/material.dart';
import '../../../utils/database_helper.dart';

class AccionesRecomendadasScreenParte2 extends StatefulWidget {
  final int evaluacionId;
  final int evaluacionEdificioId;

  const AccionesRecomendadasScreenParte2({
    Key? key,
    required this.evaluacionId,
    required this.evaluacionEdificioId,
  }) : super(key: key);

  @override
  _AccionesRecomendadasScreenParte2State createState() => _AccionesRecomendadasScreenParte2State();
}

class _AccionesRecomendadasScreenParte2State extends State<AccionesRecomendadasScreenParte2> {
  List<Map<String, dynamic>> acciones = []; 
  Map<int, bool> seleccion = {};
  TextEditingController cualCtrl = TextEditingController(); // Por si hay un campo "¿Cuál?"

  @override
  void initState() {
    super.initState();
    _cargarAcciones();
  }

  Future<void> _cargarAcciones() async {
    final db = DatabaseHelper();
    final todas = await db.obtenerAccionesRecomendadas();
    // Supongamos que aquí vienen las acciones restantes (parte 2)
    // Si teníamos 8 acciones totales y en parte 1 mostramos 4, aquí mostramos las otras 4
    if (todas.length > 4) {
      acciones = todas.sublist(4);
    }
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

    if (cualCtrl.text.isNotEmpty) {
      // Guardar el texto adicional en EvaluacionAccionDetalle si corresponde
      // Debes tener una accion_recomendada_id para "Otro" o algo similar
      // Suponiendo id= X para "Otro"
      // await db.insert('EvaluacionAccionDetalle', {
      //   'evaluacion_id': widget.evaluacionId,
      //   'accion_recomendada_id': X,
      //   'detalle': cualCtrl.text
      // });
    }

    // Navegar a la siguiente pantalla (finalizar o lo que siga)
    Navigator.pop(context); // O ir a otra pantalla final
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('8.2 Recomendaciones y Medidas (Parte 2)'),
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
          SizedBox(height: 8),
          TextField(
            controller: cualCtrl,
            decoration: InputDecoration(labelText: '¿Cuál?'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _guardarSeleccion,
            child: Text('Guardar y Finalizar'),
          )
        ],
      ),
    );
  }
}
