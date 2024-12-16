import 'package:flutter/material.dart';
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
  // Reemplazar los booleanos individuales por una sola variable
  String? _usoPredominante;
  final TextEditingController _otroUsoController = TextEditingController();
  String _fechaConstruccion = 'Desconocida';

  @override
  void dispose() {
    _otroUsoController.dispose();
    super.dispose();
  }

  void _guardarYContinuar() async {
    if (_usoPredominante == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un uso predominante'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    bool existenDatosCaracteristicas = await DatabaseHelper()
        .verificarCaracteristicasGenerales(widget.evaluacionEdificioId);

    if (!existenDatosCaracteristicas) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero debe guardar las características generales'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      final db = DatabaseHelper();
      
      // Guardar el uso seleccionado
      await db.insertarEvaluacionUso({
        'evaluacion_edificio_id': widget.evaluacionEdificioId,
        'uso_predominante_id': await db.obtenerIdUsoPorDescripcion(
          _usoPredominante == 'Otro' ? 'otro' : _usoPredominante!.toLowerCase()
        ),
        'otro_uso': _usoPredominante == 'Otro' ? _otroUsoController.text : null,
        'fecha_construccion': _fechaConstruccion,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos guardados correctamente')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SistemaEstructuralMaterialScreen(
            evaluacionId: widget.evaluacionId,
            evaluacionEdificioId: widget.evaluacionEdificioId,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar los datos')),
      );
    }
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seleccione el uso predominante:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...['Residencial', 'Educativo', 'Institucional', 'Industrial', 
                'Comercial', 'Oficina', 'Salud', 'Seguridad', 'Almacenamiento', 
                'Reunión', 'Parqueaderos', 'Servicios Públicos', 'Otro']
                .map((uso) => RadioListTile<String>(
                  title: Text(uso),
                  value: uso,
                  groupValue: _usoPredominante,
                  onChanged: (value) => setState(() => _usoPredominante = value),
                )),
            
            if (_usoPredominante == 'Otro')
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _otroUsoController,
                  decoration: const InputDecoration(
                    labelText: 'Especifique el otro uso',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

            const SizedBox(height: 20),
            const Text(
              'Fecha de diseño o construcción:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _fechaConstruccion,
              isExpanded: true,
              onChanged: (value) => setState(() => _fechaConstruccion = value!),
              items: const [
                DropdownMenuItem(value: 'Antes de 1984', child: Text('Antes de 1984')),
                DropdownMenuItem(value: 'Entre 1984 y 1997', child: Text('Entre 1984 y 1997')),
                DropdownMenuItem(value: 'Entre 1998 y 2010', child: Text('Entre 1998 y 2010')),
                DropdownMenuItem(value: 'Después de 2010', child: Text('Después de 2010')),
                DropdownMenuItem(value: 'Desconocida', child: Text('Desconocida')),
              ],
            ),

            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: _guardarYContinuar,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Guardar y Continuar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}