import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/database_helper.dart';
import 'primera_subseccion.dart';
import 'segunda_subseccion.dart';
import '../identificacion_edificacion/identificacion_edificacion_screen.dart';
import '../../widgets/floating_navigation_menu.dart';

class IdentificacionEvaluacionScreen extends StatefulWidget {
  final int userId;

  const IdentificacionEvaluacionScreen({super.key, required this.userId});

  @override
  State<IdentificacionEvaluacionScreen> createState() =>
      _IdentificacionEvaluacionScreenState();
}

class _IdentificacionEvaluacionScreenState
    extends State<IdentificacionEvaluacionScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  int _currentIndex = 0;
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();
  final TextEditingController _nombreEvaluadorController =
      TextEditingController();
  final TextEditingController _dependenciaController = TextEditingController();
  final TextEditingController _idGrupoController = TextEditingController();
  final TextEditingController _eventoIdController = TextEditingController();

  final ValueNotifier<ImageProvider?> _firmaImageNotifier =
      ValueNotifier<ImageProvider?>(null);
  File? _firmaFile;

  int? _selectedEventoId;

  @override
  void dispose() {
    _fechaController.dispose();
    _horaController.dispose();
    _nombreEvaluadorController.dispose();
    _dependenciaController.dispose();
    _idGrupoController.dispose();
    _firmaImageNotifier.dispose();
    _eventoIdController.dispose();
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
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _horaController.text = picked.format(context);
      });
    }
  }

  Future<Uint8List?> _fileToBytes(File? file) async {
    if (file == null) return null;
    return await file.readAsBytes();
  }

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

  Future<void> _imprimirEvaluacionBasica(int evaluacionId) async {
    final resultado =
        await _dbHelper.getEvaluacionBasica(widget.userId, evaluacionId);
    if (resultado == null) {
      print('No se encontró la evaluación o no pertenece a este usuario.');
    } else {
      print('''
        Datos básicos de la evaluación:
        ID: ${resultado['id']}
        Fecha: ${resultado['fecha_inspeccion']}
        Hora: ${resultado['hora']}
        Evaluador: ${resultado['nombre_evaluador']}
        Tipo de Evento: ${resultado['tipo_evento_id'] == 8 ? '${resultado['otro_tipo_evento']} (Otro)' : resultado['descripcion_evento'] ?? 'No especificado'}
      ''');
    }
  }

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
      // Obtener la ruta de la firma
      final String? firmaPath = _firmaFile?.path;

      final Map<String, dynamic> evaluacionData = {
        'eventoId': DateTime.now().millisecondsSinceEpoch,
        'usuario_id': widget.userId,
        'fecha_inspeccion': _fechaController.text,
        'hora': _horaController.text,
        'dependencia_entidad': _dependenciaController.text.isEmpty
            ? null
            : _dependenciaController.text,
        'id_grupo':
            _idGrupoController.text.isEmpty ? null : _idGrupoController.text,
        'tipo_evento_id': _selectedEventoId,
        'nombre_evaluador': _nombreEvaluadorController.text.isEmpty
            ? null
            : _nombreEvaluadorController.text,
        'firma': firmaPath, // Guardar la ruta en lugar de los bytes
      };

      final evaluacionId = await _dbHelper.insertarEvaluacion(evaluacionData);

      if (!mounted) return;

      await _imprimirEvaluacionBasica(evaluacionId);

      // Mostrar un mensaje temporal para confirmar que se guardó
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Evaluación guardada con ID: $evaluacionId')),
      );

      // Navegar a la siguiente pantalla
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IdentificacionEdificacionScreen(
            evaluacionId: evaluacionId,
            userId: widget.userId,
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

  Future<void> _handleEventoSeleccionado(String label, int tipoEventoId) async {
    setState(() {
      _selectedEventoId = tipoEventoId;
    });
  }

  void _handleSectionSelected(int section) {
    // Primero validar datos actuales
    if (!_formKey.currentState!.validate() || _selectedEventoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete todos los campos antes de cambiar de sección')),
      );
      return;
    }

    // Guardar datos actuales
    _saveCurrentData().then((_) {
      // Navegar a la sección seleccionada
      switch (section) {
        case 1: // Identificación de la Evaluación
          // Ya estamos aquí
          break;
        case 2: // Identificación de la Edificación
          _navigateToEdificacion();
          break;
        case 3: // Descripción de la Edificación
          _navigateToDescripcion();
          break;
        // ... más casos para otras secciones
      }
    });
  }

  Future<void> _saveCurrentData() async {
    try {
      // Obtener la ruta de la firma
      final String? firmaPath = _firmaFile?.path;
      final evaluacionData = {
        'eventoId': DateTime.now().millisecondsSinceEpoch,
        'usuario_id': widget.userId,
        'fecha_inspeccion': _fechaController.text,
        'hora': _horaController.text,
        'dependencia_entidad': _dependenciaController.text,
        'id_grupo': _idGrupoController.text,
        'tipo_evento_id': _selectedEventoId,
        'nombre_evaluador': _nombreEvaluadorController.text,
        'firma': firmaPath, // Guardar la ruta en lugar de los bytes
      };

      await _dbHelper.insertarEvaluacion(evaluacionData);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Identificación de Evaluación'),
        backgroundColor: const Color(0xFF002855),
      ),
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
            eventoIdController: _eventoIdController,
            onGuardar: () {
              // Nuevo Registro: Limpia los campos
              _fechaController.clear();
              _horaController.clear();
              _nombreEvaluadorController.clear();
              _dependenciaController.clear();
              _idGrupoController.clear();
              _firmaFile = null;
              _firmaImageNotifier.value = null;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Campos reiniciados para nuevo registro')),
              );
            },
            selectDate: (ctx) => _selectDate(ctx),
            selectTime: (ctx) => _selectTime(ctx),
            firmaImageNotifier: _firmaImageNotifier,
            onSubirFirma: _subirFirma,
          ),
          SegundaSubseccion(
            onEventoSeleccionado: _handleEventoSeleccionado,
            onContinue: guardarYContinuar,
            selectedEventoId: _selectedEventoId,
          ),
        ],
      ),
      floatingActionButton: FloatingSectionsMenu(
        currentSection: 1, // Estamos en la primera sección
        onSectionSelected: _handleSectionSelected,
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

  void _navigateToEdificacion() async {
    try {
      final evaluacionId = await _dbHelper.obtenerUltimaEvaluacionId(widget.userId);
      if (!mounted) return;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IdentificacionEdificacionScreen(
            evaluacionId: evaluacionId,
            userId: widget.userId,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al navegar: $e')),
      );
    }
  }

  void _navigateToDescripcion() {
    // Implementar navegación a Descripción de la Edificación
  }
}
