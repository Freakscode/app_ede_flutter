// ignore_for_file: unused_import

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/database_helper.dart';
import '../models/comentario.dart';
import 'package:intl/intl.dart';

class ComentariosWidget extends StatefulWidget {
  final int userId;
  final int evaluacionId;
  final String nombreSeccion;

  const ComentariosWidget({
    Key? key,
    required this.userId,
    required this.evaluacionId,
    required this.nombreSeccion,
  }) : super(key: key);

  @override
  _ComentariosWidgetState createState() => _ComentariosWidgetState();
}



class _ComentariosWidgetState extends State<ComentariosWidget> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _textoController = TextEditingController();
  final List<File> _imagenes = [];

  final ImagePicker _picker = ImagePicker();

  List<Comentario> _comentarios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarComentarios();
  }

  Future<void> _cargarComentarios() async {
    try {
      List<Comentario> comentarios = await _dbHelper.obtenerComentarios(
        widget.evaluacionId,
        widget.nombreSeccion,
      );
      setState(() {
        _comentarios = comentarios;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar comentarios: $e')),
      );
    }
  }

  Future<void> _seleccionarImagenGaleria() async {
    final XFile? imagen = await _picker.pickImage(source: ImageSource.gallery);
    if (imagen != null) {
      setState(() {
        _imagenes.add(File(imagen.path));
      });
    }
  }

  Future<void> _tomarFotoCamara() async {
    final XFile? foto = await _picker.pickImage(source: ImageSource.camera);
    if (foto != null) {
      setState(() {
        _imagenes.add(File(foto.path));
      });
    }
  }

  Future<void> _guardarComentario() async {
    final texto = _textoController.text.trim();

    if (texto.isEmpty && _imagenes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe agregar al menos un comentario')),
      );
      return;
    }

    try {
      // Insertar comentario en la base de datos
      final comentarioId = await _dbHelper.insertarComentario(
        usuarioId: widget.userId,
        evaluacionId: widget.evaluacionId,
        nombreSeccion: widget.nombreSeccion,
        texto: texto.isEmpty ? null : texto,
      );

      // Insertar imágenes asociadas al comentario
      for (var img in _imagenes) {
        await _dbHelper.insertarRecursoComentario(comentarioId, 'imagen', img.path);
      }

      // Actualizar la lista de comentarios
      await _cargarComentarios();

      // Limpiar los campos después de guardar
      _textoController.clear();
      setState(() {
        _imagenes.clear();
      });

      Navigator.pop(context); // Cerrar el bottom sheet
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comentario guardado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar comentario: $e')),
      );
    }
  }

  Future<void> _actualizarComentario(Comentario comentario) async {
    final TextEditingController _editTextoController = TextEditingController(text: comentario.texto);
    List<File> _editImagenes = comentario.recursos
        .where((recurso) => recurso.tipo == 'imagen')
        .map((recurso) => File(recurso.pathArchivo))
        .toList();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Editar Comentario',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _editTextoController,
                      decoration: const InputDecoration(
                        labelText: 'Comentario',
                        hintText: 'Escribe tu comentario...',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Imágenes:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Wrap(
                      children: _editImagenes.map((img) {
                        return Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.file(img, width: 80, height: 80, fit: BoxFit.cover),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _editImagenes.remove(img);
                                  });
                                },
                                child: const Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            final XFile? imagen = await _picker.pickImage(source: ImageSource.gallery);
                            if (imagen != null) {
                              setState(() {
                                _editImagenes.add(File(imagen.path));
                              });
                            }
                          },
                          icon: const Icon(Icons.photo),
                          label: const Text('Galería'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final XFile? foto = await _picker.pickImage(source: ImageSource.camera);
                            if (foto != null) {
                              setState(() {
                                _editImagenes.add(File(foto.path));
                              });
                            }
                          },
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Cámara'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final nuevoTexto = _editTextoController.text.trim();
                        if (nuevoTexto.isEmpty && _editImagenes.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Debe agregar al menos un comentario')),
                          );
                          return;
                        }

                        try {
                          // Actualizar el texto del comentario
                          await _dbHelper.actualizarComentario(
                            comentarioId: comentario.id,
                            texto: nuevoTexto.isEmpty ? null : nuevoTexto,
                          );

                          // Obtener imágenes actuales en la base de datos
                          List<ComentarioRecurso> recursosActuales = comentario.recursos.where((recurso) => recurso.tipo == 'imagen').toList();
                          List<String> pathsActuales = recursosActuales.map((r) => r.pathArchivo).toList();

                          // Eliminar imágenes que fueron quitadas en la edición
                          for (var recurso in recursosActuales) {
                            File imgFile = File(recurso.pathArchivo);
                            if (!_editImagenes.any((img) => img.path == imgFile.path)) {
                              await _dbHelper.eliminarRecursoComentario(recurso.id);
                              // Opcional: eliminar el archivo físico
                              if (await imgFile.exists()) {
                                await imgFile.delete();
                              }
                            }
                          }

                          // Añadir nuevas imágenes
                          List<File> nuevasImagenes = _editImagenes.where((img) => !pathsActuales.contains(img.path)).toList();
                          for (var img in nuevasImagenes) {
                            await _dbHelper.insertarRecursoComentario(comentario.id, 'imagen', img.path);
                          }

                          // Recargar comentarios
                          await _cargarComentarios();

                          Navigator.pop(context); // Cerrar el bottom sheet
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Comentario actualizado correctamente')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al actualizar comentario: $e')),
                          );
                        }
                      },
                      child: const Text('Actualizar'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets, // Manejar el teclado
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Comentarios',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_comentarios.isEmpty)
                const Text('No hay comentarios aún.')
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _comentarios.length,
                  itemBuilder: (context, index) {
                    final comentario = _comentarios[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (comentario.texto != null)
                              Text(
                                comentario.texto!,
                                style: const TextStyle(fontSize: 16),
                              ),
                            if (comentario.recursos.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                children: comentario.recursos.map((recurso) {
                                  if (recurso.tipo == 'imagen') {
                                    return Image.file(
                                      File(recurso.pathArchivo),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    );
                                  }
                                  // Puedes manejar otros tipos como 'audio' si los tuvieras
                                  return Container();
                                }).toList(),
                              ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                // Asegúrate de tener un campo de fecha en tu modelo y base de datos
                                DateFormat('yyyy-MM-dd HH:mm').format(
                                  DateTime.parse(comentario.fecha),
                                ),
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                                onPressed: () => _actualizarComentario(comentario),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Agregar Comentario',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _textoController,
                decoration: const InputDecoration(
                  labelText: 'Comentario',
                  hintText: 'Escribe tu comentario...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Imágenes:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Wrap(
                children: _imagenes.map((img) {
                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.file(img, width: 80, height: 80, fit: BoxFit.cover),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _imagenes.remove(img);
                            });
                          },
                          child: const Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _seleccionarImagenGaleria,
                    icon: const Icon(Icons.photo),
                    label: const Text('Galería'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _tomarFotoCamara,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Cámara'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarComentario,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}