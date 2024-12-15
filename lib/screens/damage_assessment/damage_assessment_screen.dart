import 'package:flutter/material.dart';
import '../../utils/database_helper.dart'; 

class DamageAssessmentScreen extends StatefulWidget {
  final int evaluacionId;
  final int evaluacionEdificioId;

  const DamageAssessmentScreen({
    Key? key,
    required this.evaluacionId,
    required this.evaluacionEdificioId,
  }) : super(key: key);

  @override
  _DamageAssessmentScreenState createState() => _DamageAssessmentScreenState();
}

class _DamageAssessmentScreenState extends State<DamageAssessmentScreen> {
  int _currentIndex = 0;

  final List<String> _opcionesPorcentaje = [
    'Ninguno',
    '<10%',
    '10-40%',
    '40-70%',
    '70%+'
  ];
  String? _porcentajeSeleccionado;

  String _resultadoSeveridad = 'Desconocido';
  String _nivelDanioGlobal = '';

  Map<String, bool> condicionesMap = {};
  Map<String, String> elementosMap = {};

  @override
  void initState() {
    super.initState();
    _cargarSeveridadDesdeBD();
  }

  Future<void> _cargarSeveridadDesdeBD() async {
    final db = DatabaseHelper();
    final datos = await db.getCondicionesYElementos(widget.evaluacionEdificioId);

    for (var c in datos['condiciones']) {
      String cond = c['condicion'];
      bool si = (c['valor'] == 1);
      condicionesMap[cond] = si;
    }

    for (var e in datos['elementos']) {
      String elem = e['elemento'];
      int nivelId = e['nivel_dano_id'];
      elementosMap[elem] = _mapNivelDanoIdATexto(nivelId);
    }

    _resultadoSeveridad = _determinarSeveridad(condicionesMap, elementosMap);
    setState(() {});
  }

  String _mapNivelDanoIdATexto(int id) {
    switch (id) {
      case 1:
        return 'Sin daño';
      case 2:
        return 'Leve';
      case 3:
        return 'Moderado';
      case 4:
        return 'Severo';
      default:
        return 'Sin daño';
    }
  }

  String _determinarSeveridad(Map<String, bool> condMap, Map<String, String> elemMap) {
    // Aquí permanece la lógica para determinar la severidad interna (Bajo, Medio, Medio Alto, Alto)
    // Tal como estaba antes.
    // Por simplicidad, asumimos que ya tienes este método que retorna (Bajo, Medio, Medio Alto, Alto)
    // o 'Sin daño' según las condiciones evaluadas.
    // Mantén la misma lógica que tenías, ya que el cambio real se hará en _calcularNivelDanioGlobal().
    // Retorna un valor entre 'Bajo', 'Medio', 'Medio Alto', 'Alto' o 'Sin daño'.
    // Ejemplo (utiliza la lógica previa):
    bool alto = false;
    if (condMap['5.1'] == true || condMap['5.2'] == true || condMap['5.3'] == true || condMap['5.4'] == true) {
      alto = true;
    }
    if (elemMap['5.7'] == 'Severo') alto = true;

    bool medioAlto = false;
    if (condMap['5.5'] == true || condMap['5.6'] == true) medioAlto = true;
    if (elemMap['5.7'] == 'Moderado') medioAlto = true;
    for (var eCode in ['5.8','5.9','5.10','5.11']) {
      if (elemMap[eCode] == 'Severo') {
        medioAlto = true;
        break;
      }
    }

    bool medio = false;
    for (var eCode in ['5.8','5.9','5.10','5.11']) {
      if (elemMap[eCode] == 'Moderado') {
        medio = true;
        break;
      }
    }

    bool todasNo = true;
    for (var cCode in ['5.1','5.2','5.3','5.4','5.5','5.6']) {
      if (condMap[cCode] == true) {
        todasNo = false;
        break;
      }
    }
    bool todosLeves = true;
    for (var eCode in ['5.7','5.8','5.9','5.10','5.11']) {
      if (elemMap[eCode] != 'Sin daño' && elemMap[eCode] != 'Leve') {
        todosLeves = false;
        break;
      }
    }
    bool bajo = (todasNo && todosLeves);

    if (alto) return 'Alto';
    if (medioAlto) return 'Medio Alto';
    if (medio) return 'Medio';
    if (bajo) return 'Bajo';
    return 'Sin daño';
  }

  void _calcularNivelDanioGlobal() {
    if (_porcentajeSeleccionado == null || _resultadoSeveridad == 'Desconocido') {
      _nivelDanioGlobal = '';
      return;
    }

    final severidad = _resultadoSeveridad.toLowerCase();
    final porcentaje = _porcentajeSeleccionado!.toLowerCase();

    // Mapeo de porcentajes a rangos lógicos
    // 'Ninguno' lo interpretamos como <10%
    bool menos10 = (porcentaje == 'ninguno' || porcentaje == '<10%');
    bool entre10y40 = (porcentaje == '10-40%');
    bool entre40y70 = (porcentaje == '40-70%');
    bool mas70 = (porcentaje == '70%+');

    // Nuevas reglas (reformuladas):
    // 1) Bajo (Verde):
    //   - Si severidad = Bajo y % <10% o 10-40% => Bajo
    //   - Si severidad = Medio y % <10% => Bajo
    if ((severidad == 'bajo' && (menos10 || entre10y40)) ||
        (severidad == 'medio' && menos10)) {
      _nivelDanioGlobal = 'Bajo';
      return;
    }

    // 2) Medio (Amarillo):
    //   - Si severidad = Bajo y % = 40-70% o >70% => Medio
    //   - Si severidad = Medio y % = 10-40% o 40-70% => Medio
    //   - Si severidad = Medio Alto y % <10% o 10-40% => Medio
    if ((severidad == 'bajo' && (entre40y70 || mas70)) ||
        (severidad == 'medio' && (entre10y40 || entre40y70)) ||
        (severidad == 'medio alto' && (menos10 || entre10y40))) {
      _nivelDanioGlobal = 'Medio';
      return;
    }

    // 3) Alto (Rojo):
    // Si no entró en las condiciones anteriores, entonces es Alto.
    _nivelDanioGlobal = 'Alto';
  }

  Widget _buildSection61() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            '6.1 Porcentaje de Afectación de la Edificación en Planta',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          for (var op in _opcionesPorcentaje)
            RadioListTile<String>(
              title: Text(op),
              value: op,
              groupValue: _porcentajeSeleccionado,
              onChanged: (val) {
                setState(() {
                  _porcentajeSeleccionado = val;
                });
                _calcularNivelDanioGlobal();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSection62() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '6.2 Severidad de Daños',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text('Severidad obtenida: $_resultadoSeveridad'),
          const SizedBox(height: 8),
          const Text(
            'La severidad se determina en función de las condiciones identificadas en la Sección 5.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSection63() {
    _calcularNivelDanioGlobal();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '6.3 Nivel de Daño en la Edificación',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text('Porcentaje de afectación seleccionado: ${_porcentajeSeleccionado ?? "No seleccionado"}'),
          Text('Severidad de daños: $_resultadoSeveridad'),
          const SizedBox(height: 16),
          Text('Nivel de daño global resultante: $_nivelDanioGlobal'),
        ],
      ),
    );
  }

  Widget _buildSubpantallaSeccion6() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSection61(),
          const Divider(),
          _buildSection62(),
          const Divider(),
          _buildSection63(),
        ],
      ),
    );
  }

  final List<Widget> _screens = [
    Container(),
    Center(child: Text('Otra pantalla', style: TextStyle(fontSize: 18))),
    Center(child: Text('Otra pantalla 2', style: TextStyle(fontSize: 18))),
  ];

  @override
  Widget build(BuildContext context) {
    _screens[0] = _buildSubpantallaSeccion6();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluación de Daños - Sección 6'),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Sección 6',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_repair_service),
            label: 'Otras',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Más',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
