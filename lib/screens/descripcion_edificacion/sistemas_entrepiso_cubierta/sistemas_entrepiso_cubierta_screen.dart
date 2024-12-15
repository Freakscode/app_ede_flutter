import 'package:flutter/material.dart';
import '../widgets/opcion_checkbox.dart';
import '../widgets/opcion_otro_texto.dart';
import '../elementos_no_estructurales/elementos_no_estructurales_screen.dart';
import '../../../utils/database_helper.dart';

class SistemasEntrepisoCubiertaScreen extends StatefulWidget {
  final int evaluacionId;
  final int evaluacionEdificioId;

  const SistemasEntrepisoCubiertaScreen({
    super.key,
    required this.evaluacionId,
    required this.evaluacionEdificioId,
  });

  @override
  State<SistemasEntrepisoCubiertaScreen> createState() =>
      _SistemasEntrepisoCubiertaScreenState();
}

class _SistemasEntrepisoCubiertaScreenState
    extends State<SistemasEntrepisoCubiertaScreen> {
  bool _losasMacizas = false;
  bool _losasAligeradas = false;
  bool _entrepisosMadera = false;
  bool _entrepisosMetalicos = false;
  bool _otroEntrepiso = false;
  final TextEditingController _otroEntrepisoController =
      TextEditingController();

  bool _tejado = false;
  bool _placaCubierta = false;
  bool _cubiertaMetalica = false;
  bool _otroCubierta = false;
  final TextEditingController _otroCubiertaController = TextEditingController();

  @override
  void dispose() {
    _otroEntrepisoController.dispose();
    _otroCubiertaController.dispose();
    super.dispose();
  }

  void _guardarYContinuar() async {
    final db = DatabaseHelper();
    await db.insertarSistemaEntrepiso({
      'evaluacion_edificio_id': widget.evaluacionEdificioId,
      'losas_macizas': _losasMacizas ? 1 : 0,
      'losas_aligeradas': _losasAligeradas ? 1 : 0,
      'entrepisos_madera': _entrepisosMadera ? 1 : 0,
      'entrepisos_metalicos': _entrepisosMetalicos ? 1 : 0,
      'otro_entrepiso': _otroEntrepiso ? _otroEntrepisoController.text : null,
      'tejado': _tejado ? 1 : 0,
      'placa_cubierta': _placaCubierta ? 1 : 0,
      'cubierta_metalica': _cubiertaMetalica ? 1 : 0,
      'otro_cubierta': _otroCubierta ? _otroCubiertaController.text : null,
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ElementosNoEstructuralesScreen(
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
        title: const Text('Sistemas Entrepiso y Cubierta'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              '3.3.3 Sistemas Entrepiso',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            OpcionCheckbox(
              label: 'Losas Macizas',
              value: _losasMacizas,
              onChanged: (value) => setState(() => _losasMacizas = value!),
            ),
            OpcionCheckbox(
              label: 'Losas Aligeradas',
              value: _losasAligeradas,
              onChanged: (value) => setState(() => _losasAligeradas = value!),
            ),
            OpcionCheckbox(
              label: 'Entrepisos de Madera',
              value: _entrepisosMadera,
              onChanged: (value) => setState(() => _entrepisosMadera = value!),
            ),
            OpcionCheckbox(
              label: 'Entrepisos Metálicos',
              value: _entrepisosMetalicos,
              onChanged: (value) =>
                  setState(() => _entrepisosMetalicos = value!),
            ),
            OpcionCheckbox(
              label: 'Otro: Especificar',
              value: _otroEntrepiso,
              onChanged: (value) => setState(() => _otroEntrepiso = value!),
            ),
            OpcionOtroTexto(
              visible: _otroEntrepiso,
              controller: _otroEntrepisoController,
            ),
            const Divider(),
            const Text(
              '3.3.4 Sistemas de Cubierta',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            OpcionCheckbox(
              label: 'Tejado',
              value: _tejado,
              onChanged: (value) => setState(() => _tejado = value!),
            ),
            OpcionCheckbox(
              label: 'Placa Cubierta',
              value: _placaCubierta,
              onChanged: (value) => setState(() => _placaCubierta = value!),
            ),
            OpcionCheckbox(
              label: 'Cubierta Metálica',
              value: _cubiertaMetalica,
              onChanged: (value) => setState(() => _cubiertaMetalica = value!),
            ),
            OpcionCheckbox(
              label: 'Otro: Especificar',
              value: _otroCubierta,
              onChanged: (value) => setState(() => _otroCubierta = value!),
            ),
            OpcionOtroTexto(
              visible: _otroCubierta,
              controller: _otroCubiertaController,
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
