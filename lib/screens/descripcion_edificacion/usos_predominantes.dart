import 'package:flutter/material.dart';
import 'widgets/opcion_checkbox.dart';
import 'sistema_estructural_material/sistema_estructural_material_screen.dart';
import '../../utils/database_helper.dart';

class UsosPredominantesScreen extends StatefulWidget {
  final int evaluacionId;
  final int evaluacionEdificioId;

  const UsosPredominantesScreen({
    super.key,
    required this.evaluacionId,
    required this.evaluacionEdificioId,
  });

  @override
  State<UsosPredominantesScreen> createState() => _UsosPredominantesScreenState();
}

class _UsosPredominantesScreenState extends State<UsosPredominantesScreen> {
  // Usos Predominantes (puedes cargarlos dinámicamente desde la BD)
  bool _residencial = false;
  bool _educativo = false;
  bool _institucional = false;
  bool _industrial = false;
  bool _comercial = false;
  bool _oficina = false;
  bool _salud = false;
  bool _seguridad = false;
  bool _almacenamiento = false;
  bool _reunion = false;
  bool _parqueaderos = false;
  bool _serviciosPublicos = false;
  bool _otroUso = false;
  final TextEditingController _otroUsoController = TextEditingController();

  // Fecha de diseño o construcción ya seleccionada en la sección 3.1, 
  // aquí podría ser nuevamente si es necesario o simplemente omitirse si ya está definida.
  // Si se requiere otro campo fecha aquí, puedes agregarlo:
  String? _fechaConstruccion = 'Desconocida';

  @override
  void dispose() {
    _otroUsoController.dispose();
    super.dispose();
  }

  void _guardarYContinuar() async {
  final db = DatabaseHelper();
  final usos = {
    'residencial': _residencial,
    'educativo': _educativo,
    'comercial': _comercial,
    'industrial': _industrial,
    'almacenamiento': _almacenamiento,
    'reunion': _reunion,
    'parqueaderos': _parqueaderos,
    'servicios_publicos': _serviciosPublicos,
  };

  // Guardar los usos seleccionados
  for (var uso in usos.entries) {
    if (uso.value) {
      await db.insertarEvaluacionUso({
        'evaluacion_edificio_id': widget.evaluacionEdificioId,
        'uso_predominante_id': await db.obtenerIdUsoPorDescripcion(uso.key),
        'fecha_construccion': _fechaConstruccion,
      });
    }
  }

  if (_otroUso) {
    await db.insertarEvaluacionUso({
      'evaluacion_edificio_id': widget.evaluacionEdificioId,
      'uso_predominante_id': await db.obtenerIdUsoPorDescripcion('otro'),
      'otro_uso': _otroUsoController.text,
      'fecha_construccion': _fechaConstruccion,
    });
  }

  // Obtener los datos guardados
  final caracteristicasGenerales = await db.obtenerCaracteristicasGenerales(widget.evaluacionEdificioId);
  final evaluacionUsos = await db.obtenerEvaluacionUsos(widget.evaluacionEdificioId);

  // Imprimir los datos en consola
  print('Caracteristicas Generales: $caracteristicasGenerales');
  print('Usos Predominantes: $evaluacionUsos');

  // Navegar a la siguiente pantalla, pasando los datos
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SistemaEstructuralMaterialScreen(
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
        title: const Text('3.2 Usos Predominantes'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            OpcionCheckbox(
              label: 'Residencial',
              value: _residencial,
              onChanged: (v) => setState(() => _residencial = v!),
            ),
            OpcionCheckbox(
              label: 'Educativo',
              value: _educativo,
              onChanged: (v) => setState(() => _educativo = v!),
            ),
            OpcionCheckbox(
              label: 'Institucional',
              value: _institucional,
              onChanged: (v) => setState(() => _institucional = v!),
            ),
            OpcionCheckbox(
              label: 'Industrial',
              value: _industrial,
              onChanged: (v) => setState(() => _industrial = v!),
            ),
            OpcionCheckbox(
              label: 'Comercial',
              value: _comercial,
              onChanged: (v) => setState(() => _comercial = v!),
            ),
            OpcionCheckbox(
              label: 'Oficina',
              value: _oficina,
              onChanged: (v) => setState(() => _oficina = v!),
            ),
            OpcionCheckbox(
              label: 'Salud',
              value: _salud,
              onChanged: (v) => setState(() => _salud = v!),
            ),
            OpcionCheckbox(
              label: 'Seguridad',
              value: _seguridad,
              onChanged: (v) => setState(() => _seguridad = v!),
            ),
            OpcionCheckbox(
              label: 'Almacenamiento',
              value: _almacenamiento,
              onChanged: (v) => setState(() => _almacenamiento = v!),
            ),
            OpcionCheckbox(
              label: 'Reunión',
              value: _reunion,
              onChanged: (v) => setState(() => _reunion = v!),
            ),
            OpcionCheckbox(
              label: 'Parqueaderos',
              value: _parqueaderos,
              onChanged: (v) => setState(() => _parqueaderos = v!),
            ),
            OpcionCheckbox(
              label: 'Servicios Públicos',
              value: _serviciosPublicos,
              onChanged: (v) => setState(() => _serviciosPublicos = v!),
            ),
            OpcionCheckbox(
              label: 'Otro: Especificar',
              value: _otroUso,
              onChanged: (v) => setState(() => _otroUso = v!),
            ),
            Visibility(
              visible: _otroUso,
              child: TextField(
                controller: _otroUsoController,
                decoration: const InputDecoration(labelText: 'Otro uso'),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Fecha de diseño o construcción (si aplica):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _fechaConstruccion,
              onChanged: (value) => setState(() => _fechaConstruccion = value),
              items: const [
                DropdownMenuItem(value: 'Antes de 1984', child: Text('Antes de 1984')),
                DropdownMenuItem(value: 'Entre 1984 y 1997', child: Text('Entre 1984 y 1997')),
                DropdownMenuItem(value: 'Entre 1998 y 2010', child: Text('Entre 1998 y 2010')),
                DropdownMenuItem(value: 'Después de 2010', child: Text('Después de 2010')),
                DropdownMenuItem(value: 'Desconocida', child: Text('Desconocida')),
              ],
            ),

            const SizedBox(height: 30),
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
