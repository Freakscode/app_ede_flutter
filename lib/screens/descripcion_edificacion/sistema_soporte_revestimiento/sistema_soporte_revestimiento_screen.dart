import 'package:flutter/material.dart';
import '../widgets/opcion_checkbox.dart';
import '../widgets/opcion_otro_texto.dart';
import '../sistemas_entrepiso_cubierta/sistemas_entrepiso_cubierta_screen.dart'; // Importar la siguiente pantalla
import '../../../utils/database_helper.dart';

class SistemaSoporteRevestimientoScreen extends StatefulWidget {
  final int evaluacionId;
  final int evaluacionEdificioId;

  const SistemaSoporteRevestimientoScreen({
    super.key,
    required this.evaluacionId,
    required this.evaluacionEdificioId,
  });

  @override
  State<SistemaSoporteRevestimientoScreen> createState() =>
      _SistemaSoporteRevestimientoScreenState();
}

class _SistemaSoporteRevestimientoScreenState
    extends State<SistemaSoporteRevestimientoScreen> {
  bool _metalico = false;
  bool _madera = false;
  bool _mixto = false;
  bool _otroSoporte = false;
  final TextEditingController _otroSoporteController = TextEditingController();

  bool _vidrio = false;
  bool _fibrocemento = false;
  bool _acrilico = false;
  bool _otroRevestimiento = false;
  final TextEditingController _otroRevestimientoController =
      TextEditingController();

  @override
  void dispose() {
    _otroSoporteController.dispose();
    _otroRevestimientoController.dispose();
    super.dispose();
  }

  void _guardarYContinuar() async {
    final db = DatabaseHelper();
    await db.insertarSistemaCubierta({
      'evaluacion_edificio_id': widget.evaluacionEdificioId,
      'tipo_soporte_id': _metalico ? 1 : (_madera ? 2 : (_mixto ? 3 : null)),
      'revestimiento_id':
          _vidrio ? 1 : (_fibrocemento ? 2 : (_acrilico ? 3 : null)),
      'otro_soporte': _otroSoporte ? _otroSoporteController.text : null,
      'otro_revestimiento':
          _otroRevestimiento ? _otroRevestimientoController.text : null,
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SistemasEntrepisoCubiertaScreen(
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
        title: const Text('Sistema de Soporte y Revestimiento'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              '3.3.4 Sistema de Soporte',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            OpcionCheckbox(
              label: 'Metálico',
              value: _metalico,
              onChanged: (value) => setState(() => _metalico = value!),
            ),
            OpcionCheckbox(
              label: 'Madera',
              value: _madera,
              onChanged: (value) => setState(() => _madera = value!),
            ),
            OpcionCheckbox(
              label: 'Mixto',
              value: _mixto,
              onChanged: (value) => setState(() => _mixto = value!),
            ),
            OpcionCheckbox(
              label: 'Otro: Especificar',
              value: _otroSoporte,
              onChanged: (value) => setState(() => _otroSoporte = value!),
            ),
            OpcionOtroTexto(
              visible: _otroSoporte,
              controller: _otroSoporteController,
            ),
            const Divider(),
            const Text(
              '3.3.5 Revestimiento',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            OpcionCheckbox(
              label: 'Vidrio',
              value: _vidrio,
              onChanged: (value) => setState(() => _vidrio = value!),
            ),
            OpcionCheckbox(
              label: 'Fibrocemento',
              value: _fibrocemento,
              onChanged: (value) => setState(() => _fibrocemento = value!),
            ),
            OpcionCheckbox(
              label: 'Acrílico',
              value: _acrilico,
              onChanged: (value) => setState(() => _acrilico = value!),
            ),
            OpcionCheckbox(
              label: 'Otro: Especificar',
              value: _otroRevestimiento,
              onChanged: (value) => setState(() => _otroRevestimiento = value!),
            ),
            OpcionOtroTexto(
              visible: _otroRevestimiento,
              controller: _otroRevestimientoController,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guardarYContinuar,
              child: const Text('Guardar y Continuar'),
            ),
          ],
        ),
      ),
    );
  }
}
