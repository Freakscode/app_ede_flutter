import 'package:flutter/material.dart';
import '../../../utils/database_helper.dart'; // Asegúrate de ajustar la ruta a tu archivo
import '../restantes/restante_screen.dart';

class ElementosNoEstructuralesScreen extends StatefulWidget {
  final int evaluacionId;
  final int evaluacionEdificioId;

  const ElementosNoEstructuralesScreen({
    super.key,
    required this.evaluacionId,
    required this.evaluacionEdificioId,
  });

  @override
  State<ElementosNoEstructuralesScreen> createState() => _ElementosNoEstructuralesScreenState();
}

class _ElementosNoEstructuralesScreenState extends State<ElementosNoEstructuralesScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;
  late MurosDivisoriosWidget _murosWidget;
  late FachadasWidget _fachadasWidget;
  late EscalerasWidget _escalerasWidget;
  int? _numeroPisos;

  @override
  void initState() {
    super.initState();
    _cargarNumeroPisos();
  }

  Future<void> _cargarNumeroPisos() async {
    try {
      final dbHelper = DatabaseHelper();
      
      // Agregar timeout de 5 segundos
      final numero = await Future.value(
        dbHelper.obtenerNumeroPisos(widget.evaluacionEdificioId)
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('Timeout al cargar número de pisos');
          return 0; // Valor por defecto
        },
      );

      // Verificar si el widget sigue montado
      if (!mounted) return;

      setState(() {
        _numeroPisos = numero;
        _inicializarWidgets();
      });

    } catch (e) {
      print('Error al cargar número de pisos: $e');
      
      // Verificar si el widget sigue montado
      if (!mounted) return;

      setState(() {
        _numeroPisos = 0; // Valor por defecto en caso de error
        _inicializarWidgets();
      });

      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al cargar datos. Se usarán valores por defecto.'),
        ),
      );
    }
  }

  void _inicializarWidgets() {
    _murosWidget = MurosDivisoriosWidget(
      evaluacionId: widget.evaluacionId,
      evaluacionEdificioId: widget.evaluacionEdificioId,
    );
    _fachadasWidget = FachadasWidget(
      evaluacionId: widget.evaluacionId,
      evaluacionEdificioId: widget.evaluacionEdificioId,
    );
    _escalerasWidget = EscalerasWidget(
      evaluacionId: widget.evaluacionId,
      evaluacionEdificioId: widget.evaluacionEdificioId,
      numeroPisos: _numeroPisos ?? 0, // Manejar caso nulo
    );

    _screens = [
      _murosWidget,
      _fachadasWidget,
      _escalerasWidget,
    ];
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  void _guardarYContinuar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EvaluacionSeccion3(
          evaluacionId: widget.evaluacionId,
          evaluacionEdificioId: widget.evaluacionEdificioId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar un indicador de carga mientras se recupera numero_pisos
    if (_numeroPisos == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('3.6 Elementos no estructurales adicionales'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('3.6 Elementos no estructurales adicionales'),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.wallpaper),
            label: 'Muros (3.6.1)',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.landscape),
            label: 'Fachadas (3.6.2)',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.stairs),
            label: 'Escaleras (3.6.3)',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _guardarYContinuar,
        label: const Text('Guardar y Continuar'),
        icon: const Icon(Icons.save),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class MurosDivisoriosWidget extends StatefulWidget {
  final int evaluacionId;
  final int evaluacionEdificioId;

  const MurosDivisoriosWidget({
    Key? key,
    required this.evaluacionId,
    required this.evaluacionEdificioId,
  }) : super(key: key);

  @override
  State<MurosDivisoriosWidget> createState() => _MurosDivisoriosWidgetState();
}

class _MurosDivisoriosWidgetState extends State<MurosDivisoriosWidget> {
  bool _mamposteria = false;
  bool _tierra = false;
  bool _bahareque = false;
  bool _particionesLivianas = false;
  bool _otro = false;
  final TextEditingController _otroController = TextEditingController();

  @override
  void dispose() {
    _otroController.dispose();
    super.dispose();
  }

  void _guardar() async {
    final db = DatabaseHelper();
    Map<String, dynamic> datos = {
      'muros_divisorios_mamposteria': _mamposteria ? 1 : 0,
      'muros_divisorios_tierra': _tierra ? 1 : 0,
      'muros_divisorios_bahareque': _bahareque ? 1 : 0,
      'muros_divisorios_particiones': _particionesLivianas ? 1 : 0,
      'muros_divisorios_otro_texto': _otro ? _otroController.text : null,
    };

    await db.insertarOActualizarElementoNoEstructural(widget.evaluacionEdificioId, datos);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Datos de Muros Divisorios guardados')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('3.6.1 Muros Divisorios', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          CheckboxListTile(
            title: const Text('Mampostería'),
            value: _mamposteria,
            onChanged: (val) => setState(() => _mamposteria = val!),
          ),
          CheckboxListTile(
            title: const Text('Tierra'),
            value: _tierra,
            onChanged: (val) => setState(() => _tierra = val!),
          ),
          CheckboxListTile(
            title: const Text('Bahareque'),
            value: _bahareque,
            onChanged: (val) => setState(() => _bahareque = val!),
          ),
          CheckboxListTile(
            title: const Text('Particiones livianas'),
            value: _particionesLivianas,
            onChanged: (val) => setState(() => _particionesLivianas = val!),
          ),
          CheckboxListTile(
            title: const Text('Otro'),
            value: _otro,
            onChanged: (val) => setState(() => _otro = val!),
          ),
          if (_otro)
            TextField(
              controller: _otroController,
              decoration: const InputDecoration(labelText: 'Especifique otro'),
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _guardar,
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

class FachadasWidget extends StatefulWidget {
  final int evaluacionId;
  final int evaluacionEdificioId;

  const FachadasWidget({
    Key? key,
    required this.evaluacionId,
    required this.evaluacionEdificioId,
  }) : super(key: key);

  @override
  State<FachadasWidget> createState() => _FachadasWidgetState();
}

class _FachadasWidgetState extends State<FachadasWidget> {
  bool _mamposteria = false;
  bool _tierra = false;
  bool _paneles = false;
  bool _flotante = false;
  bool _otro = false;
  final TextEditingController _otroController = TextEditingController();

  @override
  void dispose() {
    _otroController.dispose();
    super.dispose();
  }

  void _guardar() async {
    final db = DatabaseHelper();
    Map<String, dynamic> datos = {
      'fachadas_mamposteria': _mamposteria ? 1 : 0,
      'fachadas_tierra': _tierra ? 1 : 0,
      'fachadas_paneles': _paneles ? 1 : 0,
      'fachadas_flotante': _flotante ? 1 : 0,
      'fachadas_otro_texto': _otro ? _otroController.text : null,
    };

    await db.insertarOActualizarElementoNoEstructural(widget.evaluacionEdificioId, datos);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Datos de Fachadas guardados')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('3.6.2 Fachadas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          CheckboxListTile(
            title: const Text('Mampostería'),
            value: _mamposteria,
            onChanged: (val) => setState(() => _mamposteria = val!),
          ),
          CheckboxListTile(
            title: const Text('Tierra'),
            value: _tierra,
            onChanged: (val) => setState(() => _tierra = val!),
          ),
          CheckboxListTile(
            title: const Text('Paneles'),
            value: _paneles,
            onChanged: (val) => setState(() => _paneles = val!),
          ),
          CheckboxListTile(
            title: const Text('Flotante'),
            value: _flotante,
            onChanged: (val) => setState(() => _flotante = val!),
          ),
          CheckboxListTile(
            title: const Text('Otro'),
            value: _otro,
            onChanged: (val) => setState(() => _otro = val!),
          ),
          if (_otro)
            TextField(
              controller: _otroController,
              decoration: const InputDecoration(labelText: 'Especifique otro'),
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _guardar,
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

class EscalerasWidget extends StatefulWidget {
  final int evaluacionId;
  final int evaluacionEdificioId;
  final int numeroPisos; // Agregar esta propiedad

  const EscalerasWidget({
    Key? key,
    required this.evaluacionId,
    required this.evaluacionEdificioId,
    required this.numeroPisos, // Inicializar en el constructor
  }) : super(key: key);

  @override
  State<EscalerasWidget> createState() => _EscalerasWidgetState();
}

class _EscalerasWidgetState extends State<EscalerasWidget> {
  bool _concreto = false;
  bool _metalica = false;
  bool _madera = false;
  bool _mixtas = false;
  bool _otro = false;
  final TextEditingController _otroController = TextEditingController();
  bool _habilitado = true; // Nueva variable para controlar la habilitación

  @override
  void initState() {
    super.initState();
    _habilitarEscaleras();
  }

  void _habilitarEscaleras() {
    if (widget.numeroPisos > 1) {
      setState(() {
        _habilitado = true;
      });
    } else {
      setState(() {
        _habilitado = false;
        _concreto = false;
        _metalica = false;
        _madera = false;
        _mixtas = false;
        _otro = false;
        _otroController.clear();
      });
    }
  }

  @override
  void didUpdateWidget(covariant EscalerasWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.numeroPisos != widget.numeroPisos) {
      _habilitarEscaleras();
    }
  }

  @override
  void dispose() {
    _otroController.dispose();
    super.dispose();
  }

  void _guardar() async {
    if (!_habilitado) return;

    final db = DatabaseHelper();
    Map<String, dynamic> datos = {
      'escaleras_concreto': _concreto ? 1 : 0,
      'escaleras_metalica': _metalica ? 1 : 0,
      'escaleras_madera': _madera ? 1 : 0,
      'escaleras_mixtas': _mixtas ? 1 : 0,
      'escaleras_otro_texto': _otro ? _otroController.text : null,
    };

    await db.insertarOActualizarElementoNoEstructural(widget.evaluacionEdificioId, datos);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Datos de Escaleras guardados')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !_habilitado, // Deshabilitar interacción si no está habilitado
      child: Opacity(
        opacity: _habilitado ? 1.0 : 0.5, // Reducir opacidad si está deshabilitado
        child: Column(
          children: [
            CheckboxListTile(
              title: const Text('Concreto'),
              value: _concreto,
              onChanged: (val) => setState(() => _concreto = val!),
            ),
            CheckboxListTile(
              title: const Text('Metálica'),
              value: _metalica,
              onChanged: (val) => setState(() => _metalica = val!),
            ),
            CheckboxListTile(
              title: const Text('Madera'),
              value: _madera,
              onChanged: (val) => setState(() => _madera = val!),
            ),
            CheckboxListTile(
              title: const Text('Mixtas'),
              value: _mixtas,
              onChanged: (val) => setState(() => _mixtas = val!),
            ),
            CheckboxListTile(
              title: const Text('Otro'),
              value: _otro,
              onChanged: (val) => setState(() => _otro = val!),
            ),
            if (_otro)
              TextField(
                controller: _otroController,
                decoration: const InputDecoration(labelText: 'Especifique otro'),
              ),
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
