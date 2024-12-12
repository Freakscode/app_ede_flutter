// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PrimeraSubseccion extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController fechaController;
  final TextEditingController horaController;
  final TextEditingController nombreEvaluadorController;
  final TextEditingController dependenciaController;
  final TextEditingController idGrupoController;
  final VoidCallback onGuardar;
  final Future<void> Function(BuildContext) selectDate;
  final Future<void> Function(BuildContext) selectTime;
  final VoidCallback onPrevisualizar;
  final ValueNotifier<ImageProvider?> firmaImageNotifier; // Añadido
  final Future<void> Function() onSubirFirma;

  const PrimeraSubseccion({
    super.key,
    required this.formKey,
    required this.fechaController,
    required this.horaController,
    required this.nombreEvaluadorController,
    required this.dependenciaController,
    required this.idGrupoController,
    required this.onGuardar,
    required this.selectDate,
    required this.selectTime,
    required this.onPrevisualizar,
    required this.firmaImageNotifier, // Añadido
    required this.onSubirFirma,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Encabezado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Botón de Nuevo Registro
              ElevatedButton.icon(
                onPressed: onGuardar,
                icon: const Icon(Icons.refresh),
                label: const Text('Nuevo Registro'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002855),
                ),
              ),
              // Ícono de Usuario
              const Icon(
                Icons.account_circle,
                size: 40,
                color: Color(0xFF002855),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Título
          const Center(
            child: Text(
              'IDENTIFICACIÓN DE EVALUACIÓN',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF002855),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Nombre del Evaluador
          TextFormField(
            controller: nombreEvaluadorController,
            decoration: const InputDecoration(
              labelText: 'Nombre del Evaluador',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa el nombre del evaluador';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),

          // ID Evento con ícono de lupa
          TextFormField(
            controller: fechaController,
            decoration: InputDecoration(
              labelText: 'ID Evento',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  // Implementar lógica de búsqueda aquí
                },
              ),
            ),
            // Opcional: Validación si es requerida
          ),
          const SizedBox(height: 16.0),

          // ID Grupo
          TextFormField(
            controller: idGrupoController,
            decoration: const InputDecoration(
              labelText: 'ID Grupo',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa el ID de grupo';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),

          // Dependencia / Entidad
          TextFormField(
            controller: dependenciaController,
            decoration: const InputDecoration(
              labelText: 'Dependencia / Entidad',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa la dependencia o entidad';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),

          // Placeholder para Firma
          GestureDetector(
            onTap: onSubirFirma, // Usamos la función que movimos fuera
            child: ValueListenableBuilder<ImageProvider?>(
              valueListenable: firmaImageNotifier,
              builder: (context, firmaImage, child) {
                return Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: firmaImage != null
                      ? Stack(
                          children: [
                            Image(
                              image: firmaImage,
                              fit: BoxFit.contain,
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  firmaImageNotifier.value = null;
                                },
                              ),
                            ),
                          ],
                        )
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.upload_file, size: 48),
                              SizedBox(height: 8),
                              Text(
                                'Tocar para subir firma',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                );
              },
            ),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}