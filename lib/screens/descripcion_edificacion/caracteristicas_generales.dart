import 'package:flutter/material.dart'; // Si necesitas este tipo de widget// Importar la siguiente pantalla (3.2)
import '../../utils/database_helper.dart';

class CaracteristicasGeneralesScreen extends StatefulWidget {
  final int evaluacionId;
  final int evaluacionEdificioId;

  const CaracteristicasGeneralesScreen({
    Key? key,
    required this.evaluacionId,
    required this.evaluacionEdificioId,
  }) : super(key: key);

  @override
  State<CaracteristicasGeneralesScreen> createState() =>
      _CaracteristicasGeneralesScreenState();
}

class _CaracteristicasGeneralesScreenState
    extends State<CaracteristicasGeneralesScreen> {
  // Campos numéricos y textos
  final TextEditingController _numeroPisosController = TextEditingController();
  final TextEditingController _numeroSotanosController =
      TextEditingController();
  final TextEditingController _frenteController = TextEditingController();
  final TextEditingController _fondoController = TextEditingController();
  final TextEditingController _unidadesResidencialesController =
      TextEditingController();
  final TextEditingController _unidadesNoHabitadasController =
      TextEditingController();
  final TextEditingController _unidadesComercialesController =
      TextEditingController();
  final TextEditingController _ocupantesController = TextEditingController();

  // Acceso (Obstruido/Libre)
  String? _acceso = 'Libre'; // Puede ser 'Obstruido' o 'Libre'

  // Muertos y Heridos (booleanos)
  int _muertos = 0;
  int _heridos = 0;

  // Fecha de construcción (Dropdown)
  // Por ejemplo: Antes de 1984, Entre 1984 y 1997, Entre 1998 y 2010, Después de 2010, Desconocida
  String? _fechaConstruccion = 'Desconocida';

  // Agregar variable para controlar estado de guardado
  // ignore: unused_field
  bool _datosGuardados = false;

  @override
  void dispose() {
    _numeroPisosController.dispose();
    _numeroSotanosController.dispose();
    _frenteController.dispose();
    _fondoController.dispose();
    _unidadesResidencialesController.dispose();
    _unidadesNoHabitadasController.dispose();
    _unidadesComercialesController.dispose();
    _ocupantesController.dispose();
    super.dispose();
  }

  Future<bool> _guardar() async {
    try {
      await DatabaseHelper().insertarCaracteristicasGenerales({
        'evaluacion_edificio_id': widget.evaluacionEdificioId,
        'numero_pisos': int.tryParse(_numeroPisosController.text),
        'numero_sotanos': int.tryParse(_numeroSotanosController.text),
        'frente': double.tryParse(_frenteController.text),
        'fondo': double.tryParse(_fondoController.text),
        'unidades_residenciales': int.tryParse(_unidadesResidencialesController.text),
        'unidades_no_habitadas': int.tryParse(_unidadesNoHabitadasController.text),
        'unidades_comerciales': int.tryParse(_unidadesComercialesController.text),
        'ocupantes': int.tryParse(_ocupantesController.text),
        'acceso': _acceso,
        'muertos': _muertos, 
        'heridos': _heridos, 
        'fecha_construccion': _fechaConstruccion,
      });
      setState(() => _datosGuardados = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos guardados correctamente')),
      );
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar los datos')),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3.1 Características Generales'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Número de pisos sobre el terreno:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
                controller: _numeroPisosController,
                keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            const Text(
              'Número de sótanos:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
                controller: _numeroSotanosController,
                keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            const Text('Dimensiones aproximadas:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('Frente (m):'),
            TextField(
                controller: _frenteController,
                keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            const Text('Fondo (m):'),
            TextField(
                controller: _fondoController,
                keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            const Text('Número de unidades residenciales:'),
            TextField(
                controller: _unidadesResidencialesController,
                keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            const Text('Número de unidades no habitadas:'),
            TextField(
                controller: _unidadesNoHabitadasController,
                keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            const Text('Número de unidades comerciales:'),
            TextField(
                controller: _unidadesComercialesController,
                keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            const Text('Número de ocupantes:'),
            TextField(
                controller: _ocupantesController,
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            const Text('Acceso a la edificación:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Radio<String>(
                  value: 'Obstruido',
                  groupValue: _acceso,
                  onChanged: (value) => setState(() => _acceso = value),
                ),
                const Text('Obstruido'),
                Radio<String>(
                  value: 'Libre',
                  groupValue: _acceso,
                  onChanged: (value) => setState(() => _acceso = value),
                ),
                const Text('Libre'),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Muertos:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Cantidad de muertos',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              initialValue: _muertos.toString(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese la cantidad de muertos';
                }
                final n = int.tryParse(value);
                if (n == null || n < 0) {
                  return 'Ingrese un número válido';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _muertos = int.tryParse(value) ?? 0;
                });
              },
            ),
            const SizedBox(height: 16), // Espacio entre campos
            const Text('Heridos:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Cantidad de heridos',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              initialValue: _heridos.toString(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese la cantidad de heridos';
                }
                final n = int.tryParse(value);
                if (n == null || n < 0) {
                  return 'Ingrese un número válido';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _heridos = int.tryParse(value) ?? 0;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text('Fecha de diseño o construcción:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _fechaConstruccion,
              onChanged: (value) => setState(() => _fechaConstruccion = value),
              items: const [
                DropdownMenuItem(
                    value: 'Antes de 1984', child: Text('Antes de 1984')),
                DropdownMenuItem(
                    value: 'Entre 1984 y 1997',
                    child: Text('Entre 1984 y 1997')),
                DropdownMenuItem(
                    value: 'Entre 1998 y 2010',
                    child: Text('Entre 1998 y 2010')),
                DropdownMenuItem(
                    value: 'Después de 2010', child: Text('Después de 2010')),
                DropdownMenuItem(
                    value: 'Desconocida', child: Text('Desconocida')),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _guardar,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}