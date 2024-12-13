// ignore_for_file: unused_element

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
  final int userId; // Público ya que es final y está en una clase pública

  const IdentificacionEvaluacionScreen({super.key, required this.userId});

  @override
  // ignore: library_private_types_in_public_api
  _IdentificacionEvaluacionScreenState createState() =>
      _IdentificacionEvaluacionScreenState();
}

// Eliminar _evaluacionId ya que no lo necesitamos más
class _IdentificacionEvaluacionScreenState extends State<IdentificacionEvaluacionScreen> {
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
  int? _selectedEventoId;

  // Añadir variable para almacenar datos temporalmente
  // ignore: unused_field
  Map<String, dynamic>? _datosTemporales;

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

  // Eliminar validación en _onTabTapped para permitir cambiar de pestaña libremente
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

  // Modificar _guardarEvaluacion para ya no cambiar de pestaña
  Future<void> _guardarEvaluacion() async {
    // Ya no necesitamos este método para cambiar de pestaña
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
              Text('Fecha de Inspección: ${_fechaController.text}'),
              Text('Hora: ${_horaController.text}'),
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

  // Modificar guardarYContinuar para validar y guardar todo junto
  Future<void> guardarYContinuar() async {
    // Validar datos de la primera subsección
    if (!_formKey.currentState!.validate()) {
      setState(() => _currentIndex = 0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor complete los datos generales')),
      );
      return;
    }

    // Verificar si se seleccionó un evento
    if (_selectedEventoId == null) {
      setState(() => _currentIndex = 1);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor seleccione un tipo de evento')),
      );
      return;
    }

    try {
      final Uint8List? firmaBytes = await _fileToBytes(_firmaFile);
      
      // Crear mapa con todos los datos
      final Map<String, dynamic> evaluacionData = {
        'eventoId': DateTime.now().millisecondsSinceEpoch,
        'usuario_id': widget.userId,
        'fecha_inspeccion': _fechaController.text,
        'hora': _horaController.text,
        'dependencia_entidad': _dependenciaController.text,
        'id_grupo': _idGrupoController.text,
        'firma': firmaBytes,
        'tipo_evento_id': _selectedEventoId,
      };
      
      // Guardar todo junto
      final evaluacionId = await _dbHelper.insertarEvaluacion(evaluacionData);

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

  // Simplificar el manejador de eventos
  Future<void> _handleEventoSeleccionado(String label, int tipoEventoId) async {
    setState(() {
      _selectedEventoId = tipoEventoId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Identificación de Evaluación'),
        backgroundColor: const Color(0xFF002855),
      ),
      // Modificar el cuerpo para permitir cambiar entre subsecciones sin restricciones
      body: IndexedStack(
        index: _currentIndex,
        children: [
          PrimeraSubseccion(
            formKey: _formKey,
            fechaController: _fechaController,
            horaController: _horaController,
            nombreEvaluadorController: _nombreEvaluadorController,
            dependenciaController: _dependenciaController,
            idGrupoController: _idGrupoController,
            selectDate: _selectDate,
            selectTime: _selectTime,
            firmaImageNotifier: _firmaImageNotifier,
            onSubirFirma: _subirFirma,
            onGuardar: _guardarEvaluacion, // Agrega este argumento
            onPrevisualizar: _previsualizar, // Y este también
          ),
          SegundaSubseccion(
            onEventoSeleccionado: _handleEventoSeleccionado,
            onContinue: guardarYContinuar,
            selectedEventoId: _selectedEventoId,
          ),
        ],
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
