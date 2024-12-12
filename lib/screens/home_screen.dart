import 'package:flutter/material.dart';
import '../utils/database_helper.dart';
import 'identificacion_evaluacion/identificacion_evaluacion_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final int userId; // Añadido userId

  const HomeScreen({super.key, required this.userName, required this.userId});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _evaluaciones = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarEvaluaciones();
  }

  Future<void> _cargarEvaluaciones({String? eventoId}) async {
    setState(() => _isLoading = true);
    try {
      final db = await _dbHelper.database;
      String query = '''
        SELECT e.id, e.eventoId, e.tipo_evento_id, e.dependencia_entidad, e.hora, e.fecha_inspeccion, t.descripcion as tipo_evento
        FROM Evaluaciones e
        LEFT JOIN TipoEventos t ON e.tipo_evento_id = t.id
        WHERE e.usuario_id = ?
      ''';

      List<dynamic> args = [widget.userId];

      if (eventoId != null && eventoId.isNotEmpty) {
        query += ' AND e.eventoId = ?';
        args.add(eventoId);
      }

      final evaluaciones = await db.rawQuery(query, args);

      setState(() {
        _evaluaciones = evaluaciones;
      });
    } catch (e) {
      print('Error cargando evaluaciones: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _buscarEvaluaciones() {
    String eventoId = _searchController.text.trim();
    _cargarEvaluaciones(eventoId: eventoId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Eliminamos el AppBar para usar un Header personalizado
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header similar al de login_screen.dart
                Container(
                  padding: const EdgeInsets.only(top: 60, bottom: 20),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF002855), // Azul oscuro
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        "DAGRD - APP EDE",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Evaluación de Daños en Edificaciones",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Bienvenida al usuario
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Bienvenido, ${widget.userName}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF002855),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Barra de búsqueda con ícono de lupa con fondo amarillo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por Evento ID',
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0.0, horizontal: 16.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAD502), // Color amarillo específico
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.search,
                            color: Colors.black,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: _buscarEvaluaciones,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(height: 20),
                // Nuevo botón para añadir una evaluación
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IdentificacionEvaluacionScreen(userId: widget.userId),
                      ),
                    );
                  },
                  child: const Text('Añadir Nueva Evaluación'),
                ),
                const SizedBox(height: 20),
                // Lista de evaluaciones
                const SizedBox(height: 20),
                // Lista de evaluaciones
                Expanded(
                  child: _evaluaciones.isEmpty
                      ? const Center(
                          child: Text(
                            'No se encontraron evaluaciones.',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _evaluaciones.length,
                          itemBuilder: (context, index) {
                            final eval = _evaluaciones[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ID: ${eval['id']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text('Evento ID: ${eval['eventoId']}'),
                                    Text(
                                        'Tipo de Evento: ${eval['tipo_evento'] ?? 'N/A'}'),
                                    Text(
                                        'Dependencia: ${eval['dependencia_entidad'] ?? 'N/A'}'),
                                    Text(
                                        'Fecha de Inspección: ${eval['fecha_inspeccion']}'),
                                    Text('Hora: ${eval['hora']}'),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.end,
                                      children: [
                                        TextButton.icon(
                                          onPressed: () {
                                            // Acción para ver evaluación
                                          },
                                          icon: const Icon(Icons.remove_red_eye),
                                          label:
                                              const Text('Ver evaluación'),
                                        ),
                                        const SizedBox(width: 8),
                                        TextButton.icon(
                                          onPressed: () {
                                            // Acción para editar registro
                                          },
                                          icon: const Icon(Icons.edit),
                                          label:
                                              const Text('Editar Registro'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                // Footer similar al de login_screen.dart
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF002855),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset(
                        'assets/images/logos.png', // Reemplaza con la imagen izquierda
                        height: 60,
                      ),
                      // Puedes agregar más elementos aquí si lo deseas
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}