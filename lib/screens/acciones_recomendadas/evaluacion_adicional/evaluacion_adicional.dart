import 'package:flutter/material.dart';
import '../../../utils/database_helper.dart';
import 'acciones_recomendadas.dart';

class EvaluacionAdicionalScreen extends StatefulWidget {
  final int evaluacionId;
  final int evaluacionEdificioId;

  const EvaluacionAdicionalScreen({
    Key? key,
    required this.evaluacionId,
    required this.evaluacionEdificioId,
  }) : super(key: key);

  @override
  _EvaluacionAdicionalScreenState createState() => _EvaluacionAdicionalScreenState();
}

class _EvaluacionAdicionalScreenState extends State<EvaluacionAdicionalScreen> {
  bool estructural = false;
  bool geotecnica = false;
  bool otra = false;
  TextEditingController otraCtrl = TextEditingController();

  Future<void> _guardarEvaluacionAdicional() async {
    final db = DatabaseHelper();

    if (estructural) {
      await db.insertarEvaluacionAdicional({
        'evaluacion_id': widget.evaluacionId,
        'tipo_evaluacion': 'Estructural',
        'detalle': null
      });
    }
    if (geotecnica) {
      await db.insertarDaniosEvaluacion({
        'evaluacion_id': widget.evaluacionId,
        'tipo_evaluacion': 'Geotécnica',
        'detalle': null
      });
    }
    if (otra && otraCtrl.text.isNotEmpty) {
      await db.insertarEvaluacionAdicional({
        'evaluacion_id': widget.evaluacionId,
        'tipo_evaluacion': 'Otro',
        'detalle': otraCtrl.text
      });
    }

    // Navegar a pantalla 8.2 (Parte 1)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccionesRecomendadasScreenParte1(
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
        title: Text('8.1 Evaluación Adicional'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            CheckboxListTile(
              title: Text('Estructural'),
              value: estructural,
              onChanged: (val) {
                setState(() {
                  estructural = val ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: Text('Geotécnica'),
              value: geotecnica,
              onChanged: (val) {
                setState(() {
                  geotecnica = val ?? false;
                });
              },
            ),
            Row(
              children: [
                Checkbox(
                  value: otra,
                  onChanged: (val) {
                    setState(() {
                      otra = val ?? false;
                    });
                  },
                ),
                Expanded(child: TextField(
                  controller: otraCtrl,
                  decoration: InputDecoration(labelText: 'Otra, ¿cuál?'),
                ))
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guardarEvaluacionAdicional,
              child: Text('Guardar y Continuar'),
            )
          ],
        ),
      ),
    );
  }
}
