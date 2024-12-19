// ignore_for_file: unused_element, unused_import

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/database_helper.dart';
import 'primera_subseccion.dart';
import 'segunda_subseccion.dart';
import '../../models/temp_identificacion_evaluacion.dart';
import '../identificacion_edificacion/identificacion_edificacion_screen.dart';
import '../../widgets/comentarios_widget.dart';

class IdentificacionEvaluacionScreen extends StatefulWidget {
  final int userId;
  final int evaluacionId;
  final Map<String, dynamic>? tempData;

  const IdentificacionEvaluacionScreen({
    super.key,
    required this.userId,
    required this.evaluacionId,
    this.tempData
  });

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
  late final TextEditingController _eventoIdController;
  final TextEditingController _otroEventoController = TextEditingController();
  

  final ValueNotifier<ImageProvider?> _firmaImageNotifier =
      ValueNotifier<ImageProvider?>(null);
  File? _firmaFile;

  int? _selectedEventoId;

  late final TempIdentificacionEvaluacion _tempData;

  // Definición de secciones y pantallas
  final Map<String, List<Map<String, dynamic>>> secciones = {
    'IDENTIFICACIÓN DE EVALUACIÓN': [
      {
        'id': 1,
        'title': 'Datos Generales',
        'route': '/identificacion_evaluacion',
        'args': {}
      },
      {
        'id': 2,
        'title': 'Tipo de Evento',
        'route': '/identificacion_evaluacion',
        'args': {'tipo': 'evento'}
      },
    ],
    'IDENTIFICACIÓN DE LA EDIFICACIÓN': [
      {
        'id': 3,
        'title': 'Datos Generales',
        'route': '/identificacion_edificacion',
        'args': {}
      },
      {
        'id': 4,
        'title': 'Identificación Catastral (CBML) y Localización',
        'route': '/identificacion_edificacion',
        'args': {'tipo': 'catastral'}
      },
      {
        'id': 5,
        'title': 'Persona de Contacto',
        'route': '/identificacion_edificacion',
        'args': {'tipo': 'contacto'}
      },
    ],
    'DESCRIPCIÓN DE LA EDIFICACIÓN': [
      {
        'id': 6,
        'title': 'Características Generales',
        'route': '/descripcion_edificacion',
        'args': {}
      },
      {
        'id': 7,
        'title': 'Usos Predominantes',
        'route': '/descripcion_edificacion',
        'args': {'tipo': 'usos'}
      },
      {
        'id': 8,
        'title': 'Sistema Estructural y Material',
        'route': '/descripcion_edificacion',
        'args': {'tipo': 'sistema_estructural'}
      },
      {
        'id': 9,
        'title': 'Sistema de Entrepiso',
        'route': '/descripcion_edificacion',
        'args': {'tipo': 'entrepiso'}
      },
      {
        'id': 10,
        'title': 'Sistema de Cubierta',
        'route': '/descripcion_edificacion',
        'args': {'tipo': 'cubierta'}
      },
      {
        'id': 11,
        'title': 'Elementos no Estructurales Adicionales',
        'route': '/descripcion_edificacion',
        'args': {'tipo': 'elementos_no_estructurales'}
      },
    ],
    'IDENTIFICACIÓN DE RIESGOS EXTERNOS': [
      {
        'id': 12,
        'title': 'Riesgo Externo',
        'route': '/identificacion_riesgos_externos',
        'args': {}
      },
      {
        'id': 13,
        'title': 'Compromete Acceso',
        'route': '/identificacion_riesgos_externos',
        'args': {'tipo': 'acceso'}
      },
      {
        'id': 14,
        'title': 'Compromete Estabilidad',
        'route': '/identificacion_riesgos_externos',
        'args': {'tipo': 'estabilidad'}
      },
    ],
    'EVALUACIÓN DE DAÑOS EN LA EDIFICACIÓN': [
      {
        'id': 15,
        'title': 'Determinar existencia de condiciones',
        'route': '/evaluacion_danos',
        'args': {}
      },
      {
        'id': 16,
        'title': 'Establecer nivel de daño',
        'route': '/evaluacion_danos',
        'args': {'tipo': 'nivel_dano'}
      },
    ],
    'ALCANCE DE LA EVALUACIÓN REALIZADA': [
      {
        'id': 17,
        'title': 'Evaluación Interior/Exterior',
        'route': '/alcance_evaluacion',
        'args': {}
      },
    ],
    'HABITABILIDAD DE LA EDIFICACIÓN': [
      {
        'id': 18,
        'title': 'Evaluación de Habitabilidad',
        'route': '/habitabilidad',
        'args': {}
      },
    ],
    'ACCIONES RECOMENDADAS': [
      {
        'id': 19,
        'title': 'Evaluación Adicional',
        'route': '/acciones_recomendadas',
        'args': {}
      },
      {
        'id': 20,
        'title': 'Recomendaciones y Medidas',
        'route': '/acciones_recomendadas',
        'args': {'tipo': 'medidas'}
      },
    ],
  };

@override
void initState() {
  super.initState();
  _eventoIdController = TextEditingController();

  if (widget.tempData != null) {
    // Crear instancia de TempIdentificacionEvaluacion desde tempData
    _tempData = TempIdentificacionEvaluacion.fromMap(widget.tempData!);
    
    // Repoblar campos con datos temporales
    _fechaController.text = _tempData.fecha;
    _horaController.text = _tempData.hora;
    _nombreEvaluadorController.text = _tempData.nombreEvaluador ?? '';
    _dependenciaController.text = _tempData.dependenciaEntidad ?? '';
    _idGrupoController.text = _tempData.idGrupo ?? '';
    _eventoIdController.text = _tempData.eventoId?.toString() ?? '';
    _otroEventoController.text = _tempData.otroEvento ?? '';
    _selectedEventoId = _tempData.tipoEventoId;

    // Manejar firma si existe
    if (_tempData.firmaPath != null) {
      _firmaFile = File(_tempData.firmaPath!);
      _firmaImageNotifier.value = FileImage(_firmaFile!);
    }
  } else {
    // Inicialización con valores por defecto si no hay datos temporales
    _tempData = TempIdentificacionEvaluacion(
      fecha: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      hora: DateFormat('HH:mm').format(DateTime.now()),
    );
    _fechaController.text = _tempData.fecha;
    _horaController.text = _tempData.hora;
  }
}

  @override
  void dispose() {
    _otroEventoController.dispose();
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

  // Método para guardar y continuar
  Future<void> guardarYContinuar() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _currentIndex = 0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor complete los datos generales')),
      );
      return;
    }

    try {
      final String? firmaPath = _firmaFile?.path;

      // Validar que eventoId no esté vacío
      if (_eventoIdController.text.isEmpty) {
        throw Exception('El ID del evento es requerido');
      }

      final Map<String, dynamic> evaluacionData = {
        'id': widget.evaluacionId,
        'eventoId': int.parse(_eventoIdController.text), // Agregar eventoId
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
        'firma': firmaPath,
      };

      await _dbHelper.insertarEvaluacion(evaluacionData);

      if (!mounted) return;

      await _imprimirEvaluacionBasica(widget.evaluacionId);

      // Navegar usando rutas nombradas
      Navigator.pushNamed(
        context,
        '/identificacion_edificacion',
        arguments: {
          'userId': widget.userId,
          'evaluacionId': widget.evaluacionId,
          // Agrega otros argumentos necesarios aquí
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  Future<void> _handleEventoSeleccionado(
      String label, int tipoEventoId) async {
    setState(() {
      _selectedEventoId = tipoEventoId;
    });
  }

  // Método para manejar la selección de secciones desde el FloatingActionButton
  void _handleSectionSelected(int sectionId) {
    // Encontrar la pantalla correspondiente por ID
    String? routeName;
    Map<String, dynamic>? args;

    secciones.forEach((seccion, pantallas) {
      for (var pantalla in pantallas) {
        if (pantalla['id'] == sectionId) {
          routeName = pantalla['route'];
          args = {
            'userId': widget.userId,
            'evaluacionId': widget.evaluacionId,
            ...pantalla['args'], // Combinar argumentos extra si hay
          };
          break;
        }
      }
    });

    if (routeName != null && args != null) {
      Navigator.pushNamed(
        context,
        routeName!,
        arguments: args,
      );
    }
  }

  // Método para guardar datos actuales antes de navegar
  Future<void> _saveCurrentData() async {
    try {
      // Obtener la ruta de la firma
      final String? firmaPath = _firmaFile?.path;
      final evaluacionData = {
        'eventoId': int.tryParse(_eventoIdController.text) ?? 0,
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

  void _navigateToSection(String route) {
  _updateTempData();
  Navigator.pushNamed(
    context,
    route,
    arguments: {
      'userId': widget.userId,
      'evaluacionId': widget.evaluacionId,
      'tempData': _tempData.toMap(),
    },
  );
}

void _updateTempData() {
  _tempData = TempIdentificacionEvaluacion(
    fecha: _fechaController.text,
    hora: _horaController.text,
    nombreEvaluador: _nombreEvaluadorController.text,
    dependenciaEntidad: _dependenciaController.text,
    idGrupo: _idGrupoController.text,
    eventoId: int.tryParse(_eventoIdController.text),
    firmaPath: _firmaFile?.path,
    tipoEventoId: _selectedEventoId,
    otroEvento: _otroEventoController.text,
  );
}

  // Método para mostrar las secciones y pantallas usando FloatingActionButton
  void _mostrarSecciones() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: secciones.keys.map((seccionTitulo) {
            return ExpansionTile(
              title: Text(seccionTitulo,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              children: secciones[seccionTitulo]!.map((pantalla) {
                return ListTile(
                  title: Text(pantalla['title']),
                  onTap: () {
                    Navigator.pop(context); // Cerrar el bottom sheet
                    // Navegar a la pantalla seleccionada usando pushNamed
                    Navigator.pushNamed(
                      context,
                      pantalla['route'],
                      arguments: {
                        'userId': widget.userId,
                        'evaluacionId': widget.evaluacionId,
                        ...pantalla['args'], // Combinar argumentos extra si hay
                      },
                    );
                  },
                );
              }).toList(),
            );
          }).toList(),
        );
      },
    );
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
            onTipoEventoActualizado:
                _onTipoEventoActualizado,
            otroEvento: _otroEventoController,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ComentariosWidget(
              userId: widget.userId,
              evaluacionId: widget.evaluacionId,
              nombreSeccion: 'Identificación de Evaluación',
            ),
          ),
        );
      },
      child: const Icon(Icons.comment),
      backgroundColor: const Color(0xFF002855),
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
      final evaluacionId =
          await _dbHelper.obtenerUltimaEvaluacionId(widget.userId);
      if (!mounted) return;

      Navigator.pushNamed(
        context,
        '/identificacion_edificacion',
        arguments: {
          'userId': widget.userId,
          'evaluacionId': evaluacionId,
          // Agrega otros argumentos si es necesario
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al navegar: $e')),
      );
    }
  }

  void _navigateToDescripcion() {
    // Implementar navegación a Descripción de la Edificación
    Navigator.pushNamed(
      context,
      '/descripcion_edificacion',
      arguments: {
        'userId': widget.userId,
        'evaluacionId': widget.evaluacionId,
        // 'evaluacionEdificioId': 200, // Debe ser dinámico
      },
    );
  }

  // Métodos adicionales como _onDatosActualizados y _onTipoEventoActualizado
  void _onDatosActualizados(
    String? nombreEvaluador,
    String? dependenciaEntidad,
    String? idGrupo,
    String? firmaPath,
  ) {
    setState(() {
      if (nombreEvaluador != null)
        _tempData.nombreEvaluador = nombreEvaluador;
      if (dependenciaEntidad != null)
        _tempData.dependenciaEntidad = dependenciaEntidad;
      if (idGrupo != null)
        _tempData.idGrupo = idGrupo;
      if (firmaPath != null)
        _tempData.firmaPath = firmaPath;
    });
  }

  void _onTipoEventoActualizado(int? tipoEventoId, String? otroEvento) {
    setState(() {
      _tempData.tipoEventoId = tipoEventoId;
      _tempData.otroEvento = otroEvento;
      _selectedEventoId = tipoEventoId;
    });
  }
}
