import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/database_helper.dart';
import 'primera_subseccion.dart';
import 'segunda_subseccion.dart';
import '../identificacion_edificacion/identificacion_edificacion_screen.dart';

class IdentificacionEvaluacionScreen extends StatefulWidget {
  final int userId; // Publico ya que es final y está en una clase pública

  const IdentificacionEvaluacionScreen({super.key, required this.userId});

  @override
  // ignore: library_private_types_in_public_api
  _IdentificacionEvaluacionScreenState createState() =>
      _IdentificacionEvaluacionScreenState();
}

class _IdentificacionEvaluacionScreenState
    extends State<IdentificacionEvaluacionScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  int _currentIndex = 0;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();
  final TextEditingController _nombreEvaluadorController =
      TextEditingController();
  final TextEditingController _dependenciaController = TextEditingController();
  final TextEditingController _idGrupoController = TextEditingController();
  final ValueNotifier<ImageProvider?> _firmaImageNotifier = ValueNotifier<ImageProvider?>(null);
  File? _firmaFile; // Para almacenar el archivo de la firma

  // Para la firma, se puede implementar un widget de captura de firma

  int? _evaluacionId; // Variable de estado para almacenar el ID de la evaluación

  @override
  void dispose() {
    _fechaController.dispose();
    _horaController.dispose();
    _nombreEvaluadorController.dispose();
    _dependenciaController.dispose();
    _idGrupoController.dispose();
    _firmaImageNotifier.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _fechaController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() {
        _horaController.text = picked.format(context);
      });
    }
  }

  // Método para convertir File a Uint8List
  Future<Uint8List?> _fileToBytes(File? file) async {
    if (file == null) return null;
    return await file.readAsBytes();
  }

  // Método para subir firma
  Future<void> _subirFirma() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        _firmaFile = File(image.path);
        _firmaImageNotifier.value = FileImage(_firmaFile!);
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir la firma: $e')),
      );
    }
  }

  // Método actualizado para guardar evaluación
  Future<void> _guardarEvaluacion() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Convertir firma a bytes si existe
        final Uint8List? firmaBytes = await _fileToBytes(_firmaFile);

        Map<String, dynamic> nuevaEvaluacion = {
          'eventoId': DateTime.now().millisecondsSinceEpoch,
          'usuario_id': widget.userId,
          'fecha_inspeccion': _fechaController.text,
          'hora': _horaController.text,
          'dependencia_entidad': _dependenciaController.text,
          'id_grupo': _idGrupoController.text,
          'firma': firmaBytes,
          'tipo_evento_id': 0,
        };

        int evaluacionId = await _dbHelper.insertarEvaluacion(nuevaEvaluacion);

        setState(() {
          _evaluacionId = evaluacionId;
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evaluación guardada exitosamente')),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar la evaluación: $e')),
        );
      }
    }
  }

  Future<void> _handleEventoSeleccionado(String label, int tipoEventoId) async {
    if (_evaluacionId == null) return;

    await _dbHelper.actualizarEvaluacion(_evaluacionId!, {
      'tipo_evento_id': tipoEventoId,
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Evento $label seleccionado')),
    );

    // Opcional: Puedes navegar de vuelta o realizar otra acción
  }

  void _previsualizar() {
    if (_formKey.currentState!.validate()) {
      // Implementa la lógica de previsualización
      // Puede navegar a una pantalla de resumen o mostrar un diálogo con los datos ingresados
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Previsualización'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nombre del Evaluador: ${_nombreEvaluadorController.text}'),
              Text('ID Evento: ${_fechaController.text}'),
              Text('ID Grupo: ${_idGrupoController.text}'),
              Text('Dependencia / Entidad: ${_dependenciaController.text}'),
              // Añade más campos si es necesario
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    }
  }

  // Método actualizado para guardar y continuar
  Future<void> guardarYContinuar() async {
    try {
      if (!_formKey.currentState!.validate()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor complete todos los campos requeridos')),
        );
        return;
      }

      // Convertir firma a bytes si existe
      final Uint8List? firmaBytes = await _fileToBytes(_firmaFile);

      Map<String, dynamic> nuevaEvaluacion = {
        'eventoId': DateTime.now().millisecondsSinceEpoch,
        'usuario_id': widget.userId,
        'fecha_inspeccion': _fechaController.text,
        'hora': _horaController.text,
        'dependencia_entidad': _dependenciaController.text,
        'id_grupo': _idGrupoController.text,
        'firma': firmaBytes,
        'tipo_evento_id': 0,
      };

      int evaluacionId = await _dbHelper.insertarEvaluacion(nuevaEvaluacion);

      setState(() {
        _evaluacionId = evaluacionId;
      });

      if (!mounted) return;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IdentificacionEdificacionScreen(
            evaluacionId: evaluacionId,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Identificación de Evaluación'),
        backgroundColor: const Color(0xFF002855),
      ),
      body: _currentIndex == 0
          ? PrimeraSubseccion(
              formKey: _formKey,
              fechaController: _fechaController,
              horaController: _horaController,
              nombreEvaluadorController: _nombreEvaluadorController,
              dependenciaController: _dependenciaController,
              idGrupoController: _idGrupoController,
              onGuardar: _guardarEvaluacion,
              selectDate: _selectDate,
              selectTime: _selectTime,
              onPrevisualizar: _previsualizar,
              firmaImageNotifier: _firmaImageNotifier,
              onSubirFirma: _subirFirma, // Pasar el método de subir firma
            )
          : SegundaSubseccion(
              evaluacionId: _evaluacionId,
              onEventoSeleccionado: _handleEventoSeleccionado,
              onContinue: guardarYContinuar, // Añadido
            ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onTabTapped,
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Datos Generales',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Tipo de Evento',
          ),
        ],
      ),
    );
  }
}