// ignore_for_file: unused_element, unused_import, unused_local_variable

import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/database_helper.dart';
import '../screens/home_screen.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:url_launcher/url_launcher.dart';

class ResumenEvaluacionScreen extends StatefulWidget {
  final int userId;
  final int evaluacionId;

  const ResumenEvaluacionScreen({
    Key? key,
    required this.userId,
    required this.evaluacionId,
  }) : super(key: key);

  @override
  State<ResumenEvaluacionScreen> createState() => _ResumenEvaluacionScreenState();
}

class _ResumenEvaluacionScreenState extends State<ResumenEvaluacionScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool enviando = false;

  Widget _buildSectionTitle(String titulo) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        titulo,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF002855),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, Map<String, dynamic>? data) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF002855),
              ),
            ),
            const Divider(),
            if (data != null) ..._buildDataWidgets(data),
          ],
        ),
      ),
    );
  }

  Widget _buildDataWidget(String key, dynamic value) {
    if (key.toLowerCase() == 'firma' && value is String) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Firma del Evaluador:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: value.isNotEmpty
                ? Image.file(
                    File(value),
                    fit: BoxFit.contain,
                  )
                : const Center(
                    child: Text('No hay firma disponible'),
                  ),
          ),
        ],
      );
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        '$key: ${value ?? "No especificado"}',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  List<Widget> _buildDataWidgets(Map<String, dynamic> data) {
    return data.entries.map((entry) {
      if (entry.value is List && entry.key.toLowerCase() != 'firma') {
        return _buildListSection(entry.key, entry.value as List);
      } else if (entry.value is Map) {
        return _buildMapSection(entry.key, entry.value as Map);
      } else {
        return _buildDataWidget(entry.key, entry.value);
      }
    }).toList();
  }

  Widget _buildListSection(String title, List items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 4.0),
              child: Text('• ${item.toString()}'),
            )),
      ],
    );
  }

  Widget _buildMapSection(String title, Map data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        ...data.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 4.0),
              child: Text('${entry.key}: ${entry.value}'),
            )),
      ],
    );
  }

  Future<File> _generarPDF(Map<String, dynamic> datos) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Resumen de Evaluación',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))
          ),
          _buildPDFSection('1. Identificación de la Evaluación', datos['evaluacion']),
          _buildPDFSection('2. Identificación de la Edificación', datos['edificio']),
          _buildPDFSection('3. Descripción de la Edificación', datos['caracteristicas_generales']),
          _buildPDFSection('4. Riesgos Externos', datos['riesgos_externos']),
          _buildPDFSection('5. Daños en la Edificación', datos['danos_evaluacion']),
          _buildPDFSection('6. Habitabilidad', datos['habitabilidad']),
          _buildPDFSection('7. Acciones Recomendadas', datos['acciones_recomendadas']),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/evaluacion_${widget.evaluacionId}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  pw.Widget _buildPDFSection(String title, Map<String, dynamic>? data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title,
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Divider(),
        if (data != null) ..._buildPDFDataWidgets(data),
        pw.SizedBox(height: 20),
      ],
    );
  }

  List<pw.Widget> _buildPDFDataWidgets(Map<String, dynamic> data) {
    return data.entries.map((entry) {
      if (entry.key.toLowerCase() == 'firma' && entry.value is String) {
        return pw.Container(
          height: 200,
          child: pw.Image(pw.MemoryImage(File(entry.value).readAsBytesSync()))
        );
      }
      return pw.Text('${entry.key}: ${entry.value ?? "No especificado"}');
    }).toList();
  }

  Future<void> _guardarPDF(BuildContext context) async {
    try {
      final datos = await _dbHelper.obtenerDatosEvaluacion(widget.evaluacionId);
      final file = await _generarPDF(datos);
      await OpenFile.open(file.path);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF generado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar PDF: $e')),
      );
    }
  }

  Future<void> _enviarPDF(BuildContext context) async {
    final TextEditingController emailController = TextEditingController();
    bool enviando = false;
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Enviar PDF por Correo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  hintText: 'ejemplo@dominio.com',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: !enviando,
              ),
              if (enviando)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: enviando ? null : () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: enviando
                  ? null
                  : () async {
                      if (_validarEmail(emailController.text)) {
                        setState(() => enviando = true);
                        Navigator.pop(context);
                        await _enviarCorreo(context, emailController.text);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Correo electrónico inválido'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              child: Text(enviando ? 'Enviando...' : 'Enviar'),
            ),
          ],
        ),
      ),
    );
  }

  bool _validarEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _enviarCorreo(BuildContext context, String email) async {
    try {
      final datos = await _dbHelper.obtenerDatosEvaluacion(widget.evaluacionId);
      final file = await _generarPDF(datos);

      final smtpServer = gmail(
        'gabcardona0782@gmail.com',
        'dtoy eidc mcfp iefp'
      );

      final message = Message()
        ..from = Address('tu_correo@gmail.com', 'EDE App')
        ..recipients.add(email)
        ..subject = 'Evaluación de Daños en Edificaciones - ID: ${widget.evaluacionId}'
        ..text = '''
          Estimado usuario,
          
          Adjunto encontrará el reporte de evaluación ID: ${widget.evaluacionId}.
          
          Saludos cordiales,
          EDE App
        '''
        ..attachments = [
          FileAttachment(file)
            ..location = Location.attachment
            ..fileName = 'evaluacion_${widget.evaluacionId}.pdf'
        ];

      try {
        final conexion = PersistentConnection(smtpServer);
        await conexion.send(message);
        await conexion.close();

        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Correo enviado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } on MailerException catch (e) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen de la Evaluación'),
        backgroundColor: const Color(0xFF002855),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Terminar Evaluación',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(
                    userName: 'NombreUsuario', // Reemplaza con el nombre real del usuario
                    userId: widget.userId,     // Usa widget.userId si está definido
                  ),
                ),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dbHelper.obtenerDatosEvaluacion(widget.evaluacionId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No se encontraron datos.'));
          }

          final datos = snapshot.data!;

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.only(bottom: 80.0),
                children: [
                  _buildSectionCard('1. Identificación de la Evaluación', datos['evaluacion']),
                  _buildSectionCard('2. Identificación de la Edificación', {
                    ...?datos['edificio'] as Map<String, dynamic>?,
                    'Contacto': datos['contacto'],
                  }),
                  _buildSectionCard('3. Descripción de la Edificación', {
                    'Características': datos['caracteristicas_generales'],
                    'Usos': datos['usos_predominantes'],
                    'Estructura': datos['detalle_estructura'],
                  }),
                  _buildSectionCard('4. Riesgos Externos', {
                    'Riesgos': datos['riesgos_externos'],
                  }),
                  _buildSectionCard('5. Daños en la Edificación', {
                    'Evaluación': datos['danos_evaluacion'],
                    'Elementos': datos['elementos_no_estructurales'],
                  }),
                  _buildSectionCard('6. Habitabilidad', {
                    'Estado': datos['habitabilidad']?['estado_habitabilidad'] ?? 'No determinado',
                    'Severidad de Daños': datos['habitabilidad']?['severidad_danos'] ?? 'No especificado',
                    'Porcentaje de Afectación': datos['habitabilidad']?['porcentaje_afectacion'] ?? 'No especificado',
                    'Criterio': datos['habitabilidad']?['criterio_habitabilidad'] ?? 'No especificado',
                  }),
                  _buildSectionCard('7. Acciones Recomendadas', {
                    'Acciones': datos['acciones_recomendadas'],
                    'Evaluación Adicional': datos['evaluacion_adicional'],
                  }),
                  const SizedBox(height: 80),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _guardarPDF(context),
                        icon: const Icon(Icons.save),
                        label: const Text('PDF'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _enviarPDF(context),
                        icon: const Icon(Icons.send),
                        label: const Text('PDF'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implementar guardado CSV
                        },
                        icon: const Icon(Icons.save_alt),
                        label: const Text('CSV'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implementar envío CSV
                        },
                        icon: const Icon(Icons.upload_file),
                        label: const Text('CSV'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}